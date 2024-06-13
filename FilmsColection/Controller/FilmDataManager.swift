import Foundation
import FirebaseFirestore
import FirebaseAuth
import Network

class FilmDataManager {
    static let shared = FilmDataManager()
    private let db = Firestore.firestore()

    private init() {}
    
    func findFilmes(query: String) async -> Film? {
        let language = Locale.current.language.languageCode
        var languageCode = ""
        switch language {
        case "en":
            languageCode = "en-US"
        case "pt":
            languageCode = "pt-BR"
        case .none:
            languageCode = "en-US"
        case .some(_):
            languageCode = "en-US"
        }
        
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let searchURLString = "https://api.themoviedb.org/3/search/movie?query=\(queryEncoded)&include_adult=false&language=\(languageCode)&page=1"
        
        guard let searchURL = URL(string: searchURLString) else {
            print("Invalid URL")
            return nil
        }
        
        var searchRequest = URLRequest(url: searchURL, timeoutInterval: Double.infinity)
        searchRequest.addValue("Bearer \(Secrets.TMDB_API_KEY)", forHTTPHeaderField: "Authorization")
        searchRequest.addValue("application/json", forHTTPHeaderField: "accept")
        searchRequest.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: searchRequest)
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(SearchResponse.self, from: data)
            
            guard let firstResultId = searchResponse.results.first?.id else {
                print("No results found")
                return nil
            }
            
            return await fetchFilmDetail(for: firstResultId, languageCode: languageCode)
        } catch {
            print("Error during film search: \(error)")
            return nil
        }
    }
    
    private func fetchFilmDetail(for id: Int32, languageCode: String) async -> Film? {
        let detailURLString = "https://api.themoviedb.org/3/movie/\(id)?language=\(languageCode)"
        
        guard let detailURL = URL(string: detailURLString) else {
            print("Invalid URL")
            return nil
        }
        
        var detailRequest = URLRequest(url: detailURL, timeoutInterval: Double.infinity)
        detailRequest.addValue("Bearer \(Secrets.TMDB_API_KEY)", forHTTPHeaderField: "Authorization")
        detailRequest.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: detailRequest)
            let decoder = JSONDecoder()
            let filmDetail = try decoder.decode(FindResponse.self, from: data)
            
            return Film(
                idFilme: filmDetail.id,
                title: filmDetail.title,
                image: filmDetail.image,
                releaseDate: filmDetail.releaseDate,
                originalTitle: filmDetail.originalTitle,
                duration: filmDetail.duration,
                plot: filmDetail.plot,
                rating: filmDetail.rating,
                favorite: false,
                watched: false
            )
        } catch {
            print("Error fetching film detail: \(error)")
            return nil
        }
    }

    func saveFilm(_ film: Film, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            completion(false)
            return
        }
        
        let filmDict: [String: Any] = [
            "idFilme": film.idFilme,
            "title": film.title,
            "image": film.image,
            "releaseDate": film.releaseDate,
            "originalTitle": film.originalTitle ?? "",
            "duration": film.duration,
            "plot": film.plot,
            "rating": film.rating,
            "favorite": film.favorite,
            "watched": film.watched
        ]
        
        db.collection("users").document(userId).collection("films").document("\(film.idFilme)").setData(filmDict) { error in
            if let error = error {
                print("Erro ao salvar filme no Firestore: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    func loadFilms(from userId: String, completion: @escaping ([Film]?, Error?) -> Void) {
        db.collection("users").document(userId).collection("films").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
            } else if let documents = snapshot?.documents {
                var films = [Film]()
                for document in documents {
                    let data = document.data()
                    let film = Film(
                        idFilme: data["idFilme"] as? Int32 ?? 0,
                        title: data["title"] as? String ?? "",
                        image: data["image"] as? String ?? "",
                        releaseDate: data["releaseDate"] as? String ?? "",
                        originalTitle: data["originalTitle"] as? String,
                        duration: data["duration"] as? Int ?? 0,
                        plot: data["plot"] as? String ?? "",
                        rating: data["rating"] as? Double ?? 0.0,
                        favorite: data["favorite"] as? Bool ?? false,
                        watched: data["watched"] as? Bool ?? false
                    )
                    films.append(film)
                }
                completion(films, nil)
            }
        }
    }
}

