//
//  SessionSettings.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI

class SessionSettings: ObservableObject {
    @Published var isPeopleOcclussionEnabled: Bool = false
    @Published var isObjectOcclussionEnabled: Bool = false
    @Published var isLidarDebugEnabled: Bool = false
    @Published var isMultiuserEnabled: Bool = false
}
