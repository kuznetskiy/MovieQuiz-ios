import UIKit

protocol StatisticService {
    func store(currentRound: RoundManager)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}
