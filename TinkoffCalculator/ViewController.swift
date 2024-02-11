//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Дмитрий Яковлев on 04.02.2024.
//

import UIKit

enum CalculationError: Error {
    case divideByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "х"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .substract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.divideByZero
            }
          return  number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    let calculationHistoryStorage = CalculationHistoryStorage()
    
    private let alertView: AlertView = {
        let screenBounds = UIScreen.main.bounds
        let alertHeight: CGFloat = 100
        let alertWidth: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - alertWidth / 2
        let y: CGFloat = screenBounds.height / 2 - alertHeight / 2
        let alertFrame = CGRect(x: x, y: y, width: alertWidth, height: alertHeight)
        let alertView = AlertView(frame: alertFrame)
        return alertView
    }()
    
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        
        return numberFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetLabelText()
        calculations = calculationHistoryStorage.loadHistory()
        
        view.addSubview(alertView)
        alertView.alpha = 0
        alertView.alertText = "You have found the Easter Egg!"
        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        guard let buttonText = sender.currentTitle else { return }
        
        switch buttonText {
        case "," where label.text == "0":
            label.text = "0,"
        case "," where label.text?.contains(",") == true:
            return
        case "+ / -":
            guard let text = label.text,
                  text != "0" else {
                  return
              }
              if !text.contains("-") {
                  label.text = "-" + text
              } else {
                  label.text = text.replacingOccurrences(of: "-", with: "")
              }
            
        case "π":
            guard let text = label.text,
                  let pi = Int(text),
                  pi > 0 else {
                return
            }
            label.text = calculatePi(number: pi)
            
        default:
            if label.text == "0" || label.text == "Error" {
                label.text = buttonText
            } else {
                let count = label.text?.filter { $0 != " " }.count ?? 0
                if count < 15 {
                    label.text?.append(buttonText)
                }
            }
        }
        
        if label.text == "3,141592" {
            animateAlert()
        }
        sender.animateTap()
    }

    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard 
            let buttonText = sender.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
            else { return }
        
        guard 
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
        
        resetLabelText()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        
        resetLabelText()
    }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc =  calculationsListVC as? CalculationListViewController {
            vc.calculations = calculations
        }
        
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    @IBAction func calculateButtonPressed() {
        guard
            let labelText = label.text,
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            label.text = numberFormatter.string(from: NSNumber(value: result))
            
            let newCalculation = Calculation(expression: calculationHistory, result: result, date: NSDate() as Date)
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
        } catch {
            label.text = "Error"
            label.shake()
        }
        
        calculationHistory.removeAll()
    }
    
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        
        var currentResult = firstNumber
        
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard 
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
                else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        return currentResult
    }

    func resetLabelText() {
        label.text = "0"
    }
    
    func calculatePi(number n: Int) -> String {
        let π = Double.pi
        return String(format: "%.\(n)f", π)
    }

    func animateAlert() {
        if !view.contains(alertView) {
            alertView.alpha = 0
            alertView.center = view.center
            view.addSubview(alertView)
        }
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.2) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.alertView.alpha = 1
            }
        }
    }
}

extension UILabel {
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x, y: center.y))
        
        layer.add(animation, forKey: "position")
    }
}

extension UIButton {
    func animateTap() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.98, 1]
        scaleAnimation.keyTimes = [0, 0.1, 1]
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.4, 0.8, 1]
        opacityAnimation.keyTimes = [0, 0.1, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        
        layer.add(animationGroup, forKey: "groupAnimation ")
    }
}

