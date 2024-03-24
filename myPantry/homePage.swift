import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import Foundation



struct homePage: View {
    @State private var navigateToCameraView = false
    @State private var navigateToRecipes = false
    @State private var ingredients: String = ""
    @State private var primaryIngredient: [String] = []
    @State private var expirationDate: [String] = []
    
    let k = 0;

    
    
    
    
    let houseCode = "123456"
    
    
    func parseIngredients() {
        //for some reason on appear gets called multiple times
        primaryIngredient.removeAll()
        expirationDate.removeAll()
        
        let trimmedString = ingredients.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
        let components = trimmedString.components(separatedBy: ", ")

        var parsedIngredients: [String: String] = [:]

        
        for component in components {
            let itemComponents = component.components(separatedBy: ": ")
            if itemComponents.count == 2 {
                let key = itemComponents[0].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                let value = itemComponents[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                parsedIngredients[key] = value
            }
        }

        for (key, value) in parsedIngredients {
            primaryIngredient.append(key)
            expirationDate.append(value)
        }
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
                print("StartinggetIngredients...")
                FirebaseApp.configure()
                let db = Firestore.firestore()
                
                let docRef = db.collection("house").document(houseCode)
                
                let document = try await docRef.getDocument()
                if document.exists {
                    let data = document.data().map(String.init(describing:)) ?? "nil"
                    ingredients = data
                    parseIngredients()
                    print(primaryIngredient)
                    print(expirationDate)

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
