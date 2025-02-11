
import SwiftUI
import PhotosUI
import AVFoundation


class CameraController: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession?
    private var captureDevice: AVCaptureDevice?
    private var photoOutput: AVCapturePhotoOutput?
    
    @Published var isFlashOn = false
    @Published var capturedImage: UIImage? = nil
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        captureSession.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        captureDevice = device
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        } catch {
            print("Unable to add video input")
        }
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = self.photoOutput, captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        DispatchQueue.global(qos: .background).async {
            captureSession.startRunning()
        }
    }

    func stopCamera() {
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.stopRunning()
            // Удаляем все входы и выходы, если необходимо
            if let inputs = self.captureSession?.inputs {
                for input in inputs {
                    self.captureSession?.removeInput(input)
                }
            }
            if let outputs = self.captureSession?.outputs {
                for output in outputs {
                    self.captureSession?.removeOutput(output)
                }
            }
        }
    }
    
    func toggleFlash() {
        guard let device = captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            if device.hasTorch {
                isFlashOn.toggle()
                device.torchMode = isFlashOn ? .on : .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            DispatchQueue.main.async {
                self.capturedImage = UIImage(data: imageData)
            }
        }
    }
}

struct CameraView: UIViewControllerRepresentable {
    let cameraController: CameraController
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: cameraController.captureSession!)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        let cameraView = UIView(frame: UIScreen.main.bounds)
        cameraView.layer.addSublayer(videoPreviewLayer)
        
        viewController.view = cameraView
        videoPreviewLayer.frame = viewController.view.layer.bounds
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Updates the UI view with context if needed
    }
}

