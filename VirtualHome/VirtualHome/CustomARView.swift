//
//  CustomARView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import RealityKit
import ARKit
import FocusEntity
import SwiftUI
import Combine

class CustomARView: ARView {
    var focusEntity: FocusEntity?
    var sessionSettings: SessionSettings
    
    private var peopleOcclussionCancellable: AnyCancellable?
    private var objectOcclussionCancellable: AnyCancellable?
    private var lidarDebugCancellable: AnyCancellable?
    private var multiuserCancellable: AnyCancellable?
    
    required init(frame frameRect: CGRect, sessionSettings: SessionSettings) {
        self.sessionSettings = sessionSettings
        super.init(frame: frameRect)
        
        focusEntity = FocusEntity(on: self, focus: .classic)
        configure()
        
        self.initializeSettings()

        self.setupSubscribers()
    }
    required init(frame frameRect: CGRect) {
        fatalError("init(frame) has not been implemented")
    }
    
    @MainActor @preconcurrency required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

        session.run(config)
    }
    
    private func initializeSettings() {
        self.updatePeopleOcclusion(isEnabled: sessionSettings.isPeopleOcclussionEnabled)
        self.updateObjectOcclusion(isEnabled: sessionSettings.isObjectOcclussionEnabled)
        self.updateLidarDebug(isEnabled: sessionSettings.isLidarDebugEnabled)
        self.updateMultiuser(isEnabled: sessionSettings.isMultiuserEnabled)
    }
    
    private func setupSubscribers() {
        self.peopleOcclussionCancellable = sessionSettings.$isPeopleOcclussionEnabled.sink { [weak self] isEnable in
            self?.updatePeopleOcclusion(isEnabled: isEnable)
        }
        
        self.objectOcclussionCancellable = sessionSettings.$isObjectOcclussionEnabled.sink { [weak self] isEnable in
            self?.updateObjectOcclusion(isEnabled: isEnable)
        }
        
        self.lidarDebugCancellable = sessionSettings.$isLidarDebugEnabled.sink { [weak self] isEnable in
            self?.updateLidarDebug(isEnabled: isEnable)
        }
        
        self.multiuserCancellable = sessionSettings.$isMultiuserEnabled.sink { [weak self] isEnable in
            self?.updateMultiuser(isEnabled: isEnable)
        }
    }
    
    private func updatePeopleOcclusion(isEnabled: Bool) {
        print("PeopleOcclusion now is enabled \(isEnabled)")
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            return
        }
        
        guard let configuration = self.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        
        if configuration.frameSemantics.contains(.personSegmentationWithDepth) {
            configuration.frameSemantics.remove(.personSegmentationWithDepth)
        } else {
            configuration.frameSemantics.insert(.personSegmentationWithDepth)
        }
        
        self.session.run(configuration)
    }
    
    private func updateObjectOcclusion(isEnabled: Bool) {
        print("ObjectOcclusion now is enabled \(isEnabled)")
        
        if self.environment.sceneUnderstanding.options.contains(.occlusion) {
            self.environment.sceneUnderstanding.options.remove(.occlusion)
        } else {
            self.environment.sceneUnderstanding.options.insert(.occlusion)
        }
    }
    
    private func updateLidarDebug(isEnabled: Bool) {
        print("LidarDebug now is enabled \(isEnabled)")
        
        if self.debugOptions.contains(.showSceneUnderstanding) {
            self.debugOptions.remove(.showSceneUnderstanding)
        } else {
            self.debugOptions.insert(.showSceneUnderstanding)
        }
    }
    
    private func updateMultiuser(isEnabled: Bool) {
        print("Multiuser now is enabled \(isEnabled)")
    }
}
