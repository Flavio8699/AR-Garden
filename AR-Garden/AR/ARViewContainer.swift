//
//  ARViewContainer.swift
//  AR-Garden
//
//  Created by Flavio Matias on 22/02/2022.
//

import SwiftUI
import RealityKit
import ARKit

private let anchorPrefix = "model-"

struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var session: Session
    @EnvironmentObject var sceneManager: SceneManager
    @EnvironmentObject var modelsViewModel: ModelsViewModel
    
    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, session: session, modelsViewModel: modelsViewModel)
        
        arView.session.delegate = context.coordinator
        
        session.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { event in
            self.updateScene(for: arView)
            self.updatePersistence(for: arView)
            self.handlePersistence(for: arView)
        })
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        return arView
    }
    
    func updateUIView(_ uiview: CustomARView, context: Context) {}
    
    private func updateScene(for arView: CustomARView) {
        arView.focusEntity?.isEnabled = modelsViewModel.selectedModelPlacement != nil
        
        // Add models
        if let modelAnchor = self.modelsViewModel.placeModels.popLast(), let modelEntity = modelAnchor.model.entity {
            if let anchor = modelAnchor.anchor {
                // Anchor exists -> being loaded from persisted scene
                
                print("PLACED FROM SCENE")
                self.place(modelEntity, for: anchor, in: arView)
            } else if let transform = getTransformForPlacement(in: arView) {
                // User is placing a model, anchor needs to be created
                
                let anchorName = anchorPrefix + modelAnchor.model.modelName
                let anchor = ARAnchor(name: anchorName, transform: transform)
                
                print("PLACED BY USER")
                self.place(modelEntity, for: anchor, in: arView)
                arView.session.add(anchor: anchor)
                self.modelsViewModel.recentModels.append(modelAnchor.model)
            }
        }
    }
    
    private func place(_ modelEntity: ModelEntity, for anchor: ARAnchor, in arView: CustomARView) {
        let clone = modelEntity.clone(recursive: true)
        
        clone.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: clone)
        
        let anchorEntity = AnchorEntity(plane: .horizontal)
        anchorEntity.addChild(clone)
        
        anchorEntity.anchoring = AnchoringComponent(anchor)
        
        arView.scene.addAnchor(anchorEntity)
        
        sceneManager.anchorEntities.append(anchorEntity)
    }
    
    private func getTransformForPlacement(in arView: ARView) -> simd_float4x4? {
        guard let query = arView.makeRaycastQuery(from: arView.center, allowing: .estimatedPlane, alignment: .horizontal) else { return nil }
        
        guard let raycast = arView.session.raycast(query).first else { return nil }
        
        return raycast.worldTransform
    }
    
}

extension ARViewContainer {
    private func updatePersistence(for arView: ARView) {
        guard let frame = arView.session.currentFrame else { return }
        
        switch frame.worldMappingStatus {
        case .mapped, .extending:
            self.sceneManager.persistenceAvailable = !self.sceneManager.anchorEntities.isEmpty
        default:
            self.sceneManager.persistenceAvailable = false
        }
    }
    
    private func handlePersistence(for arView: CustomARView) {
        switch self.sceneManager.persistenceAction {
        case .save:
            self.sceneManager.saveScene(for: arView)
            self.sceneManager.persistenceAction = nil
        case .load:
            self.modelsViewModel.clearModels()
            self.sceneManager.anchorEntities.removeAll(keepingCapacity: true)
            self.sceneManager.loadScene(for: arView)
            self.sceneManager.persistenceAction = nil
        default:
            return
        }
    }
}

extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            var modelsToAdd = [String:[ARAnchor]]()
            
            for anchor in anchors {
                if let name = anchor.name, name.hasPrefix(anchorPrefix) {
                    let modelName = String(name.dropFirst(anchorPrefix.count))
                    
                    if !modelsToAdd.keys.contains(modelName) {
                        modelsToAdd[modelName] = []
                    }
                    modelsToAdd[modelName]!.append(anchor)
                }
            }
            
            for (modelName, anchors) in modelsToAdd {
                guard let model = self.parent.modelsViewModel.models.first(where: { $0.modelName == modelName }) else {
                    NSLog("No model found with name \(modelName)")
                    return
                }
                
                if model.entity == nil {
                    model.loadModel(handler: { completed, error in
                        if completed {
                            for anchor in anchors {
                                let modelAnchor = ModelAnchor(model: model, anchor: anchor)
                                self.parent.modelsViewModel.placeModels.append(modelAnchor)
                            }
                        }
                    })
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
