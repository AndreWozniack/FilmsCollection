import Foundation
import FirebaseFirestore
import FirebaseAuth
import Network

class FilmDataManager {
    static let shared = FilmDataManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func findFilms(query: String) async -> [Film] {
        let languageCode = determineLanguageCode()
        
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        let searchURLString = "https://api.themoviedb.org/3/search/movie?query=\(queryEncoded)&include_adult=false&language=\(languageCode)&page=1"
        
        guard let searchURL = URL(string: searchURLString) else {
            print("Invalid URL")
            return []
        }
        
        var searchRequest = URLRequest(url: searchURL, timeoutInterval: Double.infinity)
        searchRequest.addValue("Bearer \(Secrets.TMDB_API_KEY)", forHTTPHeaderField: "Authorization")
        searchRequest.addValue("application/json", forHTTPHeaderField: "accept")
        searchRequest.httpMethod = "GET"
        
        do {
            let (data, _) = try await URLSession.shared.data(for: searchRequest)
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(SearchResponse.self, from: data)
            
            var films = [Film]()
            for result in searchResponse.results {
                if let film = await fetchFilmDetail(for: result.id, languageCode: languageCode) {
                    films.append(film)
                }
            }
            return films
        } catch {
            print("Error during film search: \(error)")
            return []
        }
    }
    func fetchPopularFilms(page: Int = 1) async -> [Film] {
        var components = URLComponents(string: "https://api.themoviedb.org/3/movie/popular")!
        components.queryItems = [
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("Bearer \(Secrets.TMDB_API_KEY)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(SearchResponse.self, from: data)
            
            var films = [Film]()
            for result in searchResponse.results {
                if let film = await fetchFilmDetail(for: result.id, languageCode: "en-US") {
                    films.append(film)
                }
            }
            return films
        } catch {
            print("Error during film search: \(error)")
            return []
        }
    }
    private func determineLanguageCode() -> String {
        guard let language = Locale.current.language.languageCode?.identifier else { return "en-US" }
        switch language {
        case "en":
            return "en-US"
        case "pt":
            return "pt-BR"
        default:
            return "en-US"
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
                rating: filmDetail.rating
                
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
            "userRating": film.userRating ?? 0,
            "notes": film.notes ?? ""
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
                        userRating: data["userRating"] as? Double ?? 0,
                        notes: data["notes"] as? String ?? ""
                    )
                    films.append(film)
                }
                completion(films, nil)
            }
        }
    }
    
    func deleteFilm(_ film: Film, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Usuário não está logado.")
            completion(false)
            return
        }
        
        db.collection("users").document(userId).collection("films").document("\(film.idFilme)").delete { error in
            if let error = error {
                print("Erro ao deletar filme no Firestore: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    
}

