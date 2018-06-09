//
//  FirstViewController.swift
//  MLCore Examples
//
//  Created by Jack Cox on 6/9/18.
//  Copyright © 2018 CapTech Consulting. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit
import Vision


class ARMLVisionViewController: UIViewController, ARSKViewDelegate, ARSessionDelegate {
    @IBOutlet weak var sceneView: ARSKView!
    
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    private var currentBuffer: CVPixelBuffer?
    
    // Queue for dispatching vision classification requests
    private let visionQueue = DispatchQueue(label: "com.captechconsulting.MLCore-Examples.serialVisionQueue")
    
    @IBOutlet weak var customClassifierLabel: UILabel!
    @IBOutlet weak var inceptionClassifierLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var customModelClassificationRequest: VNCoreMLRequest?
    private var inceptionModelClassificationRequest: VNCoreMLRequest?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure and present the SpriteKit scene that draws overlay content.
        let overlayScene = SKScene()
        overlayScene.scaleMode = .aspectFill
        sceneView.delegate = self
        sceneView.presentScene(overlayScene)
        sceneView.session.delegate = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // create the classifier requests based on new settings
        customModelClassificationRequest = self.createClassificationRequestion(classificationModel: ImageClassifier256().model, label: self.customClassifierLabel)
        inceptionModelClassificationRequest = self.createClassificationRequestion(classificationModel: Inceptionv3().model, label: self.inceptionClassifierLabel)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        // TODO: This doesn't seem to pause didly squat
        sceneView.session.pause()
    }
    
    // MARK: ARSessionDelegate
    
    
    /// ARSessionDelegate method called on every frame. This app uses this to capture the image and try to classify it
    ///
    /// - Parameters:
    ///   - session: The ARSession reporting an image
    ///   - frame: The frame that the AR scene sees
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do not enqueue other buffers for processing while another Vision task is still running.
        // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {

            return
        }
        
        // Retain the image buffer for Vision processing.
        self.currentBuffer = frame.capturedImage
        classifyImageInCurrentBuffer()
    }
    
    /// Called when the camera changes state
    ///
    /// - Parameters:
    ///   - session: The ARKit session
    ///   - camera: The current camera
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {

        DispatchQueue.main.async {
            // show if the camera is not in a tracking state
            self.messageLabel.text = camera.trackingState.presentationString
        }
    }
    
    // MARK: Image Classification code
    
    /// Create a classification request for a specific model that reports to a specific label. These are called whent he view appears
    /// so that the requests are refreshed with the current settings
    ///
    /// - Parameters:
    ///   - classificationModel: The image classification model to utilize
    ///   - label: The UILabel to use for output
    /// - Returns: A VNCoreMLRequest
    private func createClassificationRequestion(classificationModel:MLModel, label:UILabel) -> VNCoreMLRequest {
        do {
            // Instantiate the model from its generated Swift class.
            let model = try VNCoreMLModel(for: classificationModel)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error, label: label)
            })
            
            // Crop input images to square area at center, matching the way the ML model was trained.
            request.imageCropAndScaleOption = .centerCrop
            
            // Use CPU for Vision processing to ensure that there are adequate GPU resources for rendering.
            request.usesCPUOnly = !SettingsManager.sharedInstance.useGPUForImageClassification
            
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
    
    private func classifyImageInCurrentBuffer() {
        // Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue)) else {
            print("Error: somehow we got an unexpected orientation")
            return
        }
        
        guard let currentBuffer = currentBuffer else {
            print("Error: The current image buffer is empty")
            return
        }
        guard let customReq = self.customModelClassificationRequest, let inceptionRequest = self.inceptionModelClassificationRequest else {
            print("requests not initialized")
            return
        }
        // create a request to classify the buffer
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer, orientation: orientation)
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                // use two models to classify the image
                var requests:[VNRequest] = []
                if SettingsManager.sharedInstance.doCustomClassification {
                    requests.append(customReq)
                }
                if SettingsManager.sharedInstance.doInceptionClassification {
                    requests.append(inceptionRequest)
                }
                try requestHandler.perform(requests)
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?, label:UILabel?) {
        guard let results = request.results else {
            print("Unable to classify image.\n\(error!.localizedDescription)")
            return
        }
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        guard let classifications = results as? [VNClassificationObservation] else {
            print("Observations came back as the wrong type")
            return
        }
        
        guard let label = label else {
            print("Self got freed somewhere, so the UILabel doesn't exist.")
            return
        }
        
        var message: String?
        
        // Show a label for the highest-confidence result (but only above a minimum confidence threshold).
        if let bestResult = classifications.first(where: { result in result.confidence > 0.5 }),
            let clazz = bestResult.identifier.split(separator: ",").first {
            let confidence = bestResult.confidence
            message = String(format: "\(clazz) : %.2f", confidence * 100) + "% confidence"
            DispatchQueue.main.async {
                label.text = message
            }
        }
        
        
    }

}

extension ARCamera.TrackingState {
    var presentationString: String? {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return nil
        case .limited(.excessiveMotion):
            return "TRACKING LIMITED\nExcessive motion"
        case .limited(.insufficientFeatures):
            return "TRACKING LIMITED\nLow detail"
        case .limited(.initializing):
            return "Initializing"
        case .limited(.relocalizing):
            return "Recovering from interruption"
        }
    }
    
    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Try slowing down your movement, or reset the session."
        case .limited(.insufficientFeatures):
            return "Try pointing at a flat surface, or reset the session."
        case .limited(.relocalizing):
            return "Return to the location where you left off or try resetting the session."
        default:
            return nil
        }
    }
}
