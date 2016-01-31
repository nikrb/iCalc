//
//  ViewController.swift
//  iCalc
//
//  Created by Nick Scott on 27/01/2016.
//  Copyright © 2016 Nick Scott. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var dot_used = false
    @IBOutlet weak var display: UILabel!
    
    var userIsTypingNumber = false
    var brain = CalculatorBrain()
    
    @IBAction func clear() {
        display.text = "0"
        userIsTypingNumber = false
        dot_used = false
    }
    
    @IBAction func appendDot() {
        if dot_used == false {
            dot_used = true
            if userIsTypingNumber {
                display.text = display.text! + "."
            } else {
                display.text = "0."
            }
            userIsTypingNumber = true
        }
    }
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTypingNumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsTypingNumber = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsTypingNumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
    }
    
    @IBAction func enter() {
        userIsTypingNumber = false
        dot_used = false
        if let result = brain.pushOperand( displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    var displayValue: Double {
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            display.text = "\(newValue)"
            userIsTypingNumber = false
        }
    }
}

