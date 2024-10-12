//
//  Model.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI
import RealityKit
import Combine

enum ModelCategory: CaseIterable {
    case table
    case chair
    case decor
    case light
    
    var label: String {
        get {
            switch self {
            case .table:
                return "Tables"
            case .chair:
                return "Chairs"
            case .decor:
                return "Decors"
            case .light:
                return "Lights"
            }
        }
    }
}

class Model {
    var name: String
    var category: ModelCategory
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    
    private var cancalable: AnyCancellable?

    init(name: String, category: ModelCategory, scaleCompensation: Float) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
    }
    
    func asyncLoadModelEntity() {
        let filename = self.name + ".usdz"
        
        self.cancalable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                switch loadCompletion {
                case .failure(let error): print("Unable to load modelEntity for \(filename). Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { modelEntity in
                self.modelEntity = modelEntity
                self.modelEntity?.scale *= self.scaleCompensation
                
                print("modelEntity for \(self.name) has been loaded")
            })
    }
}

struct Models {
    var all: [Model] = []
    
    init() {
        let chair = Model(name: "chair", category: .chair, scaleCompensation: 0.5)
        let flower = Model(name: "flower", category: .decor, scaleCompensation: 0.5)
        let tv = Model(name: "tv", category: .decor, scaleCompensation: 0.5)
        let table = Model(name: "table", category: .table, scaleCompensation: 0.5)
        let lamp = Model(name: "lamp", category: .light, scaleCompensation: 0.5)
        
        self.all += [chair, flower, tv, table, lamp]
    }
    
    func get(category: ModelCategory) -> [Model] {
        return all.filter({$0.category == category})
    }
}
