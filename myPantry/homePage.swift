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
    @State private var primaryIngredientFinal: [String] = []
    @State private var expirationDateFinal: [String] = []
    @State private var didAlreadyAppear = false
    @State private var houseCode: String = ""
    
    
    
    
    func parseIngredients() {
        //for some reason on appear gets called multiple times
        primaryIngredient.removeAll()
        expirationDate.removeAll()
        primaryIngredientFinal.removeAll()
        expirationDateFinal.removeAll()
        
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
        if primaryIngredient.count != expirationDate.count {
            print("FUCK ERROR")
        }else{
            print("yay same length")
        }
    }

    
    func goToCameraView() {
        didAlreadyAppear = false
        self.navigateToCameraView = true
    }
    
    func goToRecipes() {
        didAlreadyAppear = false
        self.navigateToRecipes = true
    }
    
    func getIngredients() {
        Task {
            do {
                print("StartinggetIngredients...")
                let db = Firestore.firestore()
                print("houseCode \(houseCode)")
                let docRef = db.collection("house").document(houseCode)
                
                let document = try await docRef.getDocument()
                if document.exists {
                    let data = document.data().map(String.init(describing:)) ?? "nil"
                    print("data \(data)")
                    ingredients = data
                    print("ingredients \(ingredients)")
                    
                    parseIngredients()
                    primaryIngredientFinal = primaryIngredient
                    expirationDateFinal = expirationDate
                    print("testPrint")
                    print(primaryIngredient)
                    print(expirationDate)
                    print(primaryIngredientFinal.count)
                    print(expirationDateFinal.count)
                    

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
                HStack (alignment: .center){
                    
                    Button("Add", action: goToCameraView)
                        .neumorphicButtonModifier()
                    
//                    {
//                        Text("Add")
//                            
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .frame(width: 70, height: 70)
//                            .background(Color.blue)
//                            //.clipShape(Circle())
//                            //.overlay(Circle().stroke(Color.white, lineWidth: 2))
//                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("House Code:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(houseCode)
                    }
                    Spacer()
                    Button("Recipes", action: goToRecipes)
                        .neumorphicButtonModifier()
                        
//                    {
//                        Text("Recipes")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .frame(width: 70, height: 70)
//                            .background(Color.blue)
//                            .clipShape(Circle())
//                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
//                    }
                    
                    //.frame(maxWidth:300)
                
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        ForEach(Array(zip(primaryIngredientFinal.indices, primaryIngredientFinal)), id: \.0) { index, ingredient in
                            HStack {
                                Text(ingredient)
                                    .font(.headline)
                                Spacer()
                                VStack(alignment: .trailing) {  // Align text to the right
                                    Text("Expire Date:")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    if(index < expirationDateFinal.count){
                                        Text(expirationDateFinal[index])
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("03-27-2025")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding()
                        }
                        Spacer() // Pushes all content to the top
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure ScrollView expands to fill available space
                .edgesIgnoringSafeArea(.all) // Optional: Allows the ScrollView to extend to the edges of the screen



                
            
                //Spacer()
                
                
                if navigateToCameraView {
                    NavigationLink(destination: CameraView(), isActive: $navigateToCameraView) {
                        CameraView()
                    }
                }
                if navigateToRecipes {
                    NavigationLink(destination: recipes(), isActive: $navigateToRecipes) {
                        recipes()
                    }
                }
            }
        }
        
        .onAppear {
            if !didAlreadyAppear {
                print("running homePage onAppear")
                didAlreadyAppear = true
                getIngredients()
                houseCode = UserDefaults.standard.string(forKey: "house") ?? "123456"
                print("houseCode \(houseCode)")
            }
        }


    }
}

struct homePagePreview: PreviewProvider {
    static var previews: some View {
        homePage()
    }
}
