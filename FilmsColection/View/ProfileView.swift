//
//  ProfileView.swift
//  FilmsColection
//
//  Created by André Wozniack on 13/06/24.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var films: [Film] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            VStack {
                Image("perfil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 94)
                    .padding(.top, 20)
                
                Text("Meu Perfil")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                    .foregroundColor(.orange)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    List(films, id: \.id) { film in
                        NavigationLink(destination: FilmDetail(conteudo: film)) {
                            FilmCardList(title: film.title, releaseDate: film.releaseDate, imageUrl: film.image)
                                .contextMenu {
                                    Button(action: {
                                        deleteFilm(film)
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteFilm(film)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                loadFilms()
            }
        }
    }

    func deleteFilm(_ film: Film) {
        FilmDataManager.shared.deleteFilm(film) { success in
            if success {
                print("Film deleted successfully")
                // Atualize a lista local de filmes
                if let index = films.firstIndex(where: { $0.id == film.id }) {
                    films.remove(at: index)
                }
            } else {
                print("Failed to delete film")
            }
        }
    }
    private func loadFilms() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not logged in")
            return
        }

        isLoading = true
        FilmDataManager.shared.loadFilms(from: userId) { loadedFilms, error in
            if let films = loadedFilms {
                self.films = films
            } else if let error = error {
                print("Error loading films: \(error)")
            }
            isLoading = false
        }
    }
}

#Preview {
    ProfileView()
}
