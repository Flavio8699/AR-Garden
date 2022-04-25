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
import MultipeerSession

class CustomARView: ARView {
    
    var settings: Settings
    var focusEntity: FocusEntity?
    
    var configuration: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }
        
        config.isCollaborationEnabled = true

        return config
    }
    
    private var cancellablePeopleOcclusion: AnyCancellable?
    private var cancellableObjectOcclusion: AnyCancellable?
    private var cancellableLidar: AnyCancellable?
    private var cancellableMultiuser: AnyCancellable?
    
    required init(frame frameRect: CGRect, settings: Settings) {
        self.settings = settings
        super.init(frame: frameRect)
        
        self.focusEntity = FocusEntity(on: self, focus: .classic)
        
        self.automaticallyConfigureSession = false
        session.run(configuration)
        
        // Setup a coaching overlay
        let coachingOverlay = ARCoachingOverlayView()

        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.session = session
        coachingOverlay.goal = .horizontalPlane
        
        self.addSubview(coachingOverlay)
        
        self.cancellablePeopleOcclusion = settings.$peopleOcclusion.sink { [weak self] _ in
            self?.togglePeopleOcclusion()
        }

        self.cancellableObjectOcclusion = settings.$objectOcclusion.sink { [weak self] _ in
            self?.toggleObjectOcclusion()
        }

        self.cancellableLidar = settings.$lidar.sink { [weak self] _ in
            self?.toggleLidar()
        }
        
        self.cancellableMultiuser = settings.$multiuser.sink { [weak self] _ in
            self?.toggleMultiuser()
        }
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
    
    func toggleMultiuser() {
        guard let config = self.session.configuration as? ARWorldTrackingConfiguration else { return }
        config.isCollaborationEnabled.toggle()
        self.session.run(config)
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @MainActor override required dynamic init(frame frameRect: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }
}
