import Foundation

struct PopularFilmsResponse: Codable {
    let results: [FilmData]
}

struct FilmData: Codable {
    let id: Int32
    let title: String
    let poster_path: String
    let release_date: String
    let original_title: String?
    let runtime: Int?
    let overview: String
    let vote_average: Double
    
    func toFilm() -> Film {
        Film(
            idFilme: id,
            title: title,
            image: "https://image.tmdb.org/t/p/w500\(poster_path)",
            releaseDate: release_date,
            originalTitle: original_title,
            duration: runtime ?? 0,
            plot: overview,
            rating: vote_average
        )
    }
}
