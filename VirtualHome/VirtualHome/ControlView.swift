//
//  ControlView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI

struct ControlView: View {
    @ObservedObject var models: Models
    @Binding var isControlVisibility: Bool
    @Binding var showCreateView: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool

    var body: some View {
        VStack {
            HStack {
                SettingsButton() {
                    print("settings button pressed")
                    self.showSettings.toggle()
                }.sheet(isPresented: $showSettings) {
                    SettingsView(showSettings: $showSettings)
                }
                
                Spacer()
                
                ControlVisibilityToggleButton(isControlVisibility: $isControlVisibility)
            }
            
            Spacer()
            
            if isControlVisibility {
                ControlButtonBar(showCreateView: $showCreateView, showBrowse: $showBrowse, showSettings: $showSettings, models: models)
            }
        }
    }
}

struct ControlVisibilityToggleButton: View {
    @Binding var isControlVisibility: Bool

    var body: some View {
        HStack {
            Spacer()
            ZStack {
                Color.black.opacity(0.25)
                
                Button(action: {
                    print("Control visibility toggle")
                    self.isControlVisibility.toggle()
                }) {
                    Image(systemName: self.isControlVisibility ? "rectangle" : "slider.horizontal.below.rectangle")
                        .font(.system(size: 25))
                        .foregroundStyle(.white)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)
        }
        .padding(.top, 45)
        .padding(.trailing, 25)
    }
}

struct SettingsButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            ZStack {
                Color.black.opacity(0.25)
                
                Button(action: {
                    print("SettingsButton toggle")
                    self.action()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 25))
                        .foregroundStyle(.white)
                        .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8.0)

            Spacer()
        }
        .padding(.top, 45)
        .padding(.leading, 25)
    }
}

struct ControlButtonBar: View {
    @EnvironmentObject var placmentSettings: PlacementSettings
    @Binding var showCreateView: Bool
    @Binding var showBrowse: Bool
    @Binding var showSettings: Bool
    @ObservedObject var models: Models

    var body: some View {
        HStack {
            MostRecentlyPlacedButton().hidden(self.placmentSettings.recentlyPlaced.isEmpty)

            Spacer()
            
            ControlButton(systemIconName: "plus.circle") {
                print("browse button pressed")
                self.showCreateView.toggle()
            }.fullScreenCover(isPresented: $showCreateView, content: {
                CreateView(models: models)
            })

            Spacer()

            ControlButton(systemIconName: "square.grid.2x2") {
                print("browse button pressed")
                self.showBrowse.toggle()
            }.sheet(isPresented: $showBrowse, content: {
                BrowseView(showBrowse: $showBrowse, models: models)
            })
        }
        .frame(maxWidth: 500)
        .padding(30)
        .background(Color.black.opacity(0.25))
    }
}

struct ControlButton: View {
    let systemIconName: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            Image(systemName: systemIconName)
                .font(.system(size: 35))
                .foregroundStyle(.white)
                .buttonStyle(PlainButtonStyle())
        }
        .frame(width: 50, height: 50)
    }
}

struct MostRecentlyPlacedButton: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    var body: some View {
        Button(action: {
            print("MostRecentlyPlacedButton tapped")
            self.placementSettings.selectedModel = self.placementSettings.recentlyPlaced.last
        }) {
            if let mostRecentlyPlacedModel = self.placementSettings.recentlyPlaced.last {
                Image(uiImage: mostRecentlyPlacedModel.thumbnail)
                    .resizable()
                    .frame(width: 46)
                    .aspectRatio(1/1, contentMode: .fit)
            } else {
                Image(systemName: "clock.fill")
                    .font(.system(size: 35))
                    .foregroundStyle(.white)
                    .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: 50, height: 50)
        .background(Color.white)
        .cornerRadius(8.0)
    }
}
