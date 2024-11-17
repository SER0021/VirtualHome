//
//  MainView.swift
//  VirtualHome
//
//  Created by Nisu on 17.11.2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var models: Models
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
                MainButtonView(imageName: "Icon.AddModel", text: "Добавить\n3D модель")
                MainButtonView(imageName: "Icon.VirtualHome", text: "VirtualHome")
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
                HStack(spacing: 16) { // Используйте HStack для горизонтального расположения
                    ForEach(models.all, id: \.id) { model in
                        ModelView(model: model)
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .background(Color("AccentColor"))
    }
}

struct MainButtonView: View {
    let imageName: String
    let text: String
    var body: some View {
        Button(action: {
            print("fkfkf")
        }) {
            VStack(alignment: .leading, spacing: 0) {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.top)
                    .padding(.horizontal)
                Spacer()
                Text(text)
                    .font(.system(size: 24, weight: .semibold))
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .foregroundColor(Color("MainTextColor"))
            .frame(width: 175.0, height: 175.0)
            .background(Color("FrameColor"))
            .cornerRadius(30)
        }
    }
    
}

struct ModelView: View {
    var model: Model
    var body: some View {
        Button(action: {
            print("fdfd")
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

#Preview {
    MainView(models: Models())
}
