import SwiftUI

struct recipes: View {
    var body: some View {
        VStack(alignment: .leading){
            Text("My Recipes")
                .font(.largeTitle)
                .padding(.bottom, 10)
            Text("Discover and save your favorite recipes here!")
                .font(.body)
                .padding(.horizontal)
            Text("My Recipes")
                .font(.largeTitle)
                .padding(.bottom, 10)

            Text("Discover and save your favorite recipes here!")
                .font(.body)
                .padding(.horizontal)
            Text("My Recipes")
                .font(.largeTitle)
                .padding(.bottom, 10)

            Text("Discover and save your favorite recipes here!")
                .font(.body)
                .padding(.horizontal)
        }
        .padding()
        .frame(alignment: .topLeading)
    }
    
}

struct recipes_preview: PreviewProvider {
    static var previews: some View {
        recipes()
    }
}
