//
//  File.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 05.11.2024.
//

import Foundation

struct ScriptResponse: Decodable {
    let id: Int
    let name: String
    let uploadTime: String
    let data: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case uploadTime = "upload_time"
        case data
    }
}
