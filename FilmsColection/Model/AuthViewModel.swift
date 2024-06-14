import SwiftUI
import FirebaseAuth
import Foundation


class AuthViewModel: ObservableObject {
    @Published var isUserAuthenticated = false
    @Published var user: User?

    init() {
        self.checkAuthentication()
    }

    func checkAuthentication() {
        if let currentUser = Auth.auth().currentUser {
            self.user = currentUser
            self.isUserAuthenticated = true
        } else {
            self.isUserAuthenticated = false
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let user = authResult?.user {
                self?.user = user
                self?.isUserAuthenticated = true
            } else {
                print("Error signing in: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isUserAuthenticated = false
            self.user = nil
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
}
