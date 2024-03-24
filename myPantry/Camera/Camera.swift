/*
See the License.txt file for this sample’s licensing information.
*/

import AVFoundation
import CoreImage
import UIKit
import os.log
import VisionKit
import Vision
import OpenAIKit
import GoogleGenerativeAI
import FirebaseCore
import FirebaseFirestore
import Firebase
import SwiftUI

class Camera: NSObject {
    private let captureSession = AVCaptureSession()
    private var isCaptureSessionConfigured = false
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var sessionQueue: DispatchQueue!
    
    private var allCaptureDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified).devices
    }
    
    private var frontCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .front }
    }
    
    private var backCaptureDevices: [AVCaptureDevice] {
        allCaptureDevices
            .filter { $0.position == .back }
    }
    
    private var captureDevices: [AVCaptureDevice] {
        var devices = [AVCaptureDevice]()
        #if os(macOS) || (os(iOS) && targetEnvironment(macCatalyst))
        devices += allCaptureDevices
        #else
        if let backDevice = backCaptureDevices.first {
            devices += [backDevice]
        }
        if let frontDevice = frontCaptureDevices.first {
            devices += [frontDevice]
        }
        #endif
        return devices
    }
    
    private var availableCaptureDevices: [AVCaptureDevice] {
        captureDevices
            .filter( { $0.isConnected } )
            .filter( { !$0.isSuspended } )
    }
    
    private var captureDevice: AVCaptureDevice? {
        didSet {
            guard let captureDevice = captureDevice else { return }
            logger.debug("Using capture device: \(captureDevice.localizedName)")
            sessionQueue.async {
                self.updateSessionForCaptureDevice(captureDevice)
            }
        }
    }
    
    var isRunning: Bool {
        captureSession.isRunning
    }
    
    var isUsingFrontCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return frontCaptureDevices.contains(captureDevice)
    }
    
    var isUsingBackCaptureDevice: Bool {
        guard let captureDevice = captureDevice else { return false }
        return backCaptureDevices.contains(captureDevice)
    }

    private var addToPhotoStream: ((AVCapturePhoto) -> Void)?
    
    private var addToPreviewStream: ((CIImage) -> Void)?
    
    var isPreviewPaused = false
    
    lazy var previewStream: AsyncStream<CIImage> = {
        AsyncStream { continuation in
            addToPreviewStream = { ciImage in
                if !self.isPreviewPaused {
                    continuation.yield(ciImage)
                }
            }
        }
    }()
    
    lazy var photoStream: AsyncStream<AVCapturePhoto> = {
        AsyncStream { continuation in
            addToPhotoStream = { photo in
                continuation.yield(photo)
            }
        }
    }()
        
    override init() {
        super.init()
        initialize()
    }
    
    private func initialize() {
        sessionQueue = DispatchQueue(label: "session queue")
        
        captureDevice = availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(updateForDeviceOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func configureCaptureSession(completionHandler: (_ success: Bool) -> Void) {
        
        var success = false
        
        self.captureSession.beginConfiguration()
        
        defer {
            self.captureSession.commitConfiguration()
            completionHandler(success)
        }
        
        guard
            let captureDevice = captureDevice,
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else {
            logger.error("Failed to obtain video input.")
            return
        }
        
        let photoOutput = AVCapturePhotoOutput()
                        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))
  
        guard captureSession.canAddInput(deviceInput) else {
            logger.error("Unable to add device input to capture session.")
            return
        }
        guard captureSession.canAddOutput(photoOutput) else {
            logger.error("Unable to add photo output to capture session.")
            return
        }
        guard captureSession.canAddOutput(videoOutput) else {
            logger.error("Unable to add video output to capture session.")
            return
        }
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        
        self.deviceInput = deviceInput
        self.photoOutput = photoOutput
        self.videoOutput = videoOutput
        
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        updateVideoOutputConnection()
        
        isCaptureSessionConfigured = true
        
        success = true
    }
    
    private func checkAuthorization() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            return true
        case .notDetermined:
            logger.debug("Camera access not determined.")
            sessionQueue.suspend()
            let status = await AVCaptureDevice.requestAccess(for: .video)
            sessionQueue.resume()
            return status
        case .denied:
            logger.debug("Camera access denied.")
            return false
        case .restricted:
            logger.debug("Camera library access restricted.")
            return false
        @unknown default:
            return false
        }
    }
    
    private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
        guard let validDevice = device else { return nil }
        do {
            return try AVCaptureDeviceInput(device: validDevice)
        } catch let error {
            logger.error("Error getting capture device input: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
        guard isCaptureSessionConfigured else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        for input in captureSession.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                captureSession.removeInput(deviceInput)
            }
        }
        
        if let deviceInput = deviceInputFor(device: captureDevice) {
            if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
        }
        
        updateVideoOutputConnection()
    }
    
    private func updateVideoOutputConnection() {
        if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
            if videoOutputConnection.isVideoMirroringSupported {
                videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
            }
        }
    }
    
    func start() async {
        let authorized = await checkAuthorization()
        guard authorized else {
            logger.error("Camera access was not authorized.")
            return
        }
        
        if isCaptureSessionConfigured {
            if !captureSession.isRunning {
                sessionQueue.async { [self] in
                    self.captureSession.startRunning()
                }
            }
            return
        }
        
        sessionQueue.async { [self] in
            self.configureCaptureSession { success in
                guard success else { return }
                self.captureSession.startRunning()
            }
        }
    }
    
    func stop() {
        guard isCaptureSessionConfigured else { return }
        
        if captureSession.isRunning {
            sessionQueue.async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func switchCaptureDevice() {
        if let captureDevice = captureDevice, let index = availableCaptureDevices.firstIndex(of: captureDevice) {
            let nextIndex = (index + 1) % availableCaptureDevices.count
            self.captureDevice = availableCaptureDevices[nextIndex]
        } else {
            self.captureDevice = AVCaptureDevice.default(for: .video)
        }
    }

    private var deviceOrientation: UIDeviceOrientation {
        var orientation = UIDevice.current.orientation
        if orientation == UIDeviceOrientation.unknown {
            orientation = UIScreen.main.orientation
        }
        return orientation
    }
    
    @objc
    func updateForDeviceOrientation() {
        //TODO: Figure out if we need this for anything.
    }
    
    private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
        switch deviceOrientation {
        case .portrait: return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
        case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
        default: return nil
        }
    }
    
    func takePhoto() {
        guard let photoOutput = self.photoOutput else { return }
        
        sessionQueue.async {
        
            var photoSettings = AVCapturePhotoSettings()

            if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            
            let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
            photoSettings.flashMode = isFlashAvailable ? .auto : .off
            photoSettings.isHighResolutionPhotoEnabled = true
            if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
            }
            photoSettings.photoQualityPrioritization = .balanced
            
            if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
                if photoOutputVideoConnection.isVideoOrientationSupported,
                    let videoOrientation = self.videoOrientationFor(self.deviceOrientation) {
                    photoOutputVideoConnection.videoOrientation = videoOrientation
                }
            }
            
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        
        if let error = error {
            logger.error("Error capturing photo: \(error.localizedDescription)")
            return
        }
        
        // Assuming `photo` is your AVCapturePhoto instance
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let ciImage = CIImage(data: imageData) else { return }
        
        
        // Create a text recognition request
        let textRequest = VNRecognizeTextRequest { (request, error) in
            guard error == nil else {
                // Handle any errors
                print("Error processing request: \(error!.localizedDescription)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("No text found")
                return
            }

            // Concatenate the recognized text from all observations
            let recognizedText = observations.compactMap { observation in
                // Return the top candidate for each observation
                return observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            // Here, `recognizedText` is your result string containing all recognized text
            print(recognizedText)
            
            
            
            let config = GenerationConfig(
              temperature: 0.9,
              topP: 1,
              topK: 1,
              maxOutputTokens: 2048
            )

            // Don't check your API key into source control!
            let apiKey = "AIzaSyD8l8t4rw3kT61cLlVgiIporeV5L69Uino"

            let model = GenerativeModel(
              name: "gemini-1.0-pro",
              apiKey: apiKey,
              generationConfig: config,
              safetySettings: [
                SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockMediumAndAbove),
                SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove)
              ]
            )

            Task {
              do {
                let response = try await model.generateContent(
                    "The prompt will contain text data of a grocery receipt. For every item purchased, give the item name and approximately when it will expire. Calculate the approximate expiration dates by assuming what type of food it is and its average shelf-life. Assume all purchases are made the day of. Give the result in this format:\n\n \"item_one\" : \"mm-dd-yyyy\",\n\"item_two\" : \"mm-dd-yyyy\",\n\"item_three\" : \"mm-dd-yyyy\"",
                      "input: TRADER JOE'S\n2025 Bond Street\n22901\nCharlottesville,\nStore #0661 - 434-974-1466\nOPEN 8:00AM TO 9:00PM DAILY\nSALE TRANSACTION\nSLICED JACK WITH PEPPERS\nCHICKEN SOUP DUMPLINGS\n2 0 $3.49\nLITE SHREDDED MOZZARELLA\nCRACKERS ORG NAAN GARLIC\nVEGETABLE PAD THAI\nGREEN BEANS GARLIC SHIIT\nMINI PLAIN BAGELS\nRASPBERRIES 6 OZ\nSTRAWBERRIES 1 LB\nR-PINEBERRIES\n100Z\nSALAD ORGANIC BABY SPINA\nTax:\n$41.38 @ 1.0%\nItems in Transaction: 12\nBalance to pay\nVISA\n$4.49\n$6.98\n$3.49\n$3.49\n$3,49\n$2.99\n$3.49\n$3.99\n$3.99\n$2.29\n$0.41\n$41.79\n$41.79\nPAYMENT CARD PURCHASE\nTRANSACTION\nCUSTOMER COPY\nUS DEBIT\nlype:\nChip Read\nAID: A0000000980840\nTVR: 8000088000\nIAD: 06011203A08000\nMID: *******27013\nTOTAL PURCHASE\n************5743\nAuth Code:\n122787\nPAN Seq:\nTSI:\n6800\nTID:\n**34. 79\nPlease retain for your records\nTS Alison\nTRANS.\n278662\nTHANK YOU FOR SHOPPING AT\nTRADER JOE'S\nwww.traderjoes.com\nDATE\n03-22-24 18:28\ndua\n008d\nOOH\nROL\nTax:\ni Transaction\nto pay\nDebit\nAYMENT CARD PURCHASE\nAYMENT CARD PURCHASE\nCUSTOMER\nCUSTOMER\nCOPY TRA\nACTLESS\n******\nCode:\n**",
                      "output: \"Sliced Jack With Peppers\" : \"04-05-2024\",\n\"Chicken Soup Dumplings\" : \"09-22-2024\",\n\"Lite Shredded Mozzarella\" : \"04-05-2024\",\n\"Crackers Org Naan Garlic\" : \"09-22-2024\",\n\"Vegetable Pad Thai\" : \"09-22-2024\",\n\"Green Beans Garlic\" : \"03-29-2024\",\n\"Mini Plain Bagels\" : \"03-29-2024\",\n\"Raspberries 6oz\" : \"03-25-2024\",\n\"Strawberries 1lb\" : \"03-25-2024\",\n\"R-Pineberries 10oz\" : \"03-25-2024\",\n\"Salad Organic Baby Spinach\" : \"03-29-2024\"",
                      "input: TRA\n2025 Bono\nCharlottesville,\nstore #0661 - 43\nOPEN 8:00AM TO 9:00P\\\nSALE TRANSACTIO\nPASTA RAVIOLONI ITALIAN\nDUMPLINGS PORK AND GINGE\n2 ₫ $3.49\nCHICKEN TIKKA SAMOSAS\n4 0 $4.49\nTORTILLA ROLLED CHILI LI\nTax: $31.92 @ 1.0%\nItems in Transaction:8\nBalance to pay\nVisa Debit\n$32.\nPAYMENT CAPO PURCHASE TP\nCUSTOMER MO\nUS DEBIT\nType:\nMTD:",
                      "output: \"Pasta Ravioloni Italian\" : \"04-06-2024\",\n\"Dumplings Pork and Ginger\" : \"09-22-2024\",\n\"Chicken Tikka Samosas\" : \"09-22-2024\",\n\"Tortilla Rolled Chilli Lime\" : \"09-22-2024\",",
                      "input: \(recognizedText)",
                  "output: "
                )
                print(response.text ?? "No text available")
                
                  
                  let dataMap = self.stringToMap(input: response.text ?? "No text available")
                  print(dataMap)
                  
                  Task{
                      //FirebaseApp.configure()
                      let db = Firestore.firestore()
                      let houseCode = "123456"
                      
                      db.collection("house").document(houseCode).setData(dataMap, merge: true)
                      
                      
                  }
                  struct homePagePreview: PreviewProvider {
                      static var previews: some View {
                          homePage()
                      }
                  }
                
                  
                  
              } catch {
                print(error)
              }
            }
            
            
            
            
            
            
            
            
            // Access your API key from your on-demand resource .plist file
            // (see "Set up your API key" above)
//            Task{
//                let model = GenerativeModel(name: "receiptParserMyPantry", apiKey: "AIzaSyD8l8t4rw3kT61cLlVgiIporeV5L69Uino")
//                let prompt = recognizedText
//                let response = try await model.generateContent(prompt)
//                if let text = response.text {
//                    print(text)
//                }
//            }
            
            // If you want to store it outside, make sure to do it on the main thread if updating UI or similar
        }
        
        // Specify some properties for the request, if needed
//        textRequest.recognitionLevel = .accurate
//        textRequest.usesLanguageCorrection = true

        // Process the image
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([textRequest])
        } catch {
            print("Failed to perform text recognition request: \(error)")
        }
        
        
        
        
        
        
        //TODO: photo is of type AVCapturePhoto
        //addToPhotoStream?(photo)
    }
    func stringToMap(input: String) -> [String: String] {
        var map = [String: String]()
        // Split the string into lines
        let lines = input.components(separatedBy: ",\n")
        for line in lines {
            // Split each line by " : " to separate the key and value
            let components = line.components(separatedBy: "\" : \"")
            if components.count == 2 {
                // Extract the key and value, trimming the quotes and whitespace
                let key = components[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let value = components[1].trimmingCharacters(in: CharacterSet(charactersIn: "\","))
                map[key] = value
            }
        }
        return map
    }
}

extension Camera: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
        
        if connection.isVideoOrientationSupported,
           let videoOrientation = videoOrientationFor(deviceOrientation) {
            connection.videoOrientation = videoOrientation
        }

        addToPreviewStream?(CIImage(cvPixelBuffer: pixelBuffer))
    }
}

fileprivate extension UIScreen {

    var orientation: UIDeviceOrientation {
        let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
        if point == CGPoint.zero {
            return .portrait
        } else if point.x != 0 && point.y != 0 {
            return .portraitUpsideDown
        } else if point.x == 0 && point.y != 0 {
            return .landscapeRight //.landscapeLeft
        } else if point.x != 0 && point.y == 0 {
            return .landscapeLeft //.landscapeRight
        } else {
            return .unknown
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "Camera")

