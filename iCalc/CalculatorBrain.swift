//
//  CalculatorBrain.swift
//  iCalc
//
//  Created by Nick Scott on 28/01/2016.
//  Copyright © 2016 Nick Scott. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case UnaryOperation( String, Double -> Double)
        case BinaryOperation( String, (Double, Double) -> Double)
        
        // computed properties only in a struct. No set function
        var description: String {
            get {
                switch self {
                case .Operand( let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    // var opStack = Array<Op>
    // preferred syntax
    private var opStack = [Op]()
    
    
    // var knownOps = Dictionary<String, Op>()
    // more preferred syntax
    private var knownOps = [String:Op]()
    
    // called when: let brain = CalculatorBrain
    init(){
        // we can simplify as * and + ARE functions, apparently, and the param order is not significant
        knownOps["✖️"] = Op.BinaryOperation( "✖️", *)
        knownOps["➗"] = Op.BinaryOperation( "➗") { $1 / $0 }
        knownOps["➕"] = Op.BinaryOperation( "➕", +)
        knownOps["➖"] = Op.BinaryOperation( "➖") { $1 - $0 }
        
        // knownOps["✔️"] = Op.UnaryOperation("✔️") { sqrt( $0) }
        // so, sqrt prototype takes single double and returns double, so ...
        knownOps["✔️"] = Op.UnaryOperation("✔️", sqrt)
    }
    
    // recusively consume stack. operand return immediately, operator requires another recursion
    // return tuple (name optional), we return the result and also the rest of the stack we haven't consumed
    // standford swift 3/17@40:30
    // has to be private because op is private
    private func evaluate( ops: [Op]) -> ( result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            // classes passed by reference, structs are passed by value so are immutable
            // Arrays and Dictionaries are structs, NOT classes
            // let op = ops.removeLast()
            // so to make ops mutable
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand( let operand):
                return (operand, remainingOps)
            // _ means I don't care
            case .UnaryOperation( _, let operation):
                let operandEvaluation = evaluate( remainingOps)
                // if this fails it falls through to bottom return
                if let operand = operandEvaluation.result {
                    return (operation( operand), operandEvaluation.remainingOps )
                }
            case .BinaryOperation( _, let operation):
                let op1Evaluation = evaluate( remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate( op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation( operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            // no need for default as we handle every case
            }
        }
        // default return
        return (nil, ops)
    }
    
    // return has to be optional to cover misuse, e.g. + followed by evaluate
    func evaluate() -> Double? {
        // setting a tuple (to a returned tuple.)
        let (result, remainder) = evaluate( opStack)
        print( "\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand( operand:Double) -> Double? {
        opStack.append( Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation( symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}