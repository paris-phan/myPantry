//
//  loginPage.swift
//  myPantry
//
//  Created by Abhinav Pappu on 3/23/24.
//
import SwiftUI

struct LoginPage: View {
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var password: String = ""

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter your info:")) {
                    TextField("Name", text: $name)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    TextField("Phone", text: $phone)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $password)
                }

                Button(action: logIn) {
                    Text("Log In")
                }
            }
            .navigationBarTitle("Log In")
        }
    }
    
    func logIn() {
        // Implement the login logic here
        // This might include form validation and sending data to a server
        print("Logging in with Name: \(name), Phone: \(phone), Password: \(password)")
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
