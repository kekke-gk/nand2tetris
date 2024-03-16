//
//  Expressions.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

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

            return nil
        } catch {
            print(context.currentLine, name, context.currentToken)
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
            print(context.currentLine, name, context.currentToken)
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
                elements.append(identifier)
                if let symbol = Symbol(context, symbols: [.squareBracketL]) {
                    elements += [
                        symbol,
                        try Expression(context)!,
                        Symbol(context, symbols: [.squareBracketR])!,
                    ]
                    return
                } else if let symbol = Symbol(context, symbols: [.bracketL]) {
                    elements += [
                        symbol,
                        try ExpressionList(context)!,
                        Symbol(context, symbols: [.bracketR])!,
                    ]
                    return
                } else if let symbol = Symbol(context, symbols: [.period]) {
                    elements += [
                        symbol,
                        Identifier(context)!,
                        Symbol(context, symbols: [.bracketL])!,
                        try ExpressionList(context)!,
                        Symbol(context, symbols: [.bracketR])!,
                    ]
                    return
                } else {
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

            return nil
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}
