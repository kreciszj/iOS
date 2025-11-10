//
//  ViewController.swift
//  zadanie1
//
//  Created by Jakub Kręcisz on 10/11/2025.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var displayLabel: UILabel!
    
    var currentNumber: Double = 0
    var previousNumber: Double = 0
    var performingOperation: Bool = false
    var operation: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLabel.text = "0"
    }

    @IBAction func numberPressed(_ sender: UIButton) {
        // get the number
        guard let numberText = sender.currentTitle else { return }
        
        // if operation was performed, clear it
        if performingOperation {
            displayLabel.text = numberText
            performingOperation = false
        } else {
            if displayLabel.text == "0" {
                displayLabel.text = numberText
            } else {
                displayLabel.text = displayLabel.text! + numberText
            }
        }
        
        // update number
        currentNumber = Double(displayLabel.text!) ?? 0
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        displayLabel.text = "0"
        currentNumber = 0
        previousNumber = 0
        operation = ""
        performingOperation = false
    }
    
    @IBAction func operationPressed(_ sender: UIButton) {
        if operation != "" && !performingOperation {
            performCalculation()
        } else {
            previousNumber = currentNumber
        }
        
        operation = sender.currentTitle ?? ""
        performingOperation = true
    }
    
    @IBAction func equalsPressed(_ sender: UIButton) {
        performCalculation()
        operation = ""
    }
    
    func performCalculation() {
        var result: Double = 0
        
        switch operation {
        case "+":
            result = previousNumber + currentNumber
        case "−", "-":
            result = previousNumber - currentNumber
        case "×", "*":
            result = previousNumber * currentNumber
        case "÷", "/":
            if currentNumber != 0 {
                result = previousNumber / currentNumber
            } else {
                displayLabel.text = "Error"
                currentNumber = 0
                previousNumber = 0
                operation = ""
                return
            }
        default:
            result = currentNumber
        }
        
        displayLabel.text = formatResult(result)
        currentNumber = result
        previousNumber = result
    }
    
    func formatResult(_ number: Double) -> String {
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", number)
        } else {
            return String(number)
        }
    }
}
