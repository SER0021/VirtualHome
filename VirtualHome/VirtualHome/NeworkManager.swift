import Foundation
import UIKit

class PhotoUploader: NSObject {
    private let serverURL: URL
    private var session: URLSession!
    private var fileName: String? = nil

    init(serverURL: URL) {
        self.serverURL = serverURL
        super.init()
        
        // Создание URLSession с делегатом для обработки сертификата
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30.0 // 30 секунд
        config.timeoutIntervalForResource = 60.0 // 60 секунд
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }
    
    func uploadPhoto(_ photo: UIImage, completion: @escaping (Result<(Data, String), Error>) -> Void) {
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
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName!)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
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
            
            completion(.success((data, self.fileName!)))
        }
        
        task.resume()
    }
    
}

// Расширение для поддержки SSL Pinning
extension PhotoUploader: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust,
           let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            
            // Путь к сертификату в проекте
            let localCertPath = Bundle.main.path(forResource: "sertificate", ofType: "pem")!
            let localCertData = try! Data(contentsOf: URL(fileURLWithPath: localCertPath))
            
            // Получение данных сертификата сервера
            let serverCertData = SecCertificateCopyData(certificate) as Data
            
            if localCertData == serverCertData {
                // Если сертификат совпадает, доверяем соединению
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
            } else {
                // Если не совпадает, отменяем соединение
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            // Если не удается проверить сертификат, отклоняем запрос
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

class PostScriptRunner {
    private let serverURL: URL

    init(serverURL: URL) {
        self.serverURL = serverURL
    }
    
    func runScript(with filename: String, completion: @escaping (Result<ScriptResponse, Error>) -> Void) {
        // Создаем URLRequest
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Настраиваем JSON данных
        let json: [String: Any] = ["filename": filename]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            completion(.failure(NSError(domain: "PostScriptRunner", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encode JSON."])))
            return
        }
        
        request.httpBody = jsonData
        
        // Выполняем запрос
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "PostScriptRunner", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed HTTP response."])))
                return
            }
            
            // Проверяем данные ответа
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let scriptResponse = try decoder.decode(ScriptResponse.self, from: data)
                    completion(.success(scriptResponse))
                } catch {
                    completion(.failure(NSError(domain: "PostScriptRunner", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode response."])))
                }
            } else {
                completion(.failure(NSError(domain: "PostScriptRunner", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data in response."])))
            }
        }
        
        task.resume()
    }
}

