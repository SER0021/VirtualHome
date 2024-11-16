//
//  SelectedModelView.swift
//  VirtualHome
//
//  Created by Сергей Васильев on 16.11.2024.
//

import SwiftUI
import RealityFoundation

struct SelectedModelView: View {
    @ObservedObject var models: Models
    @Binding var showSelectedModel: Bool
    @Binding var model: Model?
    @Binding var selectedModelAnchor: AnchorEntity?
    
    var body: some View {
        HStack {
            Image(uiImage: getImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50) // Пример размера изображения
                .padding(.leading)

            Spacer()

            VStack {
                Text(getName())
                    .font(.title)
                    .bold()
                Text(getCategory())
                    .font(.title3)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Button(action: {
                selectedModelAnchor?.removeFromParent()
                model = nil
                showSelectedModel = false
                selectedModelAnchor = nil
            }) {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                    .padding()
                    .foregroundStyle(.gray)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 80)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
    
    func getImage() -> UIImage {
        guard let image = model?.thumbnail else { return UIImage(systemName: "photo")! }
        return image
    }
    func getName() -> String {
        guard let name = model?.name else { return "" }
        return name
    }
    func getCategory() -> String {
        guard let category = model?.category.label else { return "" }
        return category
    }
}

struct ModelHeightControlView: View {
    @Binding var selectedModelAnchor: AnchorEntity?
    
    var body: some View {
        VerticalSlider(value: Binding(
            get: {
                selectedModelAnchor?.position.y ?? 0.0
            },
            set: { newValue in
                selectedModelAnchor?.position.y = newValue
            }
        ),  in: -1...1)
        .padding()
        .frame(height: 300)
    }
}

struct VerticalSlider<V>: View where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
    @Binding private var value: V
    private let bounds: ClosedRange<V>
    private let onEditingChanged: (Bool) -> Void
    private let sliderButtonSize: CGFloat = 27
    
    init(
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self._value = value
        self.bounds = bounds
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        Rectangle()
            .frame(width: sliderButtonSize)
            .frame(maxHeight: .infinity)
            .hidden()
            .overlay {
                GeometryReader { proxy in
                    Slider(value: $value, in: bounds, onEditingChanged: onEditingChanged)
                        .frame(width: proxy.size.height)
                        .rotationEffect(.degrees(-90))
                        .offset(
                            x: (proxy.size.width - proxy.size.height) / 2,
                            y: (proxy.size.height - proxy.size.width) / 2
                        )
                }
            }
    }
}
