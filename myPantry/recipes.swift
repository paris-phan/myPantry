import SwiftUI
import GoogleGenerativeAI
import Firebase
import FirebaseCore
import FirebaseFirestore

struct recipes: View {
    
    @State private var firstRecipe = ""
    @State private var firstDesc = ""
    @State private var secondRecipe = ""
    @State private var secondDesc = ""
    @State private var ingredients: String = ""
    @State private var primaryIngredient: [String] = []
    @State private var expirationDate: [String] = []
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
    
    func getRecipes(){
        let config = GenerationConfig(
          temperature: 0.9,
          topP: 1,
          topK: 1,
          maxOutputTokens: 2048
        )

        // Don't check your API key into source control!
        let apiKey = "AIzaSyD8l8t4rw3kT61cLlVgiIporeV5L69Uino"
        

        let model = GenerativeModel(
          name: "gemini-1.0-pro",
          apiKey: apiKey,
          generationConfig: config,
          safetySettings: [
            SafetySetting(harmCategory: .harassment, threshold: .blockMediumAndAbove),
            SafetySetting(harmCategory: .hateSpeech, threshold: .blockMediumAndAbove),
            SafetySetting(harmCategory: .sexuallyExplicit, threshold: .blockMediumAndAbove),
            SafetySetting(harmCategory: .dangerousContent, threshold: .blockMediumAndAbove)
          ]
        )

        let chat = model.startChat(history: [

        ])

        Task {
          do {
            let message = "Given the following ingredients, come up with two recipes. Each recipe should have a title and ingredients list, separated by a colon : \n\nHere are the ingredients, \(primaryIngredient)"
            let response = try await chat.sendMessage(message)
            print(response.text ?? "No response received")
              
              let responseData = splitRecipes(from: response.text ?? "No response received")
              firstRecipe = responseData[0]
              firstDesc = responseData[1]
              secondRecipe = responseData[2]
              secondDesc = responseData[3]
          } catch {
            print(error)
          }
        }
    }
    
    func splitRecipes(from input: String) -> [String] {
        // Split the input string by the recipe number indicator, ignoring the first empty split
        let recipesSplit = input.components(separatedBy: "**Recipe ").dropFirst()
        var result: [String] = []
        
        for recipe in recipesSplit {
            // Further split each recipe by the first occurrence of "Ingredients:"
            if let rangeOfIngredients = recipe.range(of: "Ingredients:") {
                let title = String(recipe[..<rangeOfIngredients.lowerBound])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "\n**", with: "")  // Clean up the title
                let ingredients = String(recipe[rangeOfIngredients.lowerBound...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                // Append the cleaned title and ingredients to the result array
                result.append(title)
                result.append(ingredients)
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Recipes")
                .font(.largeTitle)

            Text("Discover and save your favorite recipes here!")
                .font(.body)
                .padding(.bottom, 5)
            Text(firstRecipe)
                .font(.largeTitle)
                
            Text(firstDesc)
                .font(.body)
                .padding(.bottom, 5)
            
            Text(secondRecipe)
                .font(.largeTitle)
            
            Text(secondDesc)
                .font(.body)
                .padding(.bottom, 5)

                
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .onAppear{
            getIngredients()
            getRecipes()
        }
    }
}

struct recipes_preview: PreviewProvider {
    static var previews: some View {
        recipes()
    }
}
