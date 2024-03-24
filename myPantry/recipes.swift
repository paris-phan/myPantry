import SwiftUI

struct recipes: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("My Recipes")
                .font(.largeTitle)

            Text("Discover and save your favorite recipes here!")
                .font(.body)
                .padding(.bottom, 5)
            Text("My Recipes")
                .font(.largeTitle)
                
            Text("Discover and save your favorite recipes here!")
                .font(.body)
                .padding(.bottom, 5)
            
            Text("My Recipes")
                .font(.largeTitle)
            
            Text("Discover and save your favorite recipes here!")
                .font(.body)
                .padding(.bottom, 5)

                
            Spacer()
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .topLeading)
    }
}

struct recipes_preview: PreviewProvider {
    static var previews: some View {
        recipes()
    }
}
