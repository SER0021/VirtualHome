//
//  MainView.swift
//  VirtualHome
//
//  Created by Nisu on 17.11.2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var models: Models
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @State var showCreateView: Bool = false
    @State var showContentView: Bool = false
    @State var showLoadingSpinner: Bool = false
    @State var showProfileView: Bool = false
    @State private var showOnboarding: Bool = true
    @State private var isLoadingModel: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack{
                HStack{
                    Image("Icon.VirtualHome")
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text("Home")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("MainTextColor"))
                        .multilineTextAlignment(.leading)
                }
                .padding(8)
                .cornerRadius(16)
                .padding(.leading, 16)

                Spacer()
                Button(action: {
                    print("profile")
                    showProfileView.toggle()
                }) {
                    HStack(spacing: 8) {
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("Имя")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color("MainTextColor"))
                                .multilineTextAlignment(.trailing)
                            Text("@nickname")
                                .font(.system(size: 14))
                                .foregroundColor(Color("SubTextColor"))
                        }
                        Image("Icon.DefaultProfileIcon")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    .padding(8)
                    .background(Color("FrameColor"))
                    .cornerRadius(16)
                    .padding(.trailing, 16)
                }
                .fullScreenCover(isPresented: $showProfileView) {
                    ProfileChangeView()
                }
            }
            HStack(spacing: 11) {
                OpenCreateViewButton(imageName: "Icon.AddModel", text: "Добавить\n3D модель", models: models, showCreateView: $showCreateView, showLoadingSpinner: $showLoadingSpinner)
                OpenContentViewButton(imageName: "Icon.ARView", text: "Примерить\nмодель", models: models, showContentView: $showContentView, showLoadingSpinner: $showLoadingSpinner)
            }
            .padding(.horizontal, 16)
            
            Button(action: {
            }) {
                HStack(alignment: .center, spacing: 0) {
                    Image("Icon.Catalog")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding([.top, .leading, .bottom], 20)
                    Text("Каталог")
                        .font(.system(size: 24, weight: .semibold))
                        .padding([.top, .trailing, .bottom], 20)
                        .padding(.leading, 11)
                }
                .foregroundColor(Color("MainTextColor"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color("FrameColor"))
                .cornerRadius(30)
            }
            .padding(.horizontal, 16)
            
            Text("Недавние 3D модели")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(Color("MainTextColor"))
                .padding(.leading, 16)
                .padding(.top, 30)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // Заглушка для модели
                    if isLoadingModel {
                        LoadingModelView()
                            .transition(.opacity) // Анимация появления/исчезновения
                    }
                    
                    // Существующие модели
                    ForEach(models.all, id: \.id) { model in
                        ModelView(model: model)
                    }
                }
                .padding()
            }


//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ForEach(models.all, id: \.id) { model in
//                        ModelView(model: model)
//                    }
//                }
//                .padding()
//            }
            
            Spacer()
        }
        .background(Color("AccentColor"))
        .onReceive(NotificationCenter.default.publisher(for: .start3DModelAdded)) { _ in
            showLoadingSpinner = true
            isLoadingModel = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .end3DModelAdded)) { _ in
            showLoadingSpinner = false
            isLoadingModel = false
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
                .onDisappear {
                    // Сохраняем состояние после закрытия OnboardingView
//                    UserDefaults.standard.set(true, forKey: "DidShowOnboarding")
                }
        }
    }
}

struct OpenCreateViewButton: View {
    let imageName: String
    let text: String
    @ObservedObject var models: Models
    @Binding var showCreateView: Bool
    @Binding var showLoadingSpinner: Bool
    @State private var isLoading: Bool = false // Флаг загрузки

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("MainTextColor")))
                        .frame(width: 50, height: 50)
                        .padding(.top)
                        .padding(.horizontal)
                } else {
                    Image(imageName)
                        .resizable()
                        .frame(width: 55, height: 50)
                        .padding(.top)
                        .padding(.horizontal)
                }
                Spacer()
                Text(text)
                    .font(.system(size: 24, weight: .semibold))
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(Color("MainTextColor"))
            .frame(width: 175.0, height: 175.0)
            .background(isLoading ? Color("FrameColor").opacity(0.5) : Color("FrameColor"))
            .cornerRadius(30)
        }
        .onChange(of: showCreateView) { newValue in
            // Если showContentView становится true, показываем спиннер
            if newValue {
                isLoading = true
            } else {
                isLoading = false // Скрываем спиннер, если закрывается ContentView
            }
        }
        .disabled(isLoading) // Блокируем кнопку во время загрузки
        .onTapGesture {
            if !isLoading {
                showCreateView = true
            }
        }
        .fullScreenCover(isPresented: $showCreateView, onDismiss: {
            // Убираем спиннер при закрытии ContentView
            isLoading = false
        }) {
            CreateView(models: models)
        }
    }
}

struct OpenContentViewButton: View {
    let imageName: String
    let text: String
    @ObservedObject var models: Models
    @Binding var showContentView: Bool
    @EnvironmentObject var placementSettings: PlacementSettings
    @EnvironmentObject var sessionSettings: SessionSettings
    @State private var isLoading: Bool = false // Флаг загрузки
    @Binding var showLoadingSpinner: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("MainTextColor")))
                        .frame(width: 50, height: 50)
                        .padding(.top)
                        .padding(.horizontal)
                } else {
                    Image(imageName)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.top)
                        .padding(.horizontal)
                }
                Spacer()
                Text(text)
                    .font(.system(size: 24, weight: .semibold))
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(Color("MainTextColor"))
            .frame(width: 175.0, height: 175.0)
            .background(isLoading ? Color("FrameColor").opacity(0.5) : Color("FrameColor"))
            .cornerRadius(30)
        }
        .onChange(of: showContentView) { newValue in
            // Если showContentView становится true, показываем спиннер
            if newValue {
                isLoading = true
            } else {
                isLoading = false // Скрываем спиннер, если закрывается ContentView
            }
        }
        .disabled(isLoading) // Блокируем кнопку во время загрузки
        .onTapGesture {
            if !isLoading {
                showContentView = true
            }
        }
        .fullScreenCover(isPresented: $showContentView, onDismiss: {
            // Убираем спиннер при закрытии ContentView
            isLoading = false
        }) {
            ContentView(models: models, showLoadingSpinner: $showLoadingSpinner)
                .environmentObject(placementSettings)
                .environmentObject(sessionSettings)
        }
    }
}

struct ModelView: View {
    @State var showModelView: Bool = false
    var model: Model
    var body: some View {
        Button(action: {
            print(model.getName())
            showModelView.toggle()
        }) {
            VStack {
                Image(uiImage: model.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .cornerRadius(8.0)
                
                Text(model.getName())
                    .bold()
                    .padding(.top, 5)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(Color("MainTextColor"))
        .frame(width: 150.0, height: 150.0)
        .background(Color("FrameColor"))
        .cornerRadius(30)
        .fullScreenCover(isPresented: $showModelView) {
            ModelDetailsView(model: model)
        }
    }
}

struct LoadingModelView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("MainTextColor")))
                .frame(width: 100, height: 100)
            
            Text("Загрузка...")
                .foregroundColor(Color("SubTextColor"))
                .font(.system(size: 14))
                .padding(.top, 5)
        }
        .frame(width: 150.0, height: 150.0)
        .background(Color("FrameColor").opacity(0.5))
        .cornerRadius(30)
    }
}

