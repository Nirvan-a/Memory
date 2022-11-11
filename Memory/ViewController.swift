//
//  ViewController.swift
//  ElementQuiz
//
//  Created by nirvana on 2022/5/2.
//

import UIKit
//定义记忆和检测模式
enum Mode {
    case flashCard
    case quiz
}
//定义检测模式下三种子模式：问题/答案/分数
enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var modeSelector: UISegmentedControl!
    @IBOutlet var textField: UITextField!
    @IBOutlet var showAnswerButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    
    //元素名，也是image名
    let fixedElementList = ["Mario","Spider-Man","Minions","ToyStory"]
    var elementList: [String] = []
    //记录展示索引
    var currentElementIndex = 0
    
    //定义模式决定UI更新界面
    var mode: Mode = .flashCard {
        didSet {
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            updateUI()
        }
    }
    
    func setupFlashCards() {
        elementList = fixedElementList
        state = .question
        currentElementIndex = 0
    }
    
    func setupQuiz() {
        elementList = fixedElementList.shuffled()
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }
    
    var state: State = .question

    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
        
        updateUI()
    }
    //updates the app's UI based on its mode and state
    func updateUI() {
        //根据索引展示image
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
    
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizeUI(elementName: elementName)
        }
    }
    func updateFlashCardUI(elementName: String) {
        
        textField.isHidden = true
        textField.resignFirstResponder()
        
        if state == .answer {
            answerLabel.text = elementName
        }else {
            answerLabel.text = "?"
        }
        modeSelector.selectedSegmentIndex = 0
        
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
    }
    func updateQuizeUI(elementName: String) {
        textField.isHidden = false
        
        switch state {
        case .question:
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        switch state {
        case .question:
            answerLabel.text = ""
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            }else {
                answerLabel.text = "❌\n Answer: \(elementName)"
            }
        case .score:
            answerLabel.text = ""
        }
        if state == .score {
            displayScoreAlert()
        }
        
        //modeSelector.selectedSegmentIndex = 1
        showAnswerButton.isHidden = true
        
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        }else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        
        textField.isHidden = false
        switch state {
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
    }

    @IBAction func showAnswer(_ sender: Any) {
        state = .answer
        updateUI()
    }
    
    @IBAction func next(_ sender: Any) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        updateUI()
    }
    
    @IBAction func switchMode(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        }else {
            mode = .quiz
        }
    }
    //run after the user hit "Return"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldContents = textField.text!
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        }else {
            answerIsCorrect = false
        }
        state = .answer
        updateUI()
        return true
    }
    
    
    
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quize Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count)", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
}

