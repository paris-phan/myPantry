import SwiftUI

struct authVerif: View {
    @State private var verificationCode: String = ""
    @State private var shouldNavigate = false
    
    func verifyCode() {
        //
        //verification logic
        //
        nextPage()
    }
    
    func nextPage() {
        self.shouldNavigate = true
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Please enter your verification code")
                    .font(.title)
                    .padding()
                
                TextField("Verification Code", text: $verificationCode)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding()
                
                Button(action: verifyCode) {
                    Text("Verify")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                NavigationLink(destination: homePage(), isActive: $shouldNavigate) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}

struct AuthVerif_Previews: PreviewProvider {
    static var previews: some View {
        authVerif()
    }
}
