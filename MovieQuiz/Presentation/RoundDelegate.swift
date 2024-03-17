import UIKit

protocol RoundDelegate: AnyObject {
    func didReceiveNewQuestion(_ question: QuizQuestion?)
    func roundDidEnd(_ round: Round, withResult gameRecord: GameRecord)
}
