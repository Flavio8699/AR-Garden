//
//  CustomARView.swift
//  AR-Garden
//
//  Created by Flavio Matias on 14/03/2022.
//

import SwiftUI
import FocusEntity
import ARKit
import RealityKit
import Combine

class CustomARView: ARView {
    
    var modelsViewModel: ModelsViewModel
    var currentSession: Session
    var focusEntity: FocusEntity?
    
    var configuration: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        return config
    }
    
    private var cancellablePeopleOcclusion: AnyCancellable?
    private var cancellableObjectOcclusion: AnyCancellable?
    private var cancellableLidar: AnyCancellable?
    
    required init(frame frameRect: CGRect, session currentSession: Session, modelsViewModel: ModelsViewModel) {
        self.currentSession = currentSession
        self.modelsViewModel = modelsViewModel
        super.init(frame: frameRect)
        
        self.focusEntity = FocusEntity(on: self, focus: .classic)

        session.run(configuration)
        
        self.cancellablePeopleOcclusion = currentSession.$peopleOcclusion.sink { [weak self] _ in
            self?.togglePeopleOcclusion()
        }
        
        self.cancellableObjectOcclusion = currentSession.$objectOcclusion.sink { [weak self] _ in
            self?.toggleObjectOcclusion()
        }
        
        self.cancellableLidar = currentSession.$lidar.sink { [weak self] _ in
            self?.toggleLidar()
        }
        
        self.enableDeletion()
    }
    
    func togglePeopleOcclusion() {
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else { return }
        guard let config = self.session.configuration as? ARWorldTrackingConfiguration else { return }
        
        if config.frameSemantics.contains(.personSegmentationWithDepth) {
            config.frameSemantics.remove(.personSegmentationWithDepth)
        } else {
            config.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        self.session.run(config)
    }
    
    func toggleObjectOcclusion() {
        if self.environment.sceneUnderstanding.options.contains(.occlusion) {
            self.environment.sceneUnderstanding.options.remove(.occlusion)
        } else {
            self.environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    func toggleLidar() {
        if self.debugOptions.contains(.showSceneUnderstanding) {
            self.debugOptions.remove(.showSceneUnderstanding)
        } else {
            self.debugOptions.insert(.showSceneUnderstanding)
        }
    }
    
    required init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomARView {
    func enableDeletion() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(recognizer:)))
        self.addGestureRecognizer(tapGesture)
    }
     
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        if let entity = self.entity(at: location) as? ModelEntity {
            self.modelsViewModel.selectedModelDeletion = entity
        }
    }
}
