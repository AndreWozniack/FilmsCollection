//
//  Film.swift
//  FilmsColection
//
//  Created by André Wozniack on 13/06/24.
//

import Foundation


class FilmData: Identifiable, Codable{
    var id = UUID()
    let idFilme: Int32
    let title: String
    var image: String
    let releaseDate: String
    let originalTitle: String?
    let duration: Int
    let plot: String
    let rating : Double
    var favorite : Bool
    var watched : Bool
    
    init(idFilme: Int32, title: String, image: String, releaseDate: String, originalTitle: String?, duration: Int, plot: String, rating : Double, favorite : Bool, watched : Bool) {
        self.idFilme = idFilme
        self.title = title
        self.image = image
        self.releaseDate = releaseDate
        self.originalTitle = originalTitle
        self.duration = duration
        self.plot = plot
        self.rating = rating
        self.favorite = favorite
        self.watched = watched
    }
}
