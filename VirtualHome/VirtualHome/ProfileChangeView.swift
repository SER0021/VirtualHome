//
//  ProfileChangeView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 11.12.2024.
//

import Foundation
import SwiftUI

struct ProfileChangeView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Фото профиля
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.top)

                Text("Изменить фотографию")
                    .font(.headline)
                    .foregroundColor(Color("MainTextColor"))

                // Поля ввода
                VStack(spacing: 10) {
                    TextField("", text: .constant(""), prompt: Text("Имя").foregroundStyle(Color.gray))
                        .padding()
                        .background(Color("FrameColor"))
                        .cornerRadius(10)
                        .foregroundColor(Color("MainTextColor"))

                    TextField("", text: .constant(""), prompt: Text("Фамилия").foregroundStyle(Color.gray))
                        .padding()
                        .background(Color("FrameColor"))
                        .cornerRadius(10)
                        .foregroundColor(Color("MainTextColor"))
                }
                .padding(.horizontal)

                // Кнопки для действий
                VStack {
                    HStack {
                        Text("Сменить почту")
                            .foregroundColor(Color("MainTextColor"))
                        Spacer()
                        Text("example@mail.ru")
                            .foregroundColor(Color("MainTextColor"))
                    }
                    .padding()
                    .background(Color("FrameColor"))
                    .cornerRadius(10)

                    HStack {
                        Text("Сменить пароль")
                            .foregroundColor(Color("MainTextColor"))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color("FrameColor"))
                    .cornerRadius(10)

                    HStack {
                        Text("Имя пользователя")
                            .foregroundColor(Color("MainTextColor"))
                        Spacer()
                        Text("@nickname")
                    }
                    .padding()
                    .background(Color("FrameColor"))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    print("Вышли из аккаунта")
                }) {
                    Text("Выйти из аккаунта")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("FrameColor"))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Назад") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Готово") {
                print("Сохранение изменений")
            })
            .foregroundColor(Color("MainTextColor"))
            .background(Color("AccentColor").ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
