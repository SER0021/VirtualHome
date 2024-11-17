//
//  Model.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import UIKit
import SwiftUI
import RealityKit
import Combine
import ObjectiveC.runtime

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

// Реализация вашего Model
class Model: Identifiable {
    var name: String
    var category: ModelCategory
    var thumbnail: UIImage
    var modelEntity: ModelEntity?
    var scaleCompensation: Float
    private var cancellable: AnyCancellable?

    init(name: String, category: ModelCategory, scaleCompensation: Float, modelEntity: ModelEntity? = nil) {
        self.name = name
        self.category = category
        self.thumbnail = UIImage(named: name) ?? UIImage(systemName: "photo")!
        self.scaleCompensation = scaleCompensation
        self.modelEntity = modelEntity
    }
    
    init(name: String, category: ModelCategory, thumbnail: UIImage, scaleCompensation: Float, modelEntity: ModelEntity? = nil) {
        self.name = name
        self.category = category
        self.thumbnail = thumbnail
        self.scaleCompensation = scaleCompensation
        self.modelEntity = modelEntity
    }
    
    func updateHeight(_ height: Float) {
        modelEntity?.position.y = height
        print("Updated Model Y-Position: \(String(describing: modelEntity?.position.y))")
     }
    
    func asyncLoadModelEntity() {
        guard modelEntity == nil else { return }
        
        let filename = self.name + ".usdz"
        
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                switch loadCompletion {
                case .failure(let error): print("Unable to load modelEntity for \(filename). Error: \(error.localizedDescription)")
                case .finished: break
                }
            }, receiveValue: { [weak self] modelEntity in
                guard let self = self else { return }
                self.modelEntity = modelEntity
                self.modelEntity?.scale *= self.scaleCompensation
                print("modelEntity for \(self.name) has been loaded")
                // Использование жестов должны быть добавлено в makeUIView() вашего ARViewContainer
            })
    }
    
    func getName() -> String {
        self.name.prefix(1).uppercased() + self.name.dropFirst()
    }
}

class Models: ObservableObject {
    @Published var all: [Model] = []
    
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
    
    func printAllModels(category: ModelCategory) {
        print(all.count)
    }

    func addModel(name: String, category: ModelCategory, data: Data, scaleCompensation: Float, image: UIImage) {
        // Создаем временный файл
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).usdz")
        do {
            // Записываем данные в файл
            try data.write(to: tempURL)
            print("Data written to \(tempURL.path)")

            // Создаём асинхронную задачу для загрузки модели
            Task {
                do {
                    // Асинхронная загрузка модели из файла
                    let modelEntity = try await ModelEntity.loadModel(contentsOf: tempURL)
                    let newModel = Model(name: name, category: category, thumbnail: image, scaleCompensation: scaleCompensation, modelEntity: modelEntity)
                    
                    all.append(newModel)
                    
                    print("Model \(name) added successfully.")
                    NotificationCenter.default.post(name: .end3DModelAdded, object: nil)
                    
                    // Удаляем временный файл после использования
//                    try FileManager.default.removeItem(at: tempURL)
                } catch {
                    print("Failed to load model: \(error.localizedDescription)")
                }
            }
            
        } catch {
            print("Failed to create and write temporary usdz file. Error: \(error.localizedDescription)")
        }
    }

    
    func data(fromHexString hexString: String) -> Data? {
        var data = Data()
        var hexSanitized = hexString
        // Если строка начинается с 0x, удалим ее
        if hexSanitized.hasPrefix("0x") {
            hexSanitized.removeFirst(2)
        }

        // Повторяем для каждой пары символов
        var index = hexSanitized.startIndex
        while index < hexSanitized.endIndex {
            let nextIndex = hexSanitized.index(index, offsetBy: 2)
            let bytes = hexSanitized[index..<nextIndex]
            if let byte = UInt8(bytes, radix: 16) {
                data.append(byte)
            } else {
                return nil // Возврат nil, если какие-то символы не удалось преобразовать
            }
            index = nextIndex
        }
        return data
    }

    // Обновляем вашу функцию handleResponse
    func handleResponse(_ response: ScriptResponse, imageName: String, category: ModelCategory) {
        let modelData = data(fromHexString: response.meshData.data)
        let image = response.decodedImage() ?? UIImage(systemName: "photo")!
        addModel(name: imageName, category: category, data: modelData!, scaleCompensation: 0.5, image: image)
    }
    
    func removeModel(name: String) {
        all.removeAll { $0.name == name }
        print("Model \(name) removed.")
    }
}

extension ModelEntity {
    private struct AssociatedKeys {
        static var model: UInt8 = 0  // Используем безопасное адресное место типа UInt8
    }
    
    var linkedModel: Model? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.model) as? Model
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.model, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

