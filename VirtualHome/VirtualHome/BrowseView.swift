//
//  BrowseView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 12.10.2024.
//

import SwiftUI

struct BrowseView: View {
    @Binding var showBrowse: Bool
    @ObservedObject var models: Models

    var body: some View {
        NavigationView{
            ScrollView(showsIndicators: false) {
                RecentGrid(showBrowse: $showBrowse)
                ModelsByCategoryGrid(showBrowse: $showBrowse, models: models)
            }
            .navigationTitle(Text("Browse"))
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button(action: {
                self.showBrowse.toggle()
            }) {
                Text("Done").bold()
            })
        }
    }
}

struct RecentGrid: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool

    var body: some View {
        if !self.placementSettings.recentlyPlaced.isEmpty {
            HorizontalGrid(showBrowse: $showBrowse, title: "Recents", items: getRecentsUniqueOrder())
        }
    }
    
    func getRecentsUniqueOrder() -> [Model] {
        var recentUniqueOrderedArray: [Model] = []
        var modelNameSet: Set<String> = []
        
        for model in self.placementSettings.recentlyPlaced.reversed() {
            if !modelNameSet.contains(model.name) {
                recentUniqueOrderedArray.append(model)
                modelNameSet.insert(model.name)
            }
        }
        
        return recentUniqueOrderedArray
    }
}

struct ModelsByCategoryGrid: View {
    @Binding var showBrowse: Bool
    @ObservedObject var models: Models

    var body: some View {
        VStack {
            ForEach(ModelCategory.allCases, id: \.self) { category in
                let modelsByCategory = models.get(category: category)
                let _ = models.printAllModels(category: .decor)
                HorizontalGrid(showBrowse: $showBrowse, title: category.label, items: modelsByCategory)
            }
        }
    }
}

struct HorizontalGrid: View {
    @EnvironmentObject var placementSettings: PlacementSettings
    @Binding var showBrowse: Bool
    var title: String
    var items: [Model]
    private let gridItemLayout = [GridItem(.fixed(150))]

    var body: some View {
        VStack(alignment: .leading) {
            Separator()

            Text(title)
                .font(.title2).bold()
                .padding(.leading, 22)
                .padding(.top, 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: gridItemLayout, spacing: 30) {
                    ForEach(0..<items.count) { index in
                        let model = items[index]

                        ItemButton(model: model) {
                            model.asyncLoadModelEntity()
                            self.placementSettings.selectedModel = model
                            print("item pressed \(model.name)")
                            self.showBrowse = false
                        }
                    }
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
            }
        }
    }
}


struct ItemButton: View {
    let model: Model
    let action: () -> Void

    var body: some View {
        Button(action: {
            self.action()
        }) {
            VStack {
                Image(uiImage: self.model.thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .background(Color(UIColor.secondarySystemFill))
                    .frame(height: 150)
                    .cornerRadius(8.0)
                
                Text(self.model.getName())
                    .bold()
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Separator: View {
    var body: some View {
        Divider()
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}
