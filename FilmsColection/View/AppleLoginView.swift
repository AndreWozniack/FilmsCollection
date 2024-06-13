import Foundation
import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit

struct AppleLoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var currentNonce: String? = nil
    @State private var isAuthenticated = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            if isAuthenticated {
                ContentView()
            } else {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: configureRequest,
                    onCompletion: handleAuthorization
                )
                .signInWithAppleButtonStyle(.black)
                .frame(width: 280, height: 50)
                .padding()
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Authentication Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    private func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    private func handleAuthorization(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.alertMessage = "Invalid response from Apple ID credential"
                self.showingAlert = true
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    self.alertMessage = "Firebase authentication error: \(error.localizedDescription)"
                    self.showingAlert = true
                } else {
                    self.isAuthenticated = true // Atualiza o estado para autenticado
                }
            }
        case .failure(let error):
            alertMessage = "Authentication failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

#Preview {
    AppleLoginView()
}
