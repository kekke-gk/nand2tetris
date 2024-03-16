//
//  ProgramStructure.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

struct Class: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "class"
    }

    init?(_ context: Context) throws {
        do {
            elements.append(Keyword(context, keywords: [.class_])!)
            elements.append(Identifier(context)!)
            elements.append(Symbol(context, symbols: [.curlyBracketL])!)

            while [.static_, .field_].contains(context.currentToken as? Keyword) {
                elements.append(try ClassVarDec(context)!)
            }

            while [.constructor_, .function_, .method_].contains(context.currentToken as? Keyword) {
                elements.append(try SubroutineDec(context)!)
            }

            elements.append(Symbol(context, symbols: [.curlyBracketR])!)
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct ClassVarDec: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "classVarDec"
    }

    init?(_ context: Context) throws {
        do {
            elements.append(Keyword(context, keywords: [.static_, .field_])!)

            if let keyword = Keyword(context, keywords: [.int_, .char_, .boolean_]) {
                elements.append(keyword)
            } else if let identifier = Identifier(context) {
                elements.append(identifier)
            } else {
                print(context.currentLine, name, context.currentToken)
                throw JackError.compile(context.currentLine, name)
            }

            elements.append(Identifier(context)!)

            while let symbol = Symbol(context, symbols: [.comma]) {
                elements += [
                    symbol,
                    Identifier(context)!,
                ]
            }
            elements.append(Symbol(context, symbols: [.semicolon])!)
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct SubroutineDec: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "subroutineDec"
    }

    init?(_ context: Context) throws {
        do {
            elements.append(Keyword(context, keywords: [.constructor_, .function_, .method_])!)

            if let keyword = Keyword(context, keywords: [.void_, .int_, .char_, .boolean_]) {
                elements.append(keyword)
            } else if let identifier = Identifier(context) {
                elements.append(identifier)
            } else {
                print(context.currentLine, name, context.currentToken)
                throw JackError.compile(context.currentLine, name)
            }

            elements += [
                Identifier(context)!,
                Symbol(context, symbols: [.bracketL])!,
                try ParameterList(context)!,
                Symbol(context, symbols: [.bracketR])!,
                try SubroutineBody(context)!,
            ]
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct ParameterList: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "parameterList"
    }

    init?(_ context: Context) throws {
        do {
            if let keyword = Keyword(context, keywords: [.int_, .char_, .boolean_]) {
                elements.append(keyword)
            } else if let identifier = Identifier(context) {
                elements.append(identifier)
            } else {
                return
            }

            elements.append(Identifier(context)!)

            while let symbol = Symbol(context, symbols: [.comma]) {
                elements.append(symbol)
                if let keyword = Keyword(context, keywords: [.int_, .char_, .boolean_]) {
                    elements.append(keyword)
                } else if let identifier = Identifier(context) {
                    elements.append(identifier)
                } else {
                    print(context.currentLine, name, context.currentToken)
                    throw JackError.compile(context.currentLine, name)
                }
                elements.append(Identifier(context)!)
            }

        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct SubroutineBody: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "subroutineBody"
    }

    init?(_ context: Context) throws {
        do {
            elements.append(Symbol(context, symbols: [.curlyBracketL])!)

            while context.currentToken as? Keyword == .var_{
                elements.append(try VarDec(context)!)
            }
            elements.append(try Statements(context)!)
            elements.append(Symbol(context, symbols: [.curlyBracketR])!)
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct VarDec: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "varDec"
    }

    init?(_ context: Context) throws {
        do {
            elements.append(Keyword(context, keywords: [.var_])!)

            if let keyword = Keyword(context, keywords: [.int_, .char_, .boolean_]) {
                elements.append(keyword)
            } else if let identifier = Identifier(context) {
                elements.append(identifier)
            } else {
                print(context.currentLine, name, context.currentToken)
                throw JackError.compile(context.currentLine, name)
            }

            elements.append(Identifier(context)!)

            while let symbol = Symbol(context, symbols: [.comma]) {
                elements += [
                    symbol,
                    Identifier(context)!,
                ]
            }
            elements.append(Symbol(context, symbols: [.semicolon])!)
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}
