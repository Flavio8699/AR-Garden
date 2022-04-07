//
//  SceneManager.swift
//  AR-Garden
//
//  Created by Flavio Matias on 01/04/2022.
//

import Foundation
import RealityKit
import ARKit

class SceneManager: ObservableObject {
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
    
    func saveScene(for arView: CustomARView) {
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
    
    func loadScene(for arView: CustomARView) {
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

enum PersistenceAction {
    case save
    case load
}
