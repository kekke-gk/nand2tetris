//
//  CompilationEngine.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/09.
//

import Foundation

class CompilationEngine {
    let context: Context

    init(tokensList: [[TerminalElement]]) {
        self.context = Context(tokensList: tokensList)
    }

    func compile() {
        do {
            let element = try Statements(context)
            print(element!)
        } catch JackError.compile(let lineNum, let message) {
            print("Compile Error")
            print(lineNum)
            print(message)
        } catch {
            print("Other Error")
        }
    }
}

class Context {
    let tokensList: [[TerminalElement]]
    var currentLine: Int = 0
    var currentIndex: Int = 0
    var currentToken: TerminalElement

    init(tokensList: [[TerminalElement]]) {
        self.tokensList = tokensList

        while tokensList[currentLine].count == 0 {
            currentLine += 1
        }
        currentToken = tokensList[currentLine][currentIndex]
    }

    func next() -> TerminalElement? {
        let (line, index, token) = next_()
        currentLine = line
        currentIndex = index
        if let token: TerminalElement = token {
            currentToken = token
        }
        return token
    }

    func checkNext() -> TerminalElement? {
        let (_, _, token) = next_()
        return token
    }

    private func next_() -> (Int, Int, TerminalElement?) {
        var line = currentLine
        var index = currentIndex

        if tokensList[line].count - 1 == index {
            repeat {
                line += 1
                if tokensList.count == line {
                    return (line, index, nil)
                }
            } while tokensList[line].count == 0

            index = 0
        } else {
            index += 1
        }
        return (line, index, tokensList[line][index])
    }
}

struct Statements: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "statements"
    }

    init?(_ context: Context) throws {
        do {
        labelWhile: while true {
            switch context.currentToken as? Keyword {
            case .let_:
                elements.append(try LetStatement(context)!)
            case .if_:
                elements.append(try IfStatement(context)!)
            case .while_:
                elements.append(try WhileStatement(context)!)
            case .do_:
                elements.append(try DoStatement(context)!)
            case .return_:
                elements.append(try ReturnStatement(context)!)
            default:
                break labelWhile
            }
        }
        } catch {
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct LetStatement: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "letStatement"
    }

    init?(_ context: Context) throws {
        do {
            elements = [
                Keyword(context, keywords: [.let_])!,
                Identifier(context)!,
            ]

            if let symbol = Symbol(context, symbols: [.squareBracketL]) {
                elements += [
                    symbol,
                    try Expression(context)!,
                    Symbol(context, symbols: [.squareBracketR])!,
                ]
            }

            elements += [
                Symbol(context, symbols: [.equal])!,
                try Expression(context)!,
                Symbol(context, symbols: [.semicolon])!,
            ]
        } catch {
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct IfStatement: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "ifStatement"
    }

    init?(_ context: Context) throws {
        do {
            elements = [
                Keyword(context, keywords: [.if_])!,
                Symbol(context, symbols: [.bracketL])!,
                try Expression(context)!,
                Symbol(context, symbols: [.bracketR])!,
                Symbol(context, symbols: [.curlyBracketL])!,
                try Statements(context)!,
                Symbol(context, symbols: [.curlyBracketR])!,
            ]

            if let keyword = Keyword(context, keywords: [.else_]) {
                elements += [
                    keyword,
                    Symbol(context, symbols: [.curlyBracketL])!,
                    try Statements(context)!,
                    Symbol(context, symbols: [.curlyBracketR])!,
                ]
            }
        } catch {
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct WhileStatement: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "whileStatement"
    }

    init?(_ context: Context) throws {
        do {
            elements = [
                Keyword(context, keywords: [.while_])!,
                Symbol(context, symbols: [.bracketL])!,
                try Expression(context)!,
                Symbol(context, symbols: [.bracketR])!,
                Symbol(context, symbols: [.curlyBracketL])!,
                try Statements(context)!,
                Symbol(context, symbols: [.curlyBracketR])!,
            ]
        } catch {
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct DoStatement: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "doStatement"
    }

    init?(_ context: Context) throws {
        do {
            elements.append(Keyword(context, keywords: [.do_])!)

            elements.append(Identifier(context)!)

            if let symbol = Symbol(context, symbols: [.bracketL]) {
                elements += [
                    symbol,
                    try ExpressionList(context)!,
                    Symbol(context, symbols: [.bracketR])!,
                ]
            } else if let symbol = Symbol(context, symbols: [.period]) {
                elements += [
                    symbol,
                    Identifier(context)!,
                    Symbol(context, symbols: [.bracketL])!,
                    try ExpressionList(context)!,
                    Symbol(context, symbols: [.bracketR])!,
                ]
            } else {
                throw JackError.compile(context.currentLine, name)
            }

            elements.append(Symbol(context, symbols: [.semicolon])!)
        } catch {
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct ReturnStatement: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "returnStatement"
    }

    init?(_ context: Context) throws {
        do {
            elements.append(Keyword(context, keywords: [.return_])!)

            if let expression = try Expression(context) {
                elements.append(expression)
            }

            elements.append(Symbol(context, symbols: [.semicolon])!)
        } catch {
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct Expression: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "expression"
    }

    init?(_ context: Context) throws {
        do {
            if let term = try Term(context) {
                elements.append(term)

                while let symbol = Symbol(context, symbols: [.plus, .minus, .asterisk, .slash, .and, .or, .angleBracketL, .angleBracketR, .equal]) {
                    elements += [
                        symbol,
                        try Term(context)!,
                    ]
                }
                return
            }
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        } catch {
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct ExpressionList: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "expressionList"
    }

    init?(_ context: Context) throws {
        do {
            if let expression = try Expression(context) {
                elements.append(expression)

                while let symbol = Symbol(context, symbols: [.comma]) {
                    elements += [
                        symbol,
                        try Expression(context)!,
                    ]
                }
            }

            return
        } catch {
            print(context.currentLine, name)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct Term: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "term"
    }

    init?(_ context: Context) throws {
        do {
            if let element = IntConst(context) {
                elements = [element]
                return
            }

            if let element = StrConst(context) {
                elements = [element]
                return
            }

            if let element = Keyword(context, keywords: [.true_, .false_, .null_, .this_]) {
                elements = [element]
                return
            }

            if let identifier = Identifier(context) {
                if let symbol = Symbol(context, symbols: [.squareBracketL]) {
                    elements = [
                        identifier,
                        symbol,
                        try Expression(context)!,
                        Symbol(context, symbols: [.squareBracketR])!,
                    ]
                    return
                } else if let symbol = Symbol(context, symbols: [.bracketL]) {
                    elements = [
                        identifier,
                        symbol,
                        try ExpressionList(context)!,
                        Symbol(context, symbols: [.bracketR])!,
                    ]
                    return
                } else if let symbol = Symbol(context, symbols: [.period]) {
                    elements = [
                        identifier,
                        symbol,
                        Identifier(context)!,
                        Symbol(context, symbols: [.bracketL])!,
                        try ExpressionList(context)!,
                        Symbol(context, symbols: [.bracketL])!,
                    ]
                    return
                } else {
                    elements.append(identifier)
                    return
                }
            }

            if let symbol = Symbol(context, symbols: [.bracketL]) {
                elements = [
                    symbol,
                    try Expression(context)!,
                    Symbol(context, symbols: [.bracketR])!,
                ]
                return
            }

            if let symbol = Symbol(context, symbols: [.minus, .tilde]) {
                elements = [
                    symbol,
                    try Term(context)!,
                ]
                return
            }
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}
