//
//  Statements.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

class Statements: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "statements" }

    func compile(_ context: Context) throws {
        while (may(context, LetStatement.self) != nil)
                || (may(context, IfStatement.self) != nil)
                || (may(context, WhileStatement.self) != nil)
                || (may(context, DoStatement.self) != nil)
                || (may(context, ReturnStatement.self) != nil) {}
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        var code = ""
        for element in elements {
            let nonTerm = element as! NonTerminalElement
            code += try nonTerm.vmcode(varSymbolTable, funcSymbolTable)
        }
        return code
    }
}

class LetStatement: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "letStatement" }

    var varName: String?
    var arrayExpression: Expression?
    var expression: Expression?
    var scope: Scope?

    func compile(_ context: Context) throws {
        try must(context, [Keyword.let_])
        let identifier = try must(context, Identifier.self)
        varName = identifier.value()

        if let _ = may(context, [Symbol.squareBracketL]) {
            arrayExpression = try must(context, Expression.self)
            try must(context, [Symbol.squareBracketR])
        }

        try must(context, [Symbol.equal])
        expression = try must(context, Expression.self)
        try must(context, [Symbol.semicolon])

        scope = context.getCurrentScope()
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        guard let varSymbol = varSymbolTable[varName!, scope!] else {
            throw JackError.failedToCompile(0, "\(varName!) is not defined in \(scope!).")
        }

        var code = ""
        if let arrayExp = arrayExpression {
            code += try arrayExp.vmcode(varSymbolTable, funcSymbolTable)
            code += "push \(varSymbol.kind.rawValue) \(varSymbol.index)\n"
            code += "add\n"
        }
        code += try expression!.vmcode(varSymbolTable, funcSymbolTable)
        if let arrayExp = arrayExpression {
            code += "pop temp 0\n"
            code += "pop pointer 1\n"
            code += "push temp 0\n"
            code += "pop that 0\n"
        } else {
            code += "pop \(varSymbol.kind.rawValue) \(varSymbol.index)\n"
        }
        return code
    }
}

class IfStatement: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "ifStatement" }

    var expression: Expression?
    var statements: Statements?
    var statementsElse: Statements?

    var labelUniqueNum: Int?

    func compile(_ context: Context) throws {
        try must(context, [Keyword.if_])
        try must(context, [Symbol.bracketL])
        expression = try must(context, Expression.self)
        try must(context, [Symbol.bracketR])
        try must(context, [Symbol.curlyBracketL])
        labelUniqueNum = context.getUniqueNumber(scope: context.getCurrentScope(), kind: .if_)
        statements = try must(context, Statements.self)
        try must(context, [Symbol.curlyBracketR])

        if let _ = may(context, [Keyword.else_]) {
            try must(context, [Symbol.curlyBracketL])
            statementsElse = try must(context, Statements.self)
            try must(context, [Symbol.curlyBracketR])
        }
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        let labelTrue = "IF_TRUE\(labelUniqueNum!)"
        let labelFalse = "IF_FALSE\(labelUniqueNum!)"
        let labelEnd = "IF_END\(labelUniqueNum!)"

        var code = ""
        if let statementsElse = statementsElse {
            code += try expression!.vmcode(varSymbolTable, funcSymbolTable)
            code += "if-goto \(labelTrue)\n"
            code += "goto \(labelFalse)\n"
            code += "label \(labelTrue)\n"
            code += try statements!.vmcode(varSymbolTable, funcSymbolTable)
            code += "goto \(labelEnd)\n"
            code += "label \(labelFalse)\n"
            code += try statementsElse.vmcode(varSymbolTable, funcSymbolTable)
            code += "label \(labelEnd)\n"
        } else {
            code = try expression!.vmcode(varSymbolTable, funcSymbolTable)
            code += "if-goto \(labelTrue)\n"
            code += "goto \(labelFalse)\n"
            code += "label \(labelTrue)\n"
            code += try statements!.vmcode(varSymbolTable, funcSymbolTable)
            code += "label \(labelFalse)\n"
        }
        return code
    }
}

class WhileStatement: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "whileStatement" }

    var expression: Expression?
    var statements: Statements?

    var labelUniqueNum: Int?

    func compile(_ context: Context) throws {
        try must(context, [Keyword.while_])
        try must(context, [Symbol.bracketL])
        expression = try must(context, Expression.self)
        try must(context, [Symbol.bracketR])

        labelUniqueNum = context.getUniqueNumber(scope: context.getCurrentScope(), kind: .while_)

        try must(context, [Symbol.curlyBracketL])
        statements = try must(context, Statements.self)
        try must(context, [Symbol.curlyBracketR])
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        let startLabel = "WHILE_EXP\(labelUniqueNum!)"
        let endLabel = "WHILE_END\(labelUniqueNum!)"

        var code = ""
        code += "label \(startLabel)\n"
        code += try expression!.vmcode(varSymbolTable, funcSymbolTable)
        code += "not\n"
        code += "if-goto \(endLabel)\n"
        code += try statements!.vmcode(varSymbolTable, funcSymbolTable)
        code += "goto \(startLabel)\n"
        code += "label \(endLabel)\n"
        return code
    }
}

class DoStatement: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "doStatement" }

    var term: Term?

    func compile(_ context: Context) throws {
        try must(context, [Keyword.do_])
        term = try must(context, Term.self)
        try must(context, [Symbol.semicolon])
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        var code = ""
        code += try term!.vmcode(varSymbolTable, funcSymbolTable)
        code += "pop temp 0\n"
        return code
    }
}

class ReturnStatement: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "returnStatement" }

    var expression: Expression?

    func compile(_ context: Context) throws {
        try must(context, [Keyword.return_])
        expression = may(context, Expression.self)
        try must(context, [Symbol.semicolon])
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        if let expression = expression {
            var code = ""
            code += try expression.vmcode(varSymbolTable, funcSymbolTable)
            code += "return\n"
            return code
        }
        return """
        push constant 0
        return\n
        """
    }
}
