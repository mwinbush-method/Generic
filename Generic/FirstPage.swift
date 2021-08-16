//
//  FirstPage.swift
//  Generic
//
//  Created by Morgan Winbush on 8/10/21.
//

import SwiftUI
import RealityKit

struct FirstPage: View {
    @EnvironmentObject var globalNavigator: GlobalNavigator
    
    var body: some View {
        return ARViewIndicator()
            .edgesIgnoringSafeArea(.all)
    }
}

// MARK: - ARViewIndicator
struct ARViewIndicator: UIViewControllerRepresentable {
   typealias UIViewControllerType = ARView
   
   func makeUIViewController(context: Context) -> ARView {
      return ARView()
   }
    
   func updateUIViewController(_ uiViewController:
   ARViewIndicator.UIViewControllerType, context:
   UIViewControllerRepresentableContext<ARViewIndicator>) { }
}

struct FirstPage_Previews: PreviewProvider {
    static var previews: some View {
        FirstPage()
    }
}
