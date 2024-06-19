import SwiftUI

struct StarRatingEditingView: View {
    @Binding var rating: Double
    var isEditable: Bool

    private let maximumRating = 5
    private let fullStarImage = "star.fill"
    private let halfStarImage = "star.lefthalf.fill"
    private let emptyStarImage = "star"

    func image(for index: Int) -> String {
        let starRating = rating / 2.0
        if Double(index + 1) <= starRating {
            return fullStarImage
        } else if Double(index) + 0.5 <= starRating {
            return halfStarImage
        } else {
            return emptyStarImage
        }
    }

    func star(index: Int) -> some View {
        let imageName = image(for: index)
        return Image(systemName: imageName)
            .foregroundColor(imageName == emptyStarImage ? .gray : .orange)
            .onTapGesture {
                if isEditable {
                    updateRating(index: index)
                }
            }
    }

    private func updateRating(index: Int) {
        let newRating = (Double(index) + 1) * 2.0

        if rating == newRating {
            rating = 0
        } else if rating == newRating - 1 {
            rating = newRating
        } else {
            rating = newRating - 1
        }
    }


    var body: some View {
        HStack {
            ForEach(0..<maximumRating, id: \.self) { index in
                star(index: index)
            }
        }
    }
}




#Preview {
    StarRatingEditingView(rating: .constant(1.5), isEditable: false)
}
