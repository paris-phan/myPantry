import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseCore

struct houseSetup: View {
    @State private var identifier = ""
    @State private var houseName = ""
    @State private var shouldNavigate = false
    @State private var shouldNavigate2 = false
    
    func houseSetup(code: String) async -> Bool{
        print("running houseSetup")
        print(code)
        if code.isEmpty{
            print("Creating new house")
            
            let letters = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ0123456789"
            let newCode = String((0..<6).map{ _ in letters.randomElement()! })
            do{
                //FirebaseApp.configure()
                let db = Firestore.firestore()
                try await db.collection("house").document(newCode).setData([:])
                UserDefaults.standard.set(newCode, forKey: "house")
            } catch { print("Error creating house") }
            self.shouldNavigate2 = true
            return false
        }
        else{
            print("Checking house code")
            
            do{
                //return true
                //FirebaseApp.configure()
                let db = Firestore.firestore()
                let docRef = db.collection("house").document(code)
                let document = try await docRef.getDocument()
                print(document)
                if document.exists {
                    UserDefaults.standard.set(code, forKey: "house")
                    print("successful userdefault set house")
                } else { print("House does not exist") }
                
            } catch { print("Error finding house") }
            self.shouldNavigate = true
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Join or Create a House")
                    .font(.custom("STIX Two Text", size: 30))
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                Image("home/home1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding(.bottom, 20)
                    
                
                TextField("Leave blank to create", text: $identifier)
                    .neumorphicTextFieldStyle()
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(5.0)
//                    .padding(.bottom, 20) // Corrected padding

                Button("Join/Create", action:{
                    Task{
                        let hasHouse = await houseSetup(code: identifier)
                        print("returned from houseSetup, hasHouse = " + String(hasHouse))
                        }
                    })
                .neumorphicButtonModifier()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.accentColor.opacity(0.3)
                    .ignoresSafeArea()
            }
            .navigationDestination(isPresented: $shouldNavigate){
                homePage()
                
            }
            .navigationDestination(isPresented: $shouldNavigate2){
                CameraView()
            }
            
        }
    }
}




struct HouseSetup_Previews: PreviewProvider {
    static var previews: some View {
        houseSetup()
    }
}
