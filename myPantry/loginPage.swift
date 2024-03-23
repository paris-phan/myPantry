import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct LoginPage: View {
    
    func userAuth(phone: String, name: String) {
//        Task{
//            do {
//                print("Running userAuth...")
//                UserDefaults.standard.set(phone, forKey: "phone")
//                FirebaseApp.configure()
//                try PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationID, error in
//                    if let error = error {
//                        print(error.localizedDescription)
//                        return
//                    }
//                    print(verificationID)
//                }
//                print("Auth code sent to number")
//            } catch {
//                print("Error in userAuth")
//
//            }
//        }
        UserDefaults.standard.set(phone, forKey: "phone")
        UserDefaults.standard.set(name, forKey: "name")
        Task{
            do{
                print("Starting userAuth...")
                FirebaseApp.configure()
                let db = Firestore.firestore()
                print("db initialized")
                
                let docRef = db.collection("users").document(phone)
                
                let document = try await docRef.getDocument()
                if document.exists {
                    print("user exists in the database")
                }
                else {
                    do{
                        try await db.collection("users").document(phone).setData([
                            "name": name
                        ])
                        print("Created new user")
                    } catch {
                        print("Error creating new user")
                    }
                }
                
            } catch {
                print("Error in userAuth")
            }
        }
        
    }
    
    
    @State private var phone = ""
    @State private var name = ""
    @State private var shouldNavigate = false
    @State private var userExists = true
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("myPantry")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                TextField("Name", text: $name)
                    .padding()
                    .background(Color(.systemGray6))
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                TextField("Phone", text: $phone)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                Button(action: {
                    print("Login Button Pressed")
                    Task{
                        print("")
                        userAuth(phone: phone, name: name)
                    }
                    if userExists{
                        self.shouldNavigate = true
                    }
                    else{
                        //
                        //TODO: make "email does not exist" pop up in red
                        //
                    }
                    
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                
                
                
            }
            .padding()
            .navigationDestination(isPresented: $shouldNavigate) {
                homePage()
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
