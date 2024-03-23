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
        while may(context, LetStatement.self)
                || may(context, IfStatement.self)
                || may(context, WhileStatement.self)
                || may(context, DoStatement.self)
                || may(context, ReturnStatement.self) {}
    }
}

struct LetStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "letStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.let_])
        try must(context, Identifier.self)

        if may(context, [Symbol.squareBracketL]) {
            try must(context, Expression.self)
            try must(context, [Symbol.squareBracketR])
        }

        try must(context, [Symbol.equal])
        try must(context, Expression.self)
        try must(context, [Symbol.semicolon])
    }
}

struct IfStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "ifStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.if_])
        try must(context, [Symbol.bracketL])
        try must(context, Expression.self)
        try must(context, [Symbol.bracketR])
        try must(context, [Symbol.curlyBracketL])
        try must(context, Statements.self)
        try must(context, [Symbol.curlyBracketR])

        if may(context, [Keyword.else_]) {
            try must(context, [Symbol.curlyBracketL])
            try must(context, Statements.self)
            try must(context, [Symbol.curlyBracketR])
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
        try must(context, [Keyword.while_])
        try must(context, [Symbol.bracketL])
        try must(context, Expression.self)
        try must(context, [Symbol.bracketR])
        try must(context, [Symbol.curlyBracketL])
        try must(context, Statements.self)
        try must(context, [Symbol.curlyBracketR])
    }
}

struct DoStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "doStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.do_])
        try must(context, Identifier.self)

        if may(context, [Symbol.bracketL]) {
            try must(context, ExpressionList.self)
            try must(context, [Symbol.bracketR])
        } else {
            try must(context, [Symbol.period])
            try must(context, Identifier.self)
            try must(context, [Symbol.bracketL])
            try must(context, ExpressionList.self)
            try must(context, [Symbol.bracketR])
        }

        try must(context, [Symbol.semicolon])
    }
}

struct ReturnStatement: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "returnStatement"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.return_])
        _ = may(context, Expression.self)
        try must(context, [Symbol.semicolon])
    }
}
