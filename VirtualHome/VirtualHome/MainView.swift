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
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack{
                Spacer()
                Button(action: {
                    print("profile")
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
            }
            HStack(spacing: 11) {
                OpenCreateViewButton(imageName: "Icon.AddModel", text: "Добавить\n3D модель", models: models, showCreateView: $showCreateView, showLoadingSpinner: $showLoadingSpinner)
                OpenContentViewButton(imageName: "Icon.VirtualHome", text: "Создать интерьер", models: models, showContentView: $showContentView, showLoadingSpinner: $showLoadingSpinner)
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
                    ForEach(models.all, id: \.id) { model in
                        ModelView(model: model)
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .background(Color("AccentColor"))
        .onReceive(NotificationCenter.default.publisher(for: .start3DModelAdded)) { _ in
            showLoadingSpinner = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .end3DModelAdded)) { _ in
            showLoadingSpinner = false
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
    var model: Model
    var body: some View {
        Button(action: {
            print(model.getName())
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
    }
}

struct ModelDetailsView: View {
    @State var model: Model
    @Environment(\.presentationMode) var presentationMode
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(uiImage: model.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: .infinity)

                Text(model.getName())
                    .font(.largeTitle)
                    .bold()

                Text("Категория: \(model.category.label)")
                    .font(.headline)

                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Удалить модель")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .alert(isPresented: $showDeleteAlert) {
                    Alert(
                        title: Text("Удаление модели"),
                        message: Text("Вы действительно хотите удалить модель?"),
                        primaryButton: .destructive(Text("Удалить")) {
                            presentationMode.wrappedValue.dismiss()
                        },
                        secondaryButton: .cancel(Text("Отменить"))
                    )
                }
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("< Назад") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color("AccentColor"))
            .foregroundColor(Color("MainTextColor"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ModelDetailsView(model: Models().all[0])
}
