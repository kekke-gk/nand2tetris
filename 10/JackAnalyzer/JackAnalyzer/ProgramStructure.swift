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

    init(_ context: Context) throws {
        do {
            elements.append(Keyword(context, filters: [.class_])!)
            elements.append(Identifier(context)!)
            elements.append(Symbol(context, filters: [.curlyBracketL])!)

            while [.static_, .field_].contains(context.currentToken as? Keyword) {
                elements.append(try ClassVarDec(context)!)
            }

            while [.constructor_, .function_, .method_].contains(context.currentToken as? Keyword) {
                elements.append(try SubroutineDec(context)!)
            }

            elements.append(Symbol(context, filters: [.curlyBracketR])!)
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

    init(_ context: Context) throws {
        do {
            elements.append(Keyword(context, filters: [.static_, .field_])!)

            if let keyword = Keyword(context, filters: [.int_, .char_, .boolean_]) {
                elements.append(keyword)
            } else if let identifier = Identifier(context) {
                elements.append(identifier)
            } else {
                print(context.currentLine, name, context.currentToken)
                throw JackError.compile(context.currentLine, name)
            }

            elements.append(Identifier(context)!)

            while let symbol = Symbol(context, filters: [.comma]) {
                elements += [
                    symbol,
                    Identifier(context)!,
                ]
            }
            elements.append(Symbol(context, filters: [.semicolon])!)
        } catch {
            print(context.currentLine, name, context.currentToken)
            throw JackError.compile(context.currentLine, name)
        }
    }
}

struct Typea: NonTerminalTagLessElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return ""
    }

    mutating func compile(_ context: Context) throws {
        if may(Keyword(context, filters: [.int_, .char_, .boolean_])) {
        } else {
            try must(Identifier(context))
        }
    }
}

struct SubroutineDec: NonTerminalElement {
    var elements: [any Element] = []

    var name: String {
        return "subroutineDec"
    }

    init(_ context: Context) throws {
        do {
            elements.append(Keyword(context, filters: [.constructor_, .function_, .method_])!)

            if let keyword = Keyword(context, filters: [.void_, .int_, .char_, .boolean_]) {
                elements.append(keyword)
            } else if let identifier = Identifier(context) {
                elements.append(identifier)
            } else {
                print(context.currentLine, name, context.currentToken)
                throw JackError.compile(context.currentLine, name)
            }

            elements += [
                Identifier(context)!,
                Symbol(context, filters: [.bracketL])!,
                try ParameterList(context)!,
                Symbol(context, filters: [.bracketR])!,
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
    init() {}

    var name: String {
        return "parameterList"
    }

    mutating func compile(_ context: Context) throws {
    }

    init(_ context: Context) throws {
        do {
            if let keyword = Keyword(context, filters: [.int_, .char_, .boolean_]) {
                elements.append(keyword)
            } else if let identifier = Identifier(context) {
                elements.append(identifier)
            } else {
                return
            }

            elements.append(Identifier(context)!)

            while let symbol = Symbol(context, filters: [.comma]) {
                elements.append(symbol)
                if let keyword = Keyword(context, filters: [.int_, .char_, .boolean_]) {
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
    init() {}

    var name: String {
        return "subroutineBody"
    }

    mutating func compile(_ context: Context) throws {
        try must(Symbol(context, filters: [.curlyBracketL]))

        while may(try? VarDec(context)) {}

        try must(try Statements(context))
        try must(Symbol(context, filters: [.curlyBracketR]))
    }
}

struct VarDec: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "varDec"
    }

    mutating func compile(_ context: Context) throws {
        try must(Keyword(context, filters: [.var_]))
        try must(try Type(context))
        try must(Identifier(context))

        while may(Symbol(context, filters: [.comma])) {
            try must(Identifier(context))
        }

        try must(Symbol(context, filters: [.semicolon]))
    }
}
