//
//  PlacementView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI

struct PlacementView: View {
    @EnvironmentObject var placementSettings: PlacementSettings

    var body: some View {
        HStack {
            Spacer()

            PlacementButton(systemIconName: "xmark.circle.fill") {
                print("cancel placment button pressed")

                self.placementSettings.selectedModel = nil
            }

            Spacer()
            
            PlacementButton(systemIconName: "checkmark.circle.fill") {
                print("confirm placment button pressed")

                self.placementSettings.confirmedModel = self.placementSettings.selectedModel
                self.placementSettings.selectedModel = nil
            }
            
            Spacer()
        }
        .padding(.bottom, 30)
    }
}
    

struct PlacementButton: View {
    let systemIconName: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size: 50, weight: .light, design: .default))
                .foregroundStyle(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 75, height: 75)
    }
}
