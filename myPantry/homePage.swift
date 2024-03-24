import SwiftUI




struct homePage: View {
    @State private var shouldNavigate = false
    
    
    
    let houseCode = UserDefaults.standard.string(forKey: "house") ?? "couldn't find any identifier"
    
    func addReceipt() {
        self.shouldNavigate = true//sets to true so that can go to img page
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: addReceipt) {
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
                }
                .padding()
                Spacer()
                NavigationLink(destination: CameraView(), isActive: $shouldNavigate) {
                    EmptyView()
                }
            }
        }
    }
}

struct homePagePreview: PreviewProvider {
    static var previews: some View {
        homePage()
    }
}
