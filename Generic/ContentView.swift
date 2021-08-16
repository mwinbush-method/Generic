//
//  ContentView.swift
//  Generic
//
//  Created by Morgan Winbush on 8/10/21.
//

import SwiftUI

enum GlobalPages {
    case firstPage
    case secondPage
}

class GlobalNavigator: ObservableObject {
    @Published var currentPage : GlobalPages
    
    init() {
        currentPage = .secondPage
    }
}

struct ContentView: View {
    @StateObject var globalNavigator: GlobalNavigator = GlobalNavigator()
    
    var body: some View {
        switch globalNavigator.currentPage {
        case .firstPage:
            FirstPage()
                .environmentObject(globalNavigator)
        case .secondPage:
            SecondPage()
                .environmentObject(globalNavigator)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
