//
//  ViewController.swift
//  iCalc
//
//  Created by Nick Scott on 27/01/2016.
//  Copyright © 2016 Nick Scott. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    var userIsTypingNumber = false
    
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
        let operation = sender.currentTitle!
        if userIsTypingNumber {
            enter()
        }
        /**
            standford swift 2/17@34:55
            let's get crazy
            strictly speaking, performOperation form should be:
            performOperation( { (op1:Double, op2:Double) -> Double in
                return op1 * op2
            })
            Note the open brace has moved to the start and been replaced with 'in'
            However:
                swift knows the function signature, so we don't need the types,
                note the return keyword has gone aswell as it's a one liner.
            performOperation( { (op1,op2) in op1 * op2 })
                next don't have to name arguments, so {$0 * $1} will suffice.
                finally, last argument can go after the () and as there are no
                args inside the (), we can drop them aswell:
            performOperation { $0 * $1 }
        */
        switch operation {
        case "✖️": performOperation { $0 * $1}
        case "➗": performOperation { $1 / $0}
        case "➕": performOperation { $0 + $1}
        case "➖": performOperation { $1 - $0}
        case "✔️": performOperation { sqrt($0)}
            default: break
        }
    }
    func performOperation( operation: (Double, Double) -> Double){
        if operandStack.count >= 2 {
            displayValue = operation( operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    // note once argument doesn't attract brackets
    // oopsie here, object-c compiler complaint, fixes:
    //    @objc(methodTow:)
    //    func methodOne(par1) {...}
    // or
    //    @nonobjc
    //    func methodOne() {...}
    @nonobjc
    func performOperation( operation: Double -> Double){
        if operandStack.count >= 1 {
            displayValue = operation( operandStack.removeLast())
            enter()
        }
    }
    
    var operandStack = Array<Double>()
    
    @IBAction func enter() {
        userIsTypingNumber = false
        operandStack.append( displayValue)
        print( "operandStack : \(operandStack)")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

