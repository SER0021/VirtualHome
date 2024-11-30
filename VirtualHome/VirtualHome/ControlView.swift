//
//  ControlView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI
import RealityFoundation

struct ControlView: View {
    @ObservedObject var models: Models
    @Binding var isControlVisibility: Bool
    @Binding var showCreateView: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @Binding var showSelectedModel: Bool
    @Binding var selectedModel: Model?
    @Binding var selectedModelAnchor: AnchorEntity?
    @Binding var showLoadingSpinner: Bool
    @State private var loadingProgress: Double = 0.0
    @State private var showSuccessPopup: Bool = false

    var body: some View {
        VStack {
            HStack {
                if isControlVisibility {
                    SettingsButton() {
                        print("settings button pressed")
                        self.showSettings.toggle()
                    }.sheet(isPresented: $showSettings) {
                        SettingsView(showSettings: $showSettings)
                    }
                }
                
                Spacer()
                
                
                ZStack(alignment: .top) {
                    // Прогресс-бар
                    if showLoadingSpinner {
                        VStack {
                            Text("Создаем модель...")
                                .font(.system(size: 14))
                                .foregroundColor(.white)

                            ProgressView(value: loadingProgress, total: 1.0)
                                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                .padding(.horizontal)
                                .frame(width: 150, height: 10)
                                .cornerRadius(5)
                        }
                        .frame(width: 150, height: 50)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top, 40)
                        .padding()
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showLoadingSpinner)
                        .onAppear {
                            startLoading()
                        }
                        .onDisappear {
                            stopLoading()
                        }
                    }
                    
                    // Всплывающее сообщение успеха
                    if showSuccessPopup {
                        VStack {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .foregroundColor(.green)
                                    .frame(width: 24, height: 24)
                                    .padding(.trailing, 10)

                                Text("Модель добавлена")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .frame(width: 150, height: 50)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(.top, 40)
                        .padding()
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: showSuccessPopup)
                    }
                }
                .frame(height: 100)

                Spacer()
                
                if isControlVisibility {
                    CloseButton()
                }
            }
            .padding(.top, 10)
            Spacer()

            HStack{
                Spacer()

                if isControlVisibility && showSelectedModel && selectedModel != nil {
                    Spacer()
                    ModelHeightControlView(selectedModelAnchor: $selectedModelAnchor)
                }
            }
            
            Spacer()
            
            if isControlVisibility && showSelectedModel && selectedModel != nil {
                SelectedModelView(models: models, showSelectedModel: $showSelectedModel, model: $selectedModel, selectedModelAnchor: $selectedModelAnchor)
            }
            
            ControlButtonBar(isControlVisibility: $isControlVisibility, showBrowse: $showBrowse, showSettings: $showSettings, models: models)
        }
        .onReceive(NotificationCenter.default.publisher(for: .end3DModelAdded)) { _ in
            
        }
    }
    
    
    private func startLoading() {
        loadingProgress = 0.0
        let totalDuration: TimeInterval = 90.0
        let stepDuration: TimeInterval = 0.1
        let progressStep = stepDuration / totalDuration
        
        Task {
            while showLoadingSpinner && loadingProgress < 1.0 {
                try await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000)) // 0.1 секунды
                loadingProgress += progressStep
                
                // Ограничиваем прогресс максимумом в 1.0 на случай, если он выйдет за пределы
                if loadingProgress >= 1.0 {
                    loadingProgress = 1.0
                    break
                }
            }
            
            if !showLoadingSpinner {
                loadingProgress = 1.0 // Завершаем прогресс, если флаг изменяется на false до конца
            }
        }
    }
    
    
    private func stopLoading() {
        loadingProgress = 1.0
        
        // Отобразить всплывающее сообщение об успехе
        showSuccessPopup = true
        
        // Установить таймер для скрытия всплывающего сообщения
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { // Задержка в 2 секунды
            withAnimation {
                showSuccessPopup = false
            }
        }
    }
}

struct CloseButton: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Color.black.opacity(0.25)
                
                Button(action: {
                    print("close button")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 25))
                        .foregroundStyle(.white)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)
        }
        .padding(.top, 45)
        .padding(.trailing, 25)
    }
}

struct ControlVisibilityToggleButton: View {
    @Binding var isControlVisibility: Bool

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Color.black.opacity(0.25)
                
                Button(action: {
                    print("Control visibility toggle")
                    self.isControlVisibility.toggle()
                }) {
                    Image(systemName: self.isControlVisibility ? "rectangle" : "slider.horizontal.below.rectangle")
                        .font(.system(size: 25))
                        .foregroundStyle(.white)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)
        }
        .padding(.top, 45)
        .padding(.trailing, 25)
    }
}

struct SettingsButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            ZStack {
                Color.black.opacity(0.25)
                
                Button(action: {
                    print("SettingsButton toggle")
                    self.action()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 25))
                        .foregroundStyle(.white)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)

            Spacer()
        }
        .padding(.top, 45)
        .padding(.leading, 25)
    }
}

struct ControlButtonBar: View {
    @EnvironmentObject var placmentSettings: PlacementSettings
    @Binding var isControlVisibility: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @ObservedObject var models: Models

    var body: some View {
        HStack {
            MostRecentlyPlacedButton().hidden(self.placmentSettings.recentlyPlaced.isEmpty)

            Spacer()
            
            ControlButton(systemIconName: "square.grid.2x2") {
                print("browse button pressed")
                self.showBrowse.toggle()
            }.sheet(isPresented: $showBrowse, content: {
                BrowseView(showBrowse: $showBrowse, models: models)
            })
            
            Spacer()

            ControlVisabilityButton(isControlVisibility: $isControlVisibility) {
                self.isControlVisibility.toggle()
            }
            
        }
        .frame(maxWidth: 500)
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}

struct ControlVisabilityButton: View {
    @Binding var isControlVisibility: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: self.isControlVisibility ? "rectangle" : "slider.horizontal.below.rectangle")
                .font(.system(size: 35))
                .foregroundStyle(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
    }
}

struct ControlButton: View {
    let systemIconName: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size: 35))
                .foregroundStyle(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
    }
}

struct MostRecentlyPlacedButton: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    var body: some View {
        Button(action: {
            print("MostRecentlyPlacedButton tapped")
            self.placementSettings.selectedModel = self.placementSettings.recentlyPlaced.last
        }) {
            if let mostRecentlyPlacedModel = self.placementSettings.recentlyPlaced.last {
                Image(uiImage: mostRecentlyPlacedModel.thumbnail)
                    .resizable()
                    .frame(width: 46)
                    .aspectRatio(1/1, contentMode: .fit)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .background(Color.white)
        .cornerRadius(8.0)
    }
}
