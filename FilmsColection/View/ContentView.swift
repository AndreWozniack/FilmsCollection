import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        if authViewModel.isUserAuthenticated {
            MainView()
        } else {
            AppleLoginView()
        }
    }
}


#Preview {
    ContentView()
}
