import Foundation
import SwiftUI

struct FilmListView: View {
    @State private var searchText = ""
    @State private var films = [Film]()
    @State private var isLoading = false
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var showingAddToList = false
    @State private var filmLists: [String] = []
    @State private var selectedList: String? = nil
    @State private var newListName: String = ""

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: loadFilms)
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(.circular)
                    Spacer()
                } else {
                    List(films) { film in
                        NavigationLink(destination: FilmDetail(conteudo: film)) {
                            FilmCardList(title: film.title, releaseDate: film.releaseDate, imageUrl: film.image)
                                
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                saveFilm(film)
                            } label: {
                                Label("Save", systemImage: "star.fill")
                            }
                            .tint(.yellow)
                        }
                    }
                }
            }
            .navigationTitle("Search Movies")
        }
        .onAppear {
            if searchText.isEmpty {
                loadPopularFilms()
            }
        }
    }
    


    
    func loadFilms(query: String) {
        if query.isEmpty {
            loadPopularFilms()
            return
        }
        isLoading = true
        searchTask?.cancel()
        searchTask = Task {
            self.films = await FilmDataManager.shared.findFilms(query: query)
            isLoading = false
        }
    }
    
    func loadPopularFilms() {
        isLoading = true
        searchTask?.cancel()
        searchTask = Task {
            self.films = await FilmDataManager.shared.fetchPopularFilms()
            isLoading = false
        }
    }
    
    func saveFilm(_ film: Film) {
        FilmDataManager.shared.saveFilm(film) { success in
            if success {
                print("Film saved successfully")
            } else {
                print("Failed to save film")
            }
        }
    }
}

