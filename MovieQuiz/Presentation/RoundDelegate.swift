import UIKit

protocol RoundDelegate: AnyObject {
    func didReceiveNewQuestion(_ question: QuizQuestion?)
    func roundDidEnd(_ round: RoundManager, withResult gameRecord: GameRecord)
}
