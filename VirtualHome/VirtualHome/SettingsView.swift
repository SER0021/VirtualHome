//
//  SettingsView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI

enum Setting {
    case peopleOcclussion
    case objectOcclussion
    case lidarDebug
    case multiuser
    
    var label: String {
        get {
            switch self {
            case .peopleOcclussion, .objectOcclussion:
                return "Occlussion"
            case .lidarDebug:
                return "LiDAR"
            case .multiuser:
                return "Multiuser"
            }
        }
    }
    
    var systemIconName: String {
        get {
            switch self {
            case .peopleOcclussion:
                return "person"
            case .objectOcclussion:
                return "cube.box.fill"
            case .lidarDebug:
                return "light.min"
            case .multiuser:
                return "person.2"
            }
        }
    }
}

struct SettingsView: View {
    @Binding var showSettings: Bool
    var body: some View {
        NavigationView {
            SettingsGrid()
                .navigationBarTitle(Text("Settings"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.showSettings.toggle()
                }) {
                    Text("Done").bold()
                })
        }
    }
}

struct SettingsGrid: View {
    @EnvironmentObject var sessionSettings: SessionSettings
    
    private var gridItemLayout = [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 25)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridItemLayout, spacing: 25) {
                SettingsToggleButton(setting: .peopleOcclussion, isOn: $sessionSettings.isPeopleOcclussionEnabled)
                SettingsToggleButton(setting: .objectOcclussion, isOn: $sessionSettings.isObjectOcclussionEnabled)
                SettingsToggleButton(setting: .lidarDebug, isOn: $sessionSettings.isLidarDebugEnabled)
//                SettingsToggleButton(setting: .multiuser, isOn: $sessionSettings.isMultiuserEnabled)
            }
        }
        .padding(.top, 35)
    }
}


struct SettingsToggleButton: View {
    let setting: Setting
    @Binding var isOn: Bool
    var body: some View {
        Button(action: {
            self.isOn.toggle()
            print("\(#file) - \(setting): \(self.isOn)")
        }) {
            VStack {
                Image(systemName: setting.systemIconName)
                    .font(.system(size: 35))
                    .foregroundStyle(self.isOn ? .green : Color(UIColor.secondaryLabel))
                    .buttonStyle(PlainButtonStyle())
                
                Text(setting.label)
                    .font(.system(size: 17, weight: .medium, design: .default))
                    .foregroundStyle(self.isOn ? Color(UIColor.label) : Color(UIColor.secondaryLabel))
                    .padding(.top, 5)
            }
        }
        .frame(width: 100, height: 100)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20.0)
    }
}
