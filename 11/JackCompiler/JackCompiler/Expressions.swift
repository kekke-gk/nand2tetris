//
//  Expressions.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

class Expression: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String {
        return "expression"
    }

    var terms: [Term] = []
    var ops: [Symbol] = []

    func compile(_ context: Context) throws {
        let term = try must(context, Term.self)
        terms.append(term)

        while let op = may(context, [Symbol.plus, .minus, .asterisk, .slash, .and, .or, .angleBracketL, .angleBracketR, .equal]) {
            let term = try must(context, Term.self)
            ops.append(op)
            terms.append(term)
        }
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        var code = ""

        for (i, term) in terms.enumerated() {
            code += try term.vmcode(varSymbolTable, funcSymbolTable)

            if i > 0 {
                switch ops[i-1] {
                case .plus:
                    code += "add"
                case .minus:
                    code += "sub"
                case .asterisk:
                    code += "call Math.multiply 2"
                case .slash:
                    code += "call Math.divide 2"
                case .and:
                    code += "and"
                case .or:
                    code += "or"
                case .angleBracketL:
                    code += "lt"
                case .angleBracketR:
                    code += "gt"
                case .equal:
                    code += "eq"
                default:
                    throw JackError.failedToCompile(0, "")
                }
                code += "\n"
            }
        }
        return code
    }
}

class ExpressionList: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String {
        return "expressionList"
    }

    var expressions: [Expression] = []

    func compile(_ context: Context) throws {
        if let expression = may(context, Expression.self) {
            expressions.append(expression)
            while let _ = may(context, [Symbol.comma]) {
                let expression = try must(context, Expression.self)
                expressions.append(expression)
            }
        }
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        var code = ""
        for expression in expressions {
            code += try expression.vmcode(varSymbolTable, funcSymbolTable)
        }
        return code
    }
}

class Term: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String {
        return "term"
    }

    var vmcodeFunc: ((VarSymbolTable, FuncSymbolTable) throws -> String)? = nil

    func compile(_ context: Context) throws {
        if let intConst = may(context, IntConst.self) {
            vmcodeFunc = { (_, _) in
                "push constant \(intConst.value())\n"
            }
            return
        }
        if let strConst = may(context, StrConst.self) {
            return
        }
        if let keyword = may(context, [Keyword.true_, .false_, .null_, .this_]) {
            let dict: [Keyword: String] = [
//                .true_: "constant 1\nneg",
                .true_: "constant 0\nnot",
                .false_: "constant 0",
                .null_: "constant 0",
                .this_: "pointer 0",
            ]
            vmcodeFunc = { (_, _) in
                "push \(dict[keyword]!)\n"
            }
            return
        }

        if let identifier = may(context, Identifier.self) {
            let scope = context.getCurrentScope()
            if let _ = may(context, [Symbol.squareBracketL]) {
                // varName[expression]
                try must(context, Expression.self)
                try must(context, [Symbol.squareBracketR])
                return
            } else if let _ = may(context, [Symbol.bracketL]) {
                // varName(exp1, exp2, ..., expn)
                let expressionList = try must(context, ExpressionList.self)
                let argNum = expressionList.expressions.count
                try must(context, [Symbol.bracketR])
                vmcodeFunc = { (varSymbolTable, funcSymbolTable) in
                    let varName = identifier.value()
                    guard let varSymbol = varSymbolTable[varName, scope] else {
                        throw JackError.failedToCompile(0, "\(varName) is not found.")
                    }
                    var code = try expressionList.vmcode(varSymbolTable, funcSymbolTable)
                    code += "call \(varName) \(argNum)\n"
                    return code
                }
                return
            } else if let _ = may(context, [Symbol.period]) {
                // varName.subroutine(exp1, exp2, ..., expn)
                // className.subroutine(exp1, exp2, ..., expn)
                let identifier2 = try must(context, Identifier.self)
                try must(context, [Symbol.bracketL])
                let expressionList = try must(context, ExpressionList.self)
                let argNum = expressionList.expressions.count
                try must(context, [Symbol.bracketR])
                vmcodeFunc = { (varSymbolTable, funcSymbolTable) in
                    let varName = identifier.value()
                    let funcName = identifier2.value()
                    guard let varSymbol = varSymbolTable[varName, scope] else {
                        throw JackError.failedToCompile(0, "\(varName) is not found.")
                    }
                    var code = try expressionList.vmcode(varSymbolTable, funcSymbolTable)
                    code += "call \(varName).\(funcName) \(argNum)\n"
                    return code
                }
                return
            }
            // varName
            vmcodeFunc = { (varSymbolTable, funcSymbolTable) in
                let varName = identifier.value()
                guard let varSymbol = varSymbolTable[varName, scope] else {
                    throw JackError.failedToCompile(0, "\(varName) is not found.")
                }
                if let varSymbol = varSymbolTable[varName, scope] {
                    return "push \(varSymbol.kind.rawValue) \(varSymbol.index)\n"
                }
                return "push Neoantuhaonetuhau"
            }
            return
        }

        if let _ = may(context, [Symbol.bracketL]) {
            // (expression)
            let expression = try must(context, Expression.self)
            try must(context, [Symbol.bracketR])
            vmcodeFunc = { (varSymbolTable, funcSymbolTable) in
                try expression.vmcode(varSymbolTable, funcSymbolTable)
            }
            return
        }

        // unaryOp term
        let symbol = try must(context, [Symbol.minus, .tilde])
        let term = try must(context, Term.self)
        let dict: [Symbol: String] = [
            .minus: "neg\n",
            .tilde: "not\n",
        ]
        vmcodeFunc = { (varSymbolTable, funcSymbolTable) in
            var code = try term.vmcode(varSymbolTable, funcSymbolTable)
            code += dict[symbol]!
            return code
        }
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        if let f = vmcodeFunc {
            return try f(varSymbolTable, funcSymbolTable)
        }

        return "Not Defined"
    }
}
