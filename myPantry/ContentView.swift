//
//  ContentView.swift
//  Shared
//
//

import UIKit
import VisionKit
import Vision
import SwiftUI
import AVFoundation


struct ContentView: View {
    var body: some View {
        Text("myPantry")
            .font(.custom("STIX Two Text", size: 60))
            .bold()
    }
}
    
//    init (){
//        for familyName in UIFont.familyNames{
//            print(familyName)
//            for fontName in UIFont.fontNames(forFamilyName: familyName)
//                    
//                print("-- \(fontName)")
//        }
//        
//    }
//}


struct ContentViewProvider: PreviewProvider{
    static var previews: some View{
        ContentView()
    }
    
}
