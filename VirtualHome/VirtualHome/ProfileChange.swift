import SwiftUI

struct ProfileChange: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Фото профиля
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.top)
                
                Text("Изменить фотографию")
                    .font(.headline)
                    .foregroundColor(Color("MainTextColor"))
                
                // Поля ввода
                VStack(spacing: 10) {
                    TextField("Имя", text: .constant(""))
                        .padding()
                        .background(Color("FrameColor"))
                        .cornerRadius(10)
                        .foregroundColor(Color("MainTextColor"))
                    
                    TextField("Фамилия", text: .constant(""))
                        .padding()
                        .background(Color("FrameColor"))
                        .cornerRadius(10)
                        .foregroundColor(Color("MainTextColor"))
                    
                    TextField("О себе", text: .constant(""))
                        .padding()
                        .background(Color("FrameColor"))
                        .cornerRadius(10)
                        .frame(height: 60) // Увеличение высоты
                        .foregroundColor(Color("MainTextColor"))
                }
                .padding(.horizontal)
                
                // Кнопки для действий
                VStack {
                    HStack {
                        Text("Сменить почту")
                            .foregroundColor(Color("MainTextColor"))
                        Spacer()
                        Text("example@mail.ru")
                            .foregroundColor(Color("MainTextColor"))
                    }
                    .padding()
                    .background(Color("FrameColor"))
                    .cornerRadius(10)
                    
                    HStack {
                        Text("Сменить пароль")
                            .foregroundColor(Color("MainTextColor"))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color("FrameColor"))
                    .cornerRadius(10)
                    
                    HStack {
                        Text("Имя пользователя")
                            .foregroundColor(Color("MainTextColor"))
                        Spacer()
                        Text("@nickname")
                    }
                    .padding()
                    .background(Color("FrameColor"))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    print("Вышли из аккаунта")
                }) {
                    Text("Выйти из аккаунта")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("FrameColor"))
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Назад") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Готово") {
                print("Сохранение изменений")
            })
            .foregroundColor(Color("MainTextColor"))
            .background(Color("AccentColor").ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ProfileChange()
}
