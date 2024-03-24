import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter?
    private var presenter: MovieQuizPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        startNewRound()
    }
    
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    func setAnswerButtonsEnabled(_ enabled: Bool) {
        noButton.isEnabled = enabled
        yesButton.isEnabled = enabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showQuestionAnswerResult(isCorrect: Bool) {
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        })
    }
    
    func showQuizResults(model: AlertModel?) {
        guard let alertModel = model else {
            return
        }
        alertPresenter?.present(alertModel: alertModel, on: self)
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать ещё раз")
        alertPresenter?.present(alertModel: alertModel, on: self)
    }
    
    func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        presenter?.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        presenter?.yesButtonClicked()
    }
    
    private func startNewRound() {
        showLoadingIndicator()
        alertPresenter = AlertPresenter()
        alertPresenter?.delegate = self
        presenter = MovieQuizPresenter(viewController: self)
        setAnswerButtonsEnabled(true)
    }
    
    func alertDidDismiss() {
        startNewRound()
    }
}
