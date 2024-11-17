//
//  MainView.swift
//  VirtualHome
//
//  Created by Nisu on 17.11.2024.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Spacer()
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
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
                .padding(.trailing, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color("FrameColor"))
            .cornerRadius(30)
            
            
            HStack(spacing: 11) {
                Button(action: {
                }) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image("Icon.AddModel")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Добавить\n3D модель")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .foregroundColor(Color("MainTextColor"))
                    .frame(width: 175.0, height: 175.0)
                    .background(Color("FrameColor"))
                    .cornerRadius(30)
                }
                
                Button(action: {
                }) {
                    VStack(alignment: .leading, spacing: 0) {
                        Image("Icon.VirtualHome")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .padding([.top, .leading], 20)
                        Text("VirtualHome")
                            .font(.system(size: 24, weight: .semibold))
                            .padding([.bottom, .trailing, .leading], 20)
                    }
                    .frame(width: 175.0, height: 175.0)
                    .foregroundColor(Color("MainTextColor"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color("FrameColor"))
                    .cornerRadius(30)
                }
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
                        .font(.system(size: 32, weight: .semibold))
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
            
            ScrollView(.horizontal, showsIndicators: false) {
            }
            
            Spacer()
        }
        .background(Color("AccentColor"))
    }
}

#Preview {
    MainView()
}
