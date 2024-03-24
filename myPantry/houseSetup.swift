import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseCore

struct houseSetup: View {
    @State private var identifier = ""
    @State private var houseName = ""
    @State private var shouldNavigate = false
    
    func houseSetup(code: String) async -> Bool{
        if code.isEmpty{
            self.shouldNavigate = true
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let newCode = String((0..<6).map{ _ in letters.randomElement()! })
            do{
                FirebaseApp.configure()
                let db = Firestore.firestore()
                try await db.collection("house").document(newCode).setData([:])
                UserDefaults.standard.set(newCode, forKey: "house")
            } catch { print("Error creating house") }
            return false
        }
        else{
            self.shouldNavigate = true
            do{
                //return true
                FirebaseApp.configure()
                let db = Firestore.firestore()
                let docRef = db.collection("house").document(code)
                let document = try await docRef.getDocument()
                if document.exists {
                    UserDefaults.standard.set(code, forKey: "house")
                } else { print("House does not exist") }
                
            } catch { print("Error finding house") }
            return true
        }
        return false
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Join or Create a House")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                    
                
                TextField("Leave blank to create", text: $identifier)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20) // Corrected padding

                Button(action:{
                    Task{
                        let hasHouse = await houseSetup(code: identifier)
                        
                        if(hasHouse){
                            NavigationLink(destination: homePage(), isActive: $shouldNavigate) {
                                homePage()
                            }
                        }
                        else{
                            NavigationLink(destination: homePage(), isActive: $shouldNavigate) {
                                houseCode()
                            }
                            
                        }}
                    }) {
                    Text("Join/Create")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
            }
            .padding()
            
        }
    }
}




struct HouseSetup_Previews: PreviewProvider {
    static var previews: some View {
        houseSetup()
    }
}
