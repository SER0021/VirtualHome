//
//  RegestrationView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 11.11.2024.
//
import Foundation
import SwiftUI

struct RegistrationView: View {
    @State var email: String = ""
    @State var login: String = ""
    @State var password: String = ""
    @State var repeatPassword: String = ""
    @Environment(\.presentationMode) var presentationMode

    let darkGrayColor = Color(red: 41/255, green: 41/255, blue: 41/255, opacity: 1)
    let placeholderColor = Color(red: 133/255, green: 133/255, blue: 133/255, opacity: 1)
    let whiteColor = Color.white
    let darkWhiteColor = Color(red: 218/255, green: 218/255, blue: 218/255, opacity: 1)
    
    var body: some View {
        ZStack {
            // Обработчик нажатий на пустую область
            Color("AccentColor")
                .ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.hideKeyboard()
                }
            
            VStack {
                Spacer()
                HStack {
                    Text("Регистрация")
                        .font(.system(size: 40))
                        .bold()
                        .foregroundStyle(darkWhiteColor)
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.bottom, 50)
                
                VStack(spacing: 0) {
                    TextField("", text: $email, prompt: Text("Почта").foregroundStyle(placeholderColor))
                        .padding()
                        .foregroundStyle(whiteColor)
                    
                    Divider()
                        .background(Color.white)
                    
                    TextField("", text: $login, prompt: Text("Логин").foregroundStyle(placeholderColor))
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
                
                VStack(spacing: 0) {
                    SecureField("", text: $password, prompt: Text("Пароль").foregroundStyle(placeholderColor))
                        .padding()
                        .foregroundStyle(whiteColor)
                    
                    Divider()
                        .background(Color.white)
                    
                    SecureField("", text: $repeatPassword, prompt: Text("Повторный пароль").foregroundStyle(placeholderColor))
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

                Spacer()
                
                VStack {
                    Button(action: {
                        print("Регистрация")
                        presentationMode.wrappedValue.dismiss()
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
                .padding(.bottom, 30)
            }
        }
    }
}


