//
//  homePage.swift
//  myPantry
//
//  Created by Abhinav Pappu on 3/23/24.
//

import SwiftUI
import AVFoundation
import UIKit


class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var image: UIImage?
    private let captureSession = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    func setup() {
        // Add camera input
        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: camera) else { return }
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        // Add photo output
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }

        // Start the session
        captureSession.startRunning()
    }

    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        self.image = UIImage(data: imageData)
    }
}


struct homePage: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("Camera feed")
                    .onAppear {
                        viewModel.setup()
                    }
            }
            Button("Take Photo") {
                viewModel.takePhoto()
            }
        }
    }
}




//@available(iOS 16.0, *)
//struct homePage: View {
//    @State private var selectedItem: PhotosPickerItem? = nil
//    @State private var selectedImageData: Data? = nil
//
//    var body: some View {
//        PhotosPicker(
//            selection: $selectedItem,
//            matching: .images,
//            photoLibrary: .shared()) {
//                Text("Select a photo")
//            }
//            .onChange(of: selectedItem) { newItem in
//                Task {
//                    // Retrieve selected asset in the form of Data
//                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
//                        selectedImageData = data
//                    }
//                }
//            }
//
//        if let selectedImageData,
//           let uiImage = UIImage(data: selectedImageData) {
//            Image(uiImage: uiImage)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 250, height: 250)
//        }
//    }
//}



struct homePagePreview: PreviewProvider {
    static var previews: some View {
        homePage()
    }
}
