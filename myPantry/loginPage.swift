import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore


struct LoginPage: View {
    
    func userAuth(phone: String, name: String) async{
        Task{
            return true
//            do{
//                print("starting userAuth()...")
//                FirebaseApp.configure()
//                let db = Firestore.firestore()
//                print("db initialised")
//                
//                let docRef = db.collection("users").document(phone)
//                
//                let document = try await docRef.getDocument()
//                if document.exists {
//                    print("User exists in database")
//                    userExists = true
//                }
//                else{
//                    print("User does not exist")
//                    userExists = false
//                }
//            } catch {
//                print("Error grabbing user")
//                userExists = false
//            }
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
                
                SecureField("Phone", text: $phone)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)

                Button(action: {
                    print("Login Button Pressed")
                    Task{
                        await userAuth(phone: phone, name: name)
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
                        .background(Color.green)
                        .cornerRadius(15.0)
                }
                
                
                
            }
            .padding()
            .navigationDestination(isPresented: $shouldNavigate) {
                authVerif()
            }
        }
    }
}

struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
