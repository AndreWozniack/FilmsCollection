import SwiftUI

struct FilmDetail: View {
    @State var conteudo: Film
//    @ObservedObject private var dataManager = DataManager.shared
    
    var ratingAsStars: Int {
        return Int((Double(conteudo.rating) ) / 2.0 + 0.5)
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: -25){
                AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/original\(conteudo.image)")) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Rectangle()
                            .opacity(0)
                            .frame(width: 390, height: 600)
                    } else {
                        Rectangle()
                            .opacity(0)
                            .frame(width: 390, height: 600)
                        
                    }
                }
                VStack(alignment: .leading, spacing: 19){
                    HStack{
                        VStack(alignment: .leading, spacing: 5){
                            Text(conteudo.title)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .padding(.top)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            HStack {
                                ForEach(0..<ratingAsStars, id: \.self) { _ in
                                    Text(.init(systemName: "star.fill"))
                                        .foregroundColor(.orange)
                                        .font(.system(size: 14))
                                }
                                ForEach(0..<(5-ratingAsStars), id: \.self) { _ in
                                    Text(.init(systemName: "star"))
                                        .foregroundColor(.orange)
                                        .font(.system(size: 14))
                                }
                            }
                        }


                        
                    }
                    .padding(.horizontal, 30)
                    HStack(spacing: 10){
                        HStack{
                            Text(.init(systemName: "clock"))
                                .font(Font.custom("SF Pro", size: 14))
                                .foregroundColor(.white)
                            Text("\(conteudo.duration) min")
                                .font(Font.custom("SF Pro", size: 14))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                        }
                        .padding(.vertical, 9)
                        .padding(.horizontal, 10)
                        .background(Rectangle()
                            .foregroundColor(.clear)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.5)
                                    .stroke(Color.white, lineWidth: 1)
                            ))
                        Text(conteudo.releaseDate)
                            .font(Font.custom("SF Pro", size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.vertical, 9)
                            .padding(.horizontal, 20)
                            .background(Rectangle()
                                .foregroundColor(.clear)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.5)
                                        .stroke(Color.white, lineWidth: 1)
                                ))
                        
                        Spacer()
                    }.padding(.leading, 30)
                    Text(conteudo.plot)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .padding(.horizontal, 30)
                    
                    
                    Spacer()
                }.background(Rectangle()
                    .foregroundColor(.black)
                    .cornerRadius(28))
            }
        }
        .edgesIgnoringSafeArea([.top])
        .background(.black)
    }
}


struct FilmDetail_Previews: PreviewProvider {
    static var previews: some View {
        FilmDetail(conteudo: Film(idFilme: 19995, title: "Avatar", image: "/iNMP8uzV2Ing6ZCw0IICgEFVNfC.jpg", releaseDate: "2009-12-15", originalTitle: nil, duration: 162, plot: "Apesar de confinado a uma cadeira de rodas, Jake Sully, um ex-marine, continua a ser um combatente. Assim, é recrutado para uma missão a Pandora, um corpo celeste que orbita um enorme planeta gasoso, para explorar um mineral alternativo chamado Unobtainium, usado na Terra como recurso energético. Porém, devido ao facto de a atmosfera de Pandora ser altamente tóxica para os humanos, é usado um programa de avatares híbridos, que possibilita a transferência da mente de qualquer humano para um corpo nativo.", rating: 7.571, favorite: false, watched: false))
    }
}
