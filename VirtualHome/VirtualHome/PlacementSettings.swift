//
//  PlacementSettings.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI
import RealityKit
import Combine

class PlacementSettings: ObservableObject {
    @Published var selectedModel: Model? {
        willSet(newValue) {
            print("setting selectedModel to \(String(describing: newValue?.name))")
        }
    }

    @Published var confirmedModel: Model? {
        willSet(newValue) {
            guard let model = newValue else {
                print("clearing confirmed")
                return
            }

            print("setting confirmedModel to \(model.name)")
            self.recentlyPlaced.append(model)
        }
    }
    
    @Published var recentlyPlaced: [Model] = []
    
    var sceneObserver: Cancellable?
}
