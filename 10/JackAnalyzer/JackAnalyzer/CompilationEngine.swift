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
            let element = try Expression(context)
            print(element!)
        } catch {
            print("Compile Error")
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

struct Expression: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "expression"
    }

    init?(_ context: Context) throws {
        if let term = try Term(context) {
            elements.append(term)
            while let symbol = Symbol(context, symbols: [.plus, .minus, .asterisk, .slash, .and, .or, .angleBracketL, .angleBracketR, .equal]) {
                if let term2 = try Term(context) {
                    elements.append(symbol)
                    elements.append(term2)
                }
            }
            return
        }

        throw JackError.tokenize(name)
    }
}

struct ExpressionList: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "expressionList"
    }

    init?(_ context: Context) throws {
        if let expression = try Expression(context) {
            elements.append(expression)

            while let symbol = Symbol(context, symbols: [.comma]) {
                if let expression2 = try Expression(context) {
                    elements.append(symbol)
                    elements.append(expression2)
                }
            }
        }

        return
    }
}

struct Term: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "term"
    }

    init?(_ context: Context) throws {
        if let element = IntConst(context) {
            elements.append(element)
            return
        }

        if let element = StrConst(context) {
            elements.append(element)
            return
        }

        if let element = Keyword(context, keywords: [.true_, .false_, .null_, .this_]) {
            elements.append(element)
            return
        }

        if let identifier = Identifier(context) {
            if let symbol = Symbol(context, symbols: [.squareBracketL]) {
                if let expression = try Expression(context) {
                    if let symbol2 = Symbol(context, symbols: [.squareBracketR]) {
                        elements.append(identifier)
                        elements.append(symbol)
                        elements.append(expression)
                        elements.append(symbol2)
                        return
                    }
                }
            } else if let symbol = Symbol(context, symbols: [.bracketL]) {
                if let expressionList = try ExpressionList(context) {
                    if let symbol2 = Symbol(context, symbols: [.bracketR]) {
                        elements.append(identifier)
                        elements.append(symbol)
                        elements.append(expressionList)
                        elements.append(symbol2)
                        return
                    }
                }
            } else if let symbol = Symbol(context, symbols: [.period]) {
                if let identifier2 = Identifier(context) {
                    if let symbol2 = Symbol(context, symbols: [.bracketL]) {
                        if let expressionList = try ExpressionList(context) {
                            if let symbol3 = Symbol(context, symbols: [.bracketR]) {
                                elements.append(identifier)
                                elements.append(symbol)
                                elements.append(identifier2)
                                elements.append(symbol2)
                                elements.append(expressionList)
                                elements.append(symbol3)
                                return
                            }
                        }
                    }

                }
            }
        }

        if let symbol = Symbol(context, symbols: [.bracketL]) {
            if let expression = try Expression(context) {
                if let symbol2 = Symbol(context, symbols: [.bracketR]) {
                    elements.append(symbol)
                    elements.append(expression)
                    elements.append(symbol2)
                    return
                }
            }
        }

        if let symbol = Symbol(context, symbols: [.minus, .tilde]) {
            if let term = try Term(context) {
                elements.append(symbol)
                elements.append(term)
                return
            }
        }

        throw JackError.tokenize("term")
    }
}
