//
//  FirstPage.swift
//  Generic
//
//  Created by Morgan Winbush on 8/10/21.
//

import SwiftUI
import RealityKit
import ARKit
import Vision

struct FirstPage: View {
    @EnvironmentObject var globalNavigator: GlobalNavigator
    @State var arView = ARView()
    
    var body: some View {
        return ARViewIndicator(arview: $arView)
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - ARViewIndicator
struct ARViewIndicator: UIViewRepresentable {
    
    @Binding var arview: ARView
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    // creates our ARView
    func makeUIView(context: Context) -> ARView {
        // makes ARView object
        let arView = self.arview
        arView.session.delegate = context.coordinator
        // return ARView
        return arView
    }
 
    func updateUIView(_ uiView: ARView, context: Context) { }
    
    class Coordinator : NSObject, ARSessionDelegate {
        
        // A Reference to the ARIndicator struct
        // This allows us access to the binded ARView property
        // Creates the opportunity to manipulate the ARView from delegation
        var parent: ARViewIndicator
        
        // Pre generated AR Model Entity
        // The Model Entity must be created at build time.
        var sphereEntity : ModelEntity
        
        // The pixel buffer being held for analysis; used to serialize Vision requests.
        // This is also a dispach queue reference for the vision thread to operate on.
        private var currentBuffer: CVPixelBuffer?
        private let visionQueue = DispatchQueue(label: "com.skookum.Generic.ARKitVision.serialVisionQueue")
        
        // A lazy reference that is used to classify the Scanned BarCode
        private lazy var classificationRequest = VNDetectBarcodesRequest { request, error in
            guard error == nil else { return }
            self.processClassification(request: request)
        }
        
        
        // MARK: Initializer
        init(_ parent: ARViewIndicator) {
            let sphereMesh = MeshResource.generateSphere(radius: 0.05)
            let material = SimpleMaterial(color: .red, roughness: 0, isMetallic: true)
            sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
            self.parent = parent
        }
        
        // MARK: Adding new AREntity
        func addObject() {
            let anchor = AnchorEntity(plane: .any)
            anchor.addChild(self.sphereEntity)
            self.parent.arview.scene.addAnchor(anchor)
            print("Add Object is called")
        }

    }

}

// MARK: ARView Delegate Methods
extension ARViewIndicator.Coordinator {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }

        // Retain the image buffer for Vision processing.
        self.currentBuffer = frame.capturedImage
        classifyCurrentImage()
    }
}

// MARK: VisionKit implementation
// Used to handle render AImage from ARView and Process QRCode
extension ARViewIndicator.Coordinator {
    // Run the Vision+ML classifier on the current image buffer.
    /// - Tag: ClassifyCurrentImage
    private func classifyCurrentImage() {
        // Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(UIDevice.current.orientation.rawValue)) else { return }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                try requestHandler.perform([self.classificationRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }

    func processClassification(request: VNRequest){
        guard let barcodes = request.results else { return }

        // Cast the result to a barcode-observatin
        for barcode in barcodes {
            guard
              // TODO: Check for QR Code symbology and confidence score
              let potentialQRCode = barcode as? VNBarcodeObservation
              else { return }

            // 3
            print("\(potentialQRCode.symbology.rawValue)")
            print("\(potentialQRCode.payloadStringValue ?? "")")
            self.addObject()
        }
    }
}

struct FirstPage_Previews: PreviewProvider {
    static var previews: some View {
        FirstPage()
    }
}
