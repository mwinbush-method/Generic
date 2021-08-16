//
//  SecondPage.swift
//  Generic
//
//  Created by Morgan Winbush on 8/10/21.
//

import SwiftUI
import AVKit

struct SecondPage: View {
    @EnvironmentObject var globalNavigator: GlobalNavigator
    @State var cameraEnabled : Bool = false
    
    init() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined:
            self.cameraEnabled = false
        case .restricted:
            self.cameraEnabled = false
        case .denied:
            self.cameraEnabled = false
        case .authorized:
            self.cameraEnabled = true
        @unknown default:
            self.cameraEnabled = false
        }
    }
    
    var body: some View {
        VStack {
            Text("Camera Usage")
            Button(action: {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
                    guard accessGranted == true else { return }
                })
            }, label: {
                Text("Request Camera Usage Permision")
            })
            
            Button("Look for AR Object", action: {
                globalNavigator.currentPage = .firstPage
            })
            .disabled(cameraEnabled)
        }
    }
}

struct SecondPage_Previews: PreviewProvider {
    static var previews: some View {
        SecondPage()
    }
}
