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
        case BinaryOperation( String, (Double, Double) -> Double)
        
        // computed properties only in a struct. No set function
        var description: String {
            get {
                switch self {
                case .Operand( let operand):
                    return "\(operand)"
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
        // provide a learn function for new ops and this simplifies init further
        func learnOp( op: Op) {
            knownOps[op.description] = op
        }
        // so just doing the first one
        learnOp( Op.BinaryOperation( "*", *))
        learnOp( Op.BinaryOperation( "/", /)) // { $1 / $0 })
        learnOp( Op.BinaryOperation( "+", +))
        learnOp( Op.BinaryOperation( "-", -)) // { $1 - $0 })
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
            let op = remainingOps.removeFirst()
            print( "@evaluate thisOp[\(op)] remainingOps[\(remainingOps)]")
            switch op {
            case .Operand( let operand):
                print("@evaluate Operand[\(operand)]")
                return (operand, remainingOps)
            case .BinaryOperation( let tor, let operation):
                print("@evaluate BinaryOp tor[\(tor)] op[\(operation)]")
                let op1Evaluation = evaluate( remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate( op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation( operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        // default return
        return (nil, ops)
    }
    
    // return has to be optional to cover misuse, e.g. + followed by evaluate
    func evaluate() -> Double? {
        var last_operand:Double = 0
        var last_op:Op? = nil
        if( opStack.count > 0) {
            for op in opStack {
                switch op{
                case .Operand(let operand):
                    if (last_op == nil) {
                        last_operand = operand
                    } else {
                        switch last_op! {
                        case .BinaryOperation( _, let operation):
                            last_operand = operation( last_operand, operand)
                            last_op = nil
                        default: break
                        }

                    }
                case .BinaryOperation( _, _):
                    last_op = op
                }
            }
        }

        print("opStack[\(opStack)]")
        // setting a tuple (to a returned tuple.)
        // let (result, remainder) = evaluate( opStack)
        // print( "\(opStack) = \(result) with \(remainder) left over")
        return last_operand
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