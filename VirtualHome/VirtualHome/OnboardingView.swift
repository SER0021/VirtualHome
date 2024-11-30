import SwiftUI

struct OnboardingView: View {
    // Массив изображений
    private let images = ["Onboarding.first", "Onboarding.second", "Onboarding.third", "Onboarding.fourth"]
    @State private var currentIndex = 0
    @Environment(\.presentationMode) var presentationMode
    @Binding var showOnboarding: Bool

    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(.all)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.5), value: currentIndex)

            VStack {
                Spacer()

                VStack {
                    HStack(spacing: 10) {
                        // Кнопка 'Назад'
                        if currentIndex > 0 {
                            Button(action: {
                                withAnimation {
                                    currentIndex -= 1
                                }
                            }) {
                                Text("Назад")
                                    .font(.system(size: 24, weight: .semibold))
                                    .frame(width: 150, height: 20)
                                    .padding()
                                    .foregroundColor(Color("MainTextColor"))
                                    .background(Color("FrameColor"))
                                    .cornerRadius(16)
                            }
                        }

                        // Кнопка 'Далее'
                        Button(action: {
                            if currentIndex == images.count - 1 {
                                withAnimation {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            if currentIndex < images.count - 1 {
                                withAnimation {
                                    currentIndex += 1
                                }
                            }
                        }) {
                            Text("Далее")
                                .font(.system(size: 24, weight: .semibold))
                                .frame(width: currentIndex == 0 ? 300 : 150, height: 20)
                                .padding()
                                .foregroundColor(Color("MainTextColor"))
                                .background(Color.orange)
                                .cornerRadius(16)
                        }
                    }

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Пропустить обучение")
                            .font(.system(size: 18, weight: .regular))
                            .padding(.top, 10)
                            .foregroundColor(Color("MainTextColor"))
                    }

                    // Индикатор страниц
                    HStack(spacing: 8) {
                        ForEach(0..<images.count, id: \.self) { index in
                            Circle()
                                .frame(width: 10, height: 10)
                                .foregroundColor(currentIndex == index ? .orange : .gray)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 25)
                }
            }
        }
        .ignoresSafeArea(.all)
    }
}
