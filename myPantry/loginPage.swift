import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct LoginPage: View {
    
    func userAuth(phone: String, name: String) {
        print("calling userAuth")
        UserDefaults.standard.set(phone, forKey: "phone")
        UserDefaults.standard.set(name, forKey: "name")
        Task{
            do{
                print("Starting userAuth...")
                //FirebaseApp.configure()
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
    @State private var shouldNavigate2 = false
    @State private var userExists = true
    @State private var configureBool = false
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("myPantry")
                    .font(.custom("STIX Two Text", size: 60))
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                Image("pantry/pantry1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding(.bottom, 20)
                    

                TextField("Name", text: $name)
                    .neumorphicTextFieldStyle()
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
//                    .cornerRadius(5.0)
//                    .padding(.bottom, 20)
                
                TextField("Phone", text: $phone)
                    .neumorphicTextFieldStyle()
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(5.0)
//                    .padding(.bottom, 20)

                Button("Login", action: {
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
                    
                }) 
                .neumorphicButtonModifier()
//                {
//                    Text("Login")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .frame(width: 220, height: 60)
//                        .background(Color.blue)
//                        .cornerRadius(15.0)
//                }
                
                
                
            }
            
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.accentColor.opacity(0.3)
                    .ignoresSafeArea()
            }
            .navigationDestination(isPresented: $shouldNavigate){
                houseSetup()
            }
            .navigationDestination(isPresented: $shouldNavigate2){
                homePage()
            }
        }
        .onAppear {
            if configureBool == false {
                print("!!!firebase configure!!!")
                FirebaseApp.configure()
                configureBool = true
            }
            if let value = UserDefaults.standard.object(forKey: "house") as? String {
                // The key exists, and you now have a non-optional value to work with.
                print("Value for key exists: \(value)")
                shouldNavigate2 = true
                
            } else {
                // The key does not exist.
                print("Key does not exist")
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
