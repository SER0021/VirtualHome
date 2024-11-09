//
//  ContentView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI
import RealityKit


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @ObservedObject var models: Models
    @State private var isControlVisibility: Bool = true
    @State private var showBrowse: Bool = false
    @State var showCreateView: Bool = false
    @State private var showSettings: Bool = false
    @State private var showLoadingSpinner: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
            
            if self.placementSettings.selectedModel == nil {
                ControlView(models: models, isControlVisibility: $isControlVisibility, showCreateView: $showCreateView, showBrowse: $showBrowse, showSettings: $showSettings)
            } else {
                PlacementView()
            }
            
            VStack {
                Spacer()
                if showLoadingSpinner {
                    ProgressView("Loading...")
                        .frame(width: 100, height: 100)
                        .progressViewStyle(CircularProgressViewStyle())
                        .foregroundStyle(.white)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding()
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onReceive(NotificationCenter.default.publisher(for: .start3DModelAdded)) { _ in
            startLoading()
        }
        .onReceive(NotificationCenter.default.publisher(for: .end3DModelAdded)) { _ in
            stopLoading()
        }
    }

    // Функция для запуска спиннера
    func startLoading() {
        showLoadingSpinner = true
    }

    // Функция для остановки спиннера
    func stopLoading() {
        showLoadingSpinner = false
    }
}

//struct ContentView: View {
//    @EnvironmentObject var placementSettings: PlacementSettings
//    @ObservedObject var models: Models
//    @State private var isControlVisibility: Bool = true
//    @State private var showBrowse: Bool = false
//    @State var showCreateView: Bool = false
//    @State private var showSettings: Bool = false
//    @State private var showLoadingSpinner: Bool = false
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            ARViewContainer()
//            
//            if self.placementSettings.selectedModel == nil {
//                ControlView(models: models, isControlVisibility: $isControlVisibility, showCreateView: $showCreateView, showBrowse: $showBrowse, showSettings: $showSettings)
//            } else {
//                PlacementView()
//            }
//        }
//        .edgesIgnoringSafeArea(.all)
//    }
//}
//
//NotificationCenter.default.addObserver(self, selector: #selector(start3DModelAdded), name: .start3DModelAdded, object: nil)
//

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
