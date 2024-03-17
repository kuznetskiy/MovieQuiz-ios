import UIKit

protocol StatisticService {
    func store(currentRound: Round)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}
