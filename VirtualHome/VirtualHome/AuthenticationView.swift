//
//  AuthenticationView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 11.11.2024.
//

import Foundation
import SwiftUI

struct AuthenticationView: View {
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    var models = Models()

    @State var login: String = ""
    @State var password: String = ""
    @State var showRegistrationView: Int? = 0
    @State var showContentView = false

    let darkGrayColor = Color(red: 41/255, green: 41/255, blue: 41/255, opacity: 1)
    let placeholderColor = Color(red: 133/255, green: 133/255, blue: 133/255, opacity: 1)
    let whiteColor = Color.white
    let darkWhiteColor = Color(red: 218/255, green: 218/255, blue: 218/255, opacity: 1)
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack{
                    Text("Авторизация")
                        .font(.system(size: 40, weight: .semibold)).foregroundColor(Color(#colorLiteral(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.bottom, 50)
                
                VStack(spacing: 0) {
                    TextField("", text: $login, prompt:Text("Почта").foregroundStyle(placeholderColor))
                        .padding()
                        .foregroundStyle(whiteColor)
                    
                    Divider()
                        .background(Color.white)
                    
                    SecureField("", text: $password, prompt: Text("Пароль").foregroundStyle(placeholderColor))
                        .padding()
                        .foregroundStyle(whiteColor)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(darkGrayColor)
                        .shadow(radius: 5)
                )
                .padding(.horizontal, 16)
                
                HStack{
                    Button(action: {
                        print("Забыли пароль?")
                    }) {
                        Text("Забыли пароль?")
                            .foregroundStyle(whiteColor)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 10)
                
                Spacer()
                
                VStack{
                    Button(action: {
                        print("войти")
                        showContentView.toggle()
                    }) {
                        Text("Войти")
                            .font(.system(size: 17))
                            .foregroundStyle(whiteColor)
                            .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(darkGrayColor)
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal, 16)
                    .fullScreenCover(isPresented: $showContentView, content: {
//                        ContentView(models: models)
//                            .environmentObject(placementSettings)
//                            .environmentObject(sessionSettings)
                        MainView(models: models)
                            .environmentObject(placementSettings)
                            .environmentObject(sessionSettings)
                    })
                    
                    NavigationLink(destination: RegistrationView(), tag: 1, selection: $showRegistrationView) {
                        Button(action: {
                            print("Регистрация")
                            showRegistrationView = 1
                        }) {
                            Text("Регистрация")
                                .font(.system(size: 17))
                                .foregroundStyle(darkGrayColor)
                                .padding()
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(darkWhiteColor)
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color.gray)
        }
    }
}


#Preview {
    AuthenticationView()
}
