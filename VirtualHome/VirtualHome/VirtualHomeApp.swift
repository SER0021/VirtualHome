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
//    @State var showLoadingSpinner: Bool = false
    var models = Models()

    var body: some Scene {
        WindowGroup {
//            ContentView(models: models, showLoadingSpinner: $showLoadingSpinner)
//                .environmentObject(placementSettings)
//                .environmentObject(sessionSettings)
            AuthenticationView()
//            RegistrationView()
        }
    }
}
