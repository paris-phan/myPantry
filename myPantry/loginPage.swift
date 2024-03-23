//
//  loginPage.swift
//  myPantry
//
//  Created by Abhinav Pappu on 3/23/24.
//

import SwiftUI

struct LoginPage: View {
    @State private var usernameOrPhone = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("Username or Phone Number", text: $usernameOrPhone)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)

            Button(action: login) {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 220, height: 60)
                    .background(Color.green)
                    .cornerRadius(15.0)
            }
        }
        .padding()
    }

    
    
    
    func login() {
        // Perform login action here
        // Validate usernameOrPhone and password
        // You might need to differentiate between a phone number and a username
        // Then proceed with the login logic
        print("Login button pressed")
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}

