
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
        
        captureSession.startRunning()
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
//        settings.flashMode = isFlashOn ? .on : .off
        
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
    @StateObject private var cameraController = CameraController()
    @State private var showPreview = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            CameraView(cameraController: cameraController)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
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
                ImagePreviewView(image: image, capturedImage: $cameraController.capturedImage, selectedImage: $selectedImage, isPresented: $showPreview)
            }
        })
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(selectedImage: $selectedImage)
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

    var body: some View {
        VStack {
            HStack{
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
            
            HStack {
                Button(action: {
                    saveToGallery()
                }) {
                    Text("Сохранить")
                        .font(.system(size: 27))
                        .foregroundStyle(Color.white)
                        .bold()
                        .padding()
                }
                .background(Color.gray)
                .cornerRadius(8.0)
                .padding()
            }
        }
    }
    
    private func saveToGallery() {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        clearAndDismiss() // Закрытие экрана после сохранения
    }
    
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
