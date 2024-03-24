import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

struct homePage: View {
    @State private var navigateToCameraView = false
    @State private var navigateToRecipes = false
    @State private var ingredients = ""
    @State private var primaryIngredient = ""
    @State private var expirationData = ""
    
    
    
    
    let houseCode = "123456"
    
    
    func parseIngredients(){
        
        
    }
    
    func goToCameraView() {
        self.navigateToCameraView = true
    }
    
    func goToRecipes() {
        self.navigateToRecipes = true
    }
    
    func getIngredients() {
        Task {
            do {
                print("Starting getIngredients...")
                FirebaseApp.configure()
                let db = Firestore.firestore()
                
                let docRef = db.collection("house").document(houseCode)
                
                let document = try await docRef.getDocument()
                if document.exists {
                    let data = document.data().map(String.init(describing:)) ?? "nil"
                    ingredients = data
                    parseIngredients()
                    print(primaryIngredient)
                    print(expirationData)
                    print("yo")
                } else {
                    print("house does not exist (shouldn't happen)")
                }
                
            } catch {
                print("error in getIngredients")
            }
        }
    }
    
//    let houseCode = UserDefaults.standard.string(forKey: "house") ?? "couldn't find any identifier"
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: goToCameraView) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    VStack(alignment: .leading) {
                        Text("House Code:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(houseCode)
                    }
                    Button(action: goToRecipes) {
                        Text("Recipe")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                Spacer()
                if navigateToCameraView {
                    NavigationLink(destination: CameraView(), isActive: $navigateToCameraView) {
                        EmptyView()
                    }
                }
                if navigateToRecipes {
                    NavigationLink(destination: recipes(), isActive: $navigateToRecipes) {
                        EmptyView()
                    }
                }
            }
        }
        .onAppear{
            getIngredients()
        }
    }
}

struct homePagePreview: PreviewProvider {
    static var previews: some View {
        homePage()
    }
}
