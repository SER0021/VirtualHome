//
//  File.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 05.11.2024.
//

import Foundation
import UIKit

// Вложенная структура для 'mesh_data'
struct MeshData: Codable {
    let id: Int
    let name: String
    let uploadTime: String
    let data: String

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case uploadTime = "upload_time"
        case data
    }
}

// Обновленная структура 'ScriptResponse'
struct ScriptResponse: Codable {
    let meshData: MeshData
    let photoBase64: String

    enum CodingKeys: String, CodingKey {
        case meshData = "mesh_data"
        case photoBase64 = "photo_base64"
    }

    // Метод для декодирования изображения из Base64
    func decodedImage() -> UIImage? {
        guard let imageData = Data(base64Encoded: photoBase64) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}
