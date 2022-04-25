//
//  ARViewModel.swift
//  BSP6
//
//  Created by Flavio Matias on 25/04/2022.
//

import UIKit
import SwiftUI
import RealityKit
import ARKit
import MultipeerConnectivity
import Combine

private let anchorPrefix = "model-"

class ARViewModel: ObservableObject {
    
    var sceneObserver: Cancellable?
    @Published var arView: CustomARView!
    
    // Settings
    @Published var settings = Settings()
    
    // Models
    var placeModels = [Model]()
    @Published var models = [Model]()
    @Published var selectedModelPlacement: Model?
    @Published var recentModels = [Model]()
    @Published var selectedModelDeletion: ModelEntity? = nil {
        willSet (model) {
            if selectedModelDeletion == nil, let modelForDeletion = model {
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                modelForDeletion.modelDebugOptions = component
            } else if let previousModel = selectedModelDeletion, let modelForDeletion = model {
                previousModel.modelDebugOptions = nil
                let component = ModelDebugOptionsComponent(visualizationMode: .lightingDiffuse)
                modelForDeletion.modelDebugOptions = component
            } else if model == nil {
                selectedModelDeletion?.modelDebugOptions = nil
            }
        }
    }
    
    // Persistence
    @Published var persistenceAvailable: Bool = false
    @Published var anchorEntities: [AnchorEntity] = []
    @Published var persistenceAction: PersistenceAction?
    
    lazy var persistenceURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Error with persistence URL: \(error.localizedDescription)")
        }
    }()
    
    var scenePersistenceData: Data? {
        return try? Data(contentsOf: self.persistenceURL)
    }
    
    // Multiuser experience
    var peerSessionIDs = [MCPeerID: String]()
    var multipeerSession: MultipeerSession?
    var sessionIDObservation: NSKeyValueObservation?
    
    init() {
        arView = CustomARView(frame: .zero, settings: settings)
        
        self.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { event in
            self.updateScene()
            self.updatePersistence()
            self.handlePersistence()
        })
        
        // Add tap gesture to select a model for deletion
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        self.arView.addGestureRecognizer(tapGesture)
        
        // Multiuser experience
        sessionIDObservation = arView.session.observe(\.identifier, options: [.new]) { object, change in
            guard let multipeerSession = self.multipeerSession else { return }
            self.sendARID(to: multipeerSession.connectedPeers)
        }
        
        multipeerSession = MultipeerSession(receivedDataHandler: self.receiveData, peerJoinedHandler: self.peerJoined, peerLeftHandler: self.peerLeft, peerDiscoveredHandler: self.peerDiscovered)
    }
    
    func loadModels() {
        let teapot = Model(modelName: "teapot", name: "Teapot", scale: 0.1)
        let cupandsaucer = Model(modelName: "cupandsaucer", name: "Cup and saucer", scale: 0.01)
        let tree = Model(modelName: "tree", name: "Tree", scale: 0.1)
        
        self.models += [teapot, cupandsaucer, tree]
        
        for model in models {
            model.loadModel(handler: { completed, error in
                if completed {
                    print("LOADED \(model.modelName)")
                }
            })
        }
    }
    
    private func updateScene() {
        arView.focusEntity?.isEnabled = selectedModelPlacement != nil
        
        if let model = self.placeModels.popLast() {
            if let transform = self.getTransformForPlacement() {
                // User is placing a model, anchor needs to be created
                
                let anchorName = anchorPrefix + model.modelName
                let anchor = ARAnchor(name: anchorName, transform: transform)
                self.arView.session.add(anchor: anchor)
                
                self.recentModels.append(model)
            }
        }
    }
    
    func place(_ modelName: String, for anchor: ARAnchor) {
        let model = self.models.first(where: {
            $0.modelName == modelName
        })
        
        if let model = model, let modelEntity = model.entity {
            let clone = modelEntity.clone(recursive: true)
            
            clone.generateCollisionShapes(recursive: true)
            arView.installGestures([.translation, .rotation], for: clone)

            let anchorEntity = AnchorEntity(anchor: anchor)
            anchorEntity.addChild(clone)

            arView.scene.addAnchor(anchorEntity)
            self.anchorEntities.append(anchorEntity)
        }
    }
    
    private func getTransformForPlacement() -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal) else { return nil }
        
        guard let raycast = arView.session.raycast(query).first else { return nil }
        
        return raycast.worldTransform
    }
    
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.arView)
        
        if let entity = self.arView.entity(at: location) as? ModelEntity {
            self.selectedModelDeletion = entity
        }
    }
    
    func deleteSelectedModel() {
        guard let anchor = selectedModelDeletion?.anchor else { return }

        let identifier = anchor.anchorIdentifier
        if let index = anchorEntities.firstIndex(where: { $0.anchorIdentifier == identifier }) {
            anchorEntities.remove(at: index)
        }
        anchor.removeFromParent()
        selectedModelDeletion = nil
        persistenceAction = .save
    }
    
    func getUniqueRecents() -> [Model] {
        var result = [Model]()
        
        for model in self.recentModels.reversed() {
            if !result.contains(where: { $0.modelName == model.modelName }) {
                result.append(model)
            }
        }
        
        return result
    }
}

