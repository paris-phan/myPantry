//
//  loginPage.swift
//  myPantry
//
//  Created by Abhinav Pappu on 3/23/24.
//

import SwiftUI
import AuthenticationServices

struct LoginPage: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
            SignInWithAppleButton(.signUp) { request in
                // Configure the request here.
            } onCompletion: { result in
                // Handle the authentication result here.
            }
            .signInWithAppleButtonStyle(.black)
            .frame(width: 280, height: 45)
        }
    }
}



// This is the correct way to define a preview in SwiftUI.
struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}

