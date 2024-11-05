//
//  ContentView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @ObservedObject var models: Models
    @State private var isControlVisibility: Bool = true
    @State private var showBrowse: Bool = false
    @State var showCreateView: Bool = false
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
            
            if self.placementSettings.selectedModel == nil {
                ControlView(models: models, isControlVisibility: $isControlVisibility, showCreateView: $showCreateView, showBrowse: $showBrowse, showSettings: $showSettings)
            } else {
                PlacementView()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}



struct ARViewContainer: UIViewRepresentable {
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings

    func makeUIView(context: Context) -> CustomARView {
        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
        
        arView.sceneUpdateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { [weak arView] event in
            if let arView = arView {
                self.updateScene(for: arView)
            }
        }
        
        return arView
    }

    func updateUIView(_ uiView: CustomARView, context: Context) {}

    static func dismantleUIView(_ uiView: CustomARView, coordinator: ()) {
        // Корректная отписка от события
        uiView.sceneUpdateSubscription?.cancel()
        uiView.session.pause()
    }
    
    private func updateScene(for arView: CustomARView) {
        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil

        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
            place(modelEntity, in: arView)
            self.placementSettings.confirmedModel = nil
        }
    }

    private func place(_ modelEntity: ModelEntity, in arView: ARView) {
        let clonedEntity = modelEntity.clone(recursive: true)

        clonedEntity.generateCollisionShapes(recursive: true)
        arView.installGestures([.translation, .rotation], for: clonedEntity)

        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)

        arView.scene.addAnchor(anchorEntity)
        print("added modelEntity to scene")
    }
}



//struct ARViewContainer: UIViewRepresentable {
//    @EnvironmentObject var placementSettings: PlacementSettings
//    @EnvironmentObject var sessionSettings: SessionSettings
//
//    func makeUIView(context: Context) -> CustomARView {
//        let arView = CustomARView(frame: .zero, sessionSettings: sessionSettings)
//        self.placementSettings.sceneObserver = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
//            self.updateScene(for: arView)
//        })
//        return arView
//    }
//    
//    func updateUIView(_ uiView: CustomARView, context: Context) {}
//    
//    private func updateScene(for arView: CustomARView) {
//        arView.focusEntity?.isEnabled = self.placementSettings.selectedModel != nil
//        
//        if let confirmedModel = self.placementSettings.confirmedModel, let modelEntity = confirmedModel.modelEntity {
//            self.place(modelEntity, in: arView)
//            self.placementSettings.confirmedModel = nil
//        }
//    }
//    
//    private func place(_ modelEntity: ModelEntity, in arView: ARView) {
//        // clone modelEntity. this creates an identical copy of modelEntity and references the same model. this allows us to have multiple models of the same asset in out scene
//        let clonedEntity = modelEntity.clone(recursive: true)
//
//        //enable translation and rotating gestures
//        clonedEntity.generateCollisionShapes(recursive: true)
//        arView.installGestures([.translation, .rotation], for: clonedEntity)
//        
//        //create an anchorEntity and add clonedEntity to anchorEntity
//        let anchorEntity = AnchorEntity(plane: .any)
//        anchorEntity.addChild(clonedEntity)
//        
//        //add the anchorEntity to arView.scene
//        arView.scene.addAnchor(anchorEntity)
//        print("added modelEntity to scene")
//        
//    }
//}

//#Preview {
//    ContentView()
//        .environmentObject(PlacementSettings())
//        .environmentObject(SessionSettings())
//}