struct CreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var cameraController = CameraController()
    @State private var showPreview = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @ObservedObject var models: Models
    
    var body: some View {
        ZStack {
            CameraView(cameraController: cameraController)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    ZStack {
                        Color.black.opacity(0.25)
                        
                        Button(action: {
                            print("help button tapped")
                            //показ туториала
                        }) {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(8.0)
                    
                    Spacer()
                    
                    ZStack {
                        Color.black.opacity(0.25)
                        
                        Button(action: {
                            print("close button")
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 25))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .cornerRadius(8.0)
                }
                .padding(.horizontal, 25)

//                HStack {
//                    Spacer()
//                    ZStack {
//                        Color.black.opacity(0.25)
//                        
//                        Button(action: {
//                            print("close button")
////                            cameraController.stopCamera()
////                            cameraController.captureSession?.stopRunning()
//                            presentationMode.wrappedValue.dismiss()
//                        }) {
//                            Image(systemName: "xmark")
//                                .font(.system(size: 25))
//                                .foregroundStyle(.white)
//                                .buttonStyle(PlainButtonStyle())
//                        }
//                    }
//                    .frame(width: 50, height: 50)
//                    .cornerRadius(8.0)
//                }
//                .padding(.trailing, 25)
                
                Spacer()
                
                HStack {
                    // Flash Toggle Button
                    Button(action: {
                        cameraController.toggleFlash()
                    }) {
                        Image(systemName: cameraController.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                    
                    Spacer()
                    
                    // Capture Button
                    Button(action: {
                        cameraController.takePhoto()
                    }) {
                        CameraButton()
                    }
                    .frame(width: 50, height: 50)
                    
                    Spacer()
                    
                    // Gallery Button
                    Button(action: {
                        showImagePicker = true
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50)
                }
                .frame(maxWidth: 500)
                .padding(30)
                .background(Color.black.opacity(0.25))
            }
        }
        .onChange(of: cameraController.capturedImage) { newImage in
            if newImage != nil {
                showPreview = true
            }
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                showPreview = true
            }
        }
        .fullScreenCover(isPresented: $showPreview, content: {
            if let image = cameraController.capturedImage ?? selectedImage {
                ImagePreviewView(image: image, capturedImage: $cameraController.capturedImage, selectedImage: $selectedImage, isPresented: $showPreview, models: models)
            }
        })
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(selectedImage: $selectedImage)
        }
        .onDisappear {
             cameraController.captureSession?.stopRunning()
         }
    }
}

struct CameraButton: View {
    var body: some View {
        ZStack {
            Image(systemName: "circle")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Image(systemName: "circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
    }
}

struct ImagePreviewView: View {
    let image: UIImage
    @Binding var capturedImage: UIImage?
    @Binding var selectedImage: UIImage?
    @Binding var isPresented: Bool
    @ObservedObject var models: Models
    @State private var imageName: String = ""
    @State private var selectedCategory = ModelCategory.decor
    @State private var showError: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button("Закрыть") {
                    clearAndDismiss()
                }
                .padding()
            }
            
            Spacer()
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
            
            Spacer()
            
            TextField("Введите название для изображения", text: $imageName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Picker для выбора категории
            Picker("Выберите категорию", selection: $selectedCategory) {
                ForEach(ModelCategory.allCases, id: \.self) { category in
                    Text(category.label).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            HStack {
                Button(action: {
                    validateAndSave()
                }) {
                    Text("Сохранить")
                        .font(.system(size: 27))
                        .foregroundStyle(Color.white)
                        .bold()
                        .padding()
                }
                .background(isFormValid() ? Color.blue : Color.gray) // Цвет кнопки в зависимости от валидности
                .cornerRadius(8.0)
                .padding()
                .disabled(!isFormValid()) // Блокировка кнопки, если поле пустое
            }
        }
    }
    
    // Проверка и сохранение
    private func validateAndSave() {
        if imageName.isEmpty {
            showError = true
        } else {
            showError = false
            sendToBackend(imageName: imageName, category: selectedCategory)
        }
    }
    
    // Проверка валидности формы
    private func isFormValid() -> Bool {
        !imageName.isEmpty
    }
    
    private func sendToBackend(imageName: String, category: ModelCategory) {
        let serverURL = URL(string: "http://90.156.217.78:8080/api/newrun-script")!
        let photoUploader = PhotoUploaderV2(serverURL: serverURL)
        NotificationCenter.default.post(name: .start3DModelAdded, object: nil)

        photoUploader.uploadPhoto(image) { result in
            switch result {
            case .success(let response):
                print("Upload successful!")
                models.handleResponseV2(response.meshData, imageName: imageName, category: category)
            case .failure(let error):
                print("Error uploading photo: \(error.localizedDescription)")
            }
        }

        clearAndDismiss()
    }
    
//    private func sendToBackend(imageName: String, category: ModelCategory) {
//        let uploader = PhotoUploader(serverURL: URL(string: "http://90.156.217.78:8080/api/upload")!)
//        NotificationCenter.default.post(name: .start3DModelAdded, object: nil)
//        uploader.uploadPhoto(image) { result in
//            switch result {
//            case .success(let (_, fileName)):
//                print("Photo uploaded successfully with filename: \(fileName)")
//                
//                guard let scriptURL = URL(string: "http://90.156.217.78:8080/api/run-script") else {
//                    print("Invalid URL for script runner")
//                    return
//                }
//                
//                let scriptRunner = PostScriptRunner(serverURL: scriptURL)
//                
//                scriptRunner.runScript(with: "examples/\(fileName)") { result in
//                    switch result {
//                    case .success(let response):
//                        print("Successfully")
//                        models.handleResponse(response, imageName: imageName, category: category)
//                    case .failure(let error):
//                        print("Error: \(error.localizedDescription)")
//                    }
//                }
//            case .failure(let error):
//                print("Failed to upload photo: \(error.localizedDescription)")
//            }
//        }
//
//        clearAndDismiss()
//    }
    
    private func clearAndDismiss() {
        capturedImage = nil
        selectedImage = nil
        isPresented = false
    }
}


struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images // Только изображения
        config.selectionLimit = 1 // По одному изображению
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate{
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

extension Notification.Name {
    static let createViewDismissed = Notification.Name("createViewDismissed")
    static let start3DModelAdded = Notification.Name("start3DModelAdded")
    static let end3DModelAdded = Notification.Name("end3DModelAdded")
}
