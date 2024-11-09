//
//  ContentView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI
import UIKit
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
        
        // Добавляем жест длительного удержания
        let longPressGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
        arView.addGestureRecognizer(longPressGesture)

        return arView
    }

    func updateUIView(_ uiView: CustomARView, context: Context) {}

    static func dismantleUIView(_ uiView: CustomARView, coordinator: ()) {
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
        arView.installGestures([.translation, .scale, .rotation], for: clonedEntity)

        let anchorEntity = AnchorEntity(plane: .any)
        anchorEntity.addChild(clonedEntity)

        arView.scene.addAnchor(anchorEntity)
        print("added modelEntity to scene")
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: ARViewContainer
        private var selectedEntity: ModelEntity?
        private var initialTouchPoint: CGPoint?
        private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
            guard let arView = recognizer.view as? ARView else { return }
            
            let location = recognizer.location(in: arView)

            switch recognizer.state {
            case .began:
                feedbackGenerator.prepare() // Готовим вибрацию
                feedbackGenerator.impactOccurred() // Воспроизводим вибрацию
                // Определяем объект под пальцем при начале удержания
                if let entity = arView.entity(at: location) as? ModelEntity {
                    selectedEntity = entity
                    initialTouchPoint = location
                    print("Object selected for manipulation")
                }
            case .changed:
                guard let entity = selectedEntity, let initialPoint = initialTouchPoint else { return }
                let currentPoint = location
                let translation = CGPoint(x: currentPoint.x - initialPoint.x, y: currentPoint.y - initialPoint.y)

                // Параметры вращения
                let rotationMultiplier: Float = 0.00009
                var xRotation: Float = 0
                var yRotation: Float = 0

                // Определяем направление движения пальца
                if abs(translation.x) > abs(translation.y) {
                    // Вращение по оси Y (влево/вправо)
                    yRotation = Float(translation.x) * rotationMultiplier
                } else {
                    // Вращение по оси X (вверх/вниз)
                    xRotation = Float(-translation.y) * rotationMultiplier
                }

                // Применяем вращение к объекту
                let newOrientation = simd_mul(entity.orientation,
                                              simd_quatf(angle: xRotation, axis: [1, 0, 0]))
                entity.orientation = simd_mul(newOrientation,
                                              simd_quatf(angle: yRotation, axis: [0, 0, 1]))
            case .ended, .cancelled:
                // Сбрасываем выбранный объект
                selectedEntity = nil
                initialTouchPoint = nil
                print("Object manipulation ended")
            default:
                break
            }
        }
    }
}
