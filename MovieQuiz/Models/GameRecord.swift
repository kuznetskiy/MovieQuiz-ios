import UIKit

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func comparisonCorrect(currentGame: GameRecord) -> Bool {
        self.correct > currentGame.correct
    }
}
