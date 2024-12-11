//
//  ModelDetailsView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 11.12.2024.
//

import Foundation
import SwiftUI

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
            .navigationBarItems(leading: Button("Назад") {
                presentationMode.wrappedValue.dismiss()
            })
            .background(Color("AccentColor"))
            .foregroundColor(Color("MainTextColor"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
