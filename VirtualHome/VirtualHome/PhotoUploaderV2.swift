//
//  PhotoUploaderV2.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 03.12.2024.
//

import UIKit

// Структура модели для ответа, содержащая 'MeshData'
struct PhotoResponseModel: Codable {
    let meshData: MeshData
    
    enum CodingKeys: String, CodingKey {
        case meshData = "mesh_data"
    }
}

class PhotoUploaderV2: NSObject {
    private let serverURL: URL
    private var session: URLSession!
    private var fileName: String? = nil

    init(serverURL: URL) {
        self.serverURL = serverURL
        super.init()
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300.0
        config.timeoutIntervalForResource = 300.0
        self.session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
    }
    
    func uploadPhoto(_ photo: UIImage, completion: @escaping (Result<PhotoResponseModel, Error>) -> Void) {
        guard let imageData = photo.jpegData(compressionQuality: 1) else {
            completion(.failure(NSError(domain: "PhotoUploader", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to convert image to JPEG data."])))
            return
        }
        
        let uuid = UUID().uuidString
        fileName = "image_\(uuid).jpg"
        
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName!)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: file/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "PhotoUploader", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server."])))
                return
            }
            
            // Выводим тело ответа сервера для проверки его содержания
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Data: \(responseString)")
            }
            
            do {
                let responseModel = try JSONDecoder().decode(PhotoResponseModel.self, from: data)
                completion(.success(responseModel))
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        
//        let task = session.dataTask(with: request) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            guard let data = data else {
//                completion(.failure(NSError(domain: "PhotoUploader", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received from server."])))
//                return
//            }
//            
//            do {
//                let responseModel = try JSONDecoder().decode(MeshData.self, from: data)
//                completion(.success(responseModel))
//            } catch {
//                completion(.failure(error))
//            }
//        }
        
        task.resume()
    }
}
