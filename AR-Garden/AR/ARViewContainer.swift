//
//  ARViewContainer.swift
//  AR-Garden
//
//  Created by Flavio Matias on 22/02/2022.
//

import UIKit
import SwiftUI
import RealityKit
import ARKit
import MultipeerSession

private let anchorPrefix = "model-"

struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var viewModel: ARViewModel
    
    typealias UIViewType = ARView
    
    func makeUIView(context: Context) -> ARView {
        viewModel.arView.session.delegate = context.coordinator
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        return viewModel.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}

extension ARViewContainer {
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        // Place model from loaded scene or multiuser experience
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            for anchor in anchors {
                if let name = anchor.name, name.hasPrefix(anchorPrefix) {
                    let modelName = String(name.dropFirst(anchorPrefix.count))
                    
                    if let model = self.parent.viewModel.models.first(where: { $0.modelName == modelName }) {
                        model.loadModel(handler: { completed, error in
                            if completed {
                                self.parent.viewModel.place(modelName, for: anchor)
                            }
                        })
                    }
                }
            }
        }
        
        func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
            guard let multipeerSession = self.parent.viewModel.multipeerSession else { return }
            
            if !multipeerSession.connectedPeers.isEmpty {
                guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true) else { fatalError("Unexpectedly failed to encode collaboration data.") }

                let dataIsCritical = data.priority == .critical
                multipeerSession.sendToAllPeers(encodedData, reliably: dataIsCritical)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}
