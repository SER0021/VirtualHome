//
//  VirtualHomeApp.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI

@main
struct VirtualHomeApp: App {
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sessionSettings = SessionSettings()
    var models = Models()

    var body: some Scene {
        WindowGroup {
//            ContentView(models: models)
//                .environmentObject(placementSettings)
//                .environmentObject(sessionSettings)
            AuthenticationView()
//            RegistrationView()
        }
    }
}