// MARK: Persistence
enum PersistenceAction {
    case save
    case load
}

extension ARViewModel {
    private func updatePersistence() {
        guard let frame = arView.session.currentFrame else { return }
        
        switch frame.worldMappingStatus {
        case .mapped, .extending:
            self.persistenceAvailable = !self.anchorEntities.isEmpty
        default:
            self.persistenceAvailable = false
        }
    }
    
    private func handlePersistence() {
        switch self.persistenceAction {
        case .save:
            self.saveScene(for: arView)
            self.persistenceAction = nil
        case .load:
            self.anchorEntities.removeAll(keepingCapacity: true)
            self.loadScene(for: arView)
            self.persistenceAction = nil
        default:
            return
        }
    }
    
    private func saveScene(for arView: CustomARView) {
        arView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap else { return }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try data.write(to: self.persistenceURL, options: [.atomic])
            } catch {
                NSLog("Can't save scene: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadScene(for arView: CustomARView) {
        if let scenePersistenceData = self.scenePersistenceData {
            let map: ARWorldMap = {
                do {
                    guard let map = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: scenePersistenceData) else {
                        fatalError("No worldmap found")
                    }
                    
                    return map
                } catch {
                    fatalError("Error loading scene: \(error.localizedDescription)")
                }
            }()
            
            let config = arView.configuration
            config.initialWorldMap = map
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        }
    }
}

// MARK: Multiuser experience
extension ARViewModel {
    func sendARID(to peers: [MCPeerID]) {
        guard let multipeerSession = multipeerSession else { return }
        let cmd = "Session" + arView.session.identifier.uuidString
        if let data = cmd.data(using: .utf8) {
            multipeerSession.sendToPeers(data, reliably: true, peers: peers)
        }
    }
    
    func receiveData(_ data: Data, from peer: MCPeerID) {
        guard let _ = multipeerSession else { return }
        
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            arView.session.update(with: collaborationData)
            return
        }
        
       let sessionIDCommandString = "Session"
        
       if let commandString = String(data: data, encoding: .utf8), commandString.starts(with: sessionIDCommandString) {
           let newSessionID = String(commandString[commandString.index(commandString.startIndex, offsetBy: sessionIDCommandString.count)...])
           print("Recevied \(commandString) from \(peer.displayName)")
           
           if let oldSessionID = peerSessionIDs[peer] {
               removeAllAnchorsOriginatingFromARSessionWithID(oldSessionID)
           }

           peerSessionIDs[peer] = newSessionID
           print(peerSessionIDs)
        }
    }
    
    func peerDiscovered (peer: MCPeerID) -> Bool {
       guard let multipeerSession = multipeerSession else { return false }
        
       if multipeerSession.connectedPeers.count > 4 {
           print("Limited to 4 players")
           return false
       } else {
           return true
       }
    }

    func peerJoined (peer: MCPeerID) {
       print("A player wants to join the game. Hold the devices next to each other.")
       sendARID(to: [peer])
    }
    
    func peerLeft( peer: MCPeerID) {
        guard let _ = multipeerSession else { return }
        
        print("A player has left the game.")
        if let sessionID = peerSessionIDs[peer] {
            removeAllAnchorsOriginatingFromARSessionWithID(sessionID)
            peerSessionIDs.removeValue(forKey: peer)
        }
    }

    func removeAllAnchorsOriginatingFromARSessionWithID(_ id: String) {
        guard let frame = arView.session.currentFrame else { return }
        
        for anchor in frame.anchors {
            guard let sessionID = anchor.sessionIdentifier else { return }
            if sessionID.uuidString == id {
                arView.session.remove(anchor: anchor)
            }
        }
    }
}
