//
//  Statements.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

struct Statements: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "statements"
    }

    mutating func compile(_ context: Context) throws {
        while may(try? LetStatement(context))
                || may(try? IfStatement(context))
                || may(try? WhileStatement(context))
                || may(try? DoStatement(context))
                || may(try? ReturnStatement(context)) {}
    }
}

struct LetStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "letStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(Keyword(context, filters: [.let_]))
        try must(Identifier(context))

        if may(Symbol(context, filters: [.squareBracketL])) {
            try must(try Expression(context))
            try must(Symbol(context, filters: [.squareBracketR]))
        }

        try must(Symbol(context, filters: [.equal]))
        try must(try Expression(context))
        try must(Symbol(context, filters: [.semicolon]))
    }
}

struct IfStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "ifStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(Keyword(context, filters: [.if_]))
        try must(Symbol(context, filters: [.bracketL]))
        try must(try Expression(context))
        try must(Symbol(context, filters: [.bracketR]))
        try must(Symbol(context, filters: [.curlyBracketL]))
        try must(try Statements(context))
        try must(Symbol(context, filters: [.curlyBracketR]))

        if may(Keyword(context, filters: [.else_])) {
            try must(Symbol(context, filters: [.curlyBracketL]))
            try must(try Statements(context))
            try must(Symbol(context, filters: [.curlyBracketR]))
        }
    }
}

struct WhileStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "whileStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(Keyword(context, filters: [.while_]))
        try must(Symbol(context, filters: [.bracketL]))
        try must(try Expression(context))
        try must(Symbol(context, filters: [.bracketR]))
        try must(Symbol(context, filters: [.curlyBracketL]))
        try must(try Statements(context))
        try must(Symbol(context, filters: [.curlyBracketR]))
    }
}

struct DoStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "doStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(Keyword(context, filters: [.do_]))
        try must(Identifier(context))

        if may(Symbol(context, filters: [.bracketL])) {
            try must(try ExpressionList(context))
            try must(Symbol(context, filters: [.bracketR]))
        } else {
            try must(Symbol(context, filters: [.period]))
            try must(Identifier(context))
            try must(Symbol(context, filters: [.bracketL]))
            try must(try ExpressionList(context))
            try must(Symbol(context, filters: [.bracketR]))
        }

        try must(Symbol(context, filters: [.semicolon]))
    }
}

struct ReturnStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "returnStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must<Keyword>(context)
        try must(Keyword(context, filters: [.return_]))
        may(try? Expression(context))
        try must(Symbol(context, filters: [.semicolon]))
    }
}
