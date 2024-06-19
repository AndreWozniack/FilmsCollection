import Foundation

class Film: Identifiable, Codable {
    var id = UUID()
    let idFilme: Int32
    let title: String
    var image: String
    let releaseDate: String
    let originalTitle: String?
    let duration: Int
    let plot: String
    var rating: Double
    var userRating: Double?
    var notes: String?
    
    init(idFilme: Int32, title: String, image: String, releaseDate: String, originalTitle: String?, duration: Int, plot: String, rating: Double, userRating: Double? = nil, notes: String? = nil) {
        self.idFilme = idFilme
        self.title = title
        self.image = image
        self.releaseDate = releaseDate
        self.originalTitle = originalTitle
        self.duration = duration
        self.plot = plot
        self.rating = rating
        self.userRating = userRating
        self.notes = notes
    }
    
    var description: String {
        var desc = "Film Title: \(title)\n"
        desc += "ID: \(idFilme)\n"
        desc += "Original Title: \(originalTitle ?? "N/A")\n"
        desc += "Release Date: \(releaseDate)\n"
        desc += "Duration: \(duration) minutes\n"
        desc += "Rating: \(rating)/10\n"
        if let userRating = userRating {
            desc += "User Rating: \(userRating)/10\n"
        }
        if let notes = notes, !notes.isEmpty {
            desc += "Notes: \(notes)\n"
        }
        return desc
    }
}
