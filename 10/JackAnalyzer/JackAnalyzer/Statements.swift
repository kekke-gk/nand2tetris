//
//  Statements.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

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
            print(context.currentLine, name, context.currentToken)
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
        print(context)
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

            print(context)
            elements += [
                Symbol(context, symbols: [.equal])!,
                ]
            print(context)
            elements += [
                try Expression(context)!,
                ]
            print(context)
            elements += [
                Symbol(context, symbols: [.semicolon])!,
            ]
        } catch {
            print(context.currentLine, name, context.currentToken)
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
            print(context.currentLine, name, context.currentToken)
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
            print(context.currentLine, name, context.currentToken)
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
                ]

                elements += [
                    try ExpressionList(context)!,
                    Symbol(context, symbols: [.bracketR])!,
                ]
            } else {
                throw JackError.compile(context.currentLine, name)
            }

            elements.append(Symbol(context, symbols: [.semicolon])!)
        } catch {
            print(context.currentLine, name, context.currentToken)
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

            if let symbol = Symbol(context, symbols: [.semicolon]) {
                elements.append(symbol)
            } else {
                elements.append(try Expression(context)!)
                elements.append(Symbol(context, symbols: [.semicolon])!)
            }
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}
