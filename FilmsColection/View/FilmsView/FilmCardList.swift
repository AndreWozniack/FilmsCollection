import Foundation
import SwiftUI

struct FilmCardList: View {
    let title: String
    let releaseDate: String
    let imageUrl: String
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()
    
    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 70, height: 105)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0), location: 0.00),
                            Gradient.Stop(color: .black, location: 0.98),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1)
                    )
                )
                .opacity(0.3)
            
                .background(Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 95, height: 142)
                    .background(
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(imageUrl)")) { phase in
                            if let image = phase.image {
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                
                            } else if phase.error != nil {
                                Image("error")
                                    .resizable()
                                    .scaledToFit()
                            } else {
                                ProgressView()
                                
                            }
                        }
                            .frame(width: 70, height: 105)
                            .clipped()
                    ))
                

            VStack(alignment: .leading, spacing: 8){
                Text(title)
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                Text(releaseDate)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
            .padding()
            Spacer()
        }
        .padding(.leading)
        .frame(maxWidth: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    FilmCardList(title: "Forest Gump: O Contador de Histórias", releaseDate: "2009-12-15", imageUrl: "/iNMP8uzV2Ing6ZCw0IICgEFVNfC.jpg")
}
