import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, RoundDelegate {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private let alertPresenter = AlertPresenter()
    private var currentRound: RoundManager?
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        alertPresenter.delegate = self
        startNewRound()
    }
    
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    private func setAnswerButtonsEnabled(_ enabled: Bool) {
        noButton.isEnabled = enabled
        yesButton.isEnabled = enabled
    }
    
    private func startNewRound() {
        showLoadingIndicator()
        currentRound = RoundManager()
        setAnswerButtonsEnabled(true)
        currentRound?.delegate = self
        currentRound?.requestNextQuestion()
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
    }
    
    func didReceiveNewQuestion(_ question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        showQuestion(quiz: convert(model: question))
        setAnswerButtonsEnabled(true)
    }
    
    func roundDidEnd(_ round: RoundManager, withResult gameRecord: GameRecord) {
        statisticService = StatisticServiceImplementation()
        showQuizResults()
    }
    
    func alertDidDismiss() {
        startNewRound()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func showQuizResults() {
        let model1 = statisticService
        let alertModel1 = convertToAlertModel(model: model1)
        alertPresenter.present(alertModel: alertModel1, on: self)
    }
    
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз")
        alertPresenter.present(alertModel: alertModel, on: self)
    }
    
    private func showQuestionAnswerResult(isCorrect: Bool) {
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        })
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        let isCorrect = currentRound?.checkAnswer(checkTap: false) ?? false
        showQuestionAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        let isCorrect = currentRound?.checkAnswer(checkTap: true) ?? false
        showQuestionAnswerResult(isCorrect: isCorrect)
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = currentRound?.getNumberCurrentQuestion() ?? 0
        let totalQuestions = currentRound?.getCountQuestions() ?? 0
        let displayNumber = questionNumber + 1
    
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(displayNumber) / \(totalQuestions)"
        )
    }
    
    private func convertToAlertModel(model: StatisticService?) -> AlertModel {
        guard let bestGame = model?.bestGame else {
            return AlertModel(title: "Ошибка", message: "Данные недоступны", buttonText: "ОК")
        }
    
        let gamesCount = model?.gamesCount ?? 0
        let gamesAccuracy = model?.totalAccuracy ?? 0.0
    
        let correctAnswers = currentRound?.getCorrectCountAnswer() ?? 0
        let totalQuestions = currentRound?.getCountQuestions() ?? 0
    
        let recordCorrect = bestGame.correct
        let recordTotal = bestGame.total
        let recordDate = bestGame.date
    
        let alertModel = AlertModel(
            title: "Раунд окончен",
            message: """
            Ваш результат: \(correctAnswers) / \(totalQuestions)
            Сыграно квизов: \(gamesCount)
            Рекорд: \(recordCorrect) / \(recordTotal) (\(recordDate.dateTimeString))
            Средняя точность: \(gamesAccuracy)%
            """,
            buttonText: "Повторить"
        )
    
        return alertModel
    }
    
    private func printAllUserDefaults() {
        let userDefaults = UserDefaults.standard
        print("All UserDefaults:")
        for (key, value) in userDefaults.dictionaryRepresentation() {
            print("\(key) = \(value)")
        }
    }
    
    private func remove() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
