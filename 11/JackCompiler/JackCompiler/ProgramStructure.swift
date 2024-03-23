//
//  ProgramStructure.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

struct Class: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "class"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.class_])
        try must(context, Identifier.self)
        try must(context, [Symbol.curlyBracketL])

        while may(context, ClassVarDec.self) {}

        while may(context, SubroutineDec.self) {}

        try must(context, [Symbol.curlyBracketR])
    }
}

struct ClassVarDec: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "classVarDec"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.static_, .field_])
        try must(context, Type.self)
        try must(context, Identifier.self)

        while may(context, [Symbol.comma]) {
            try must(context, Identifier.self)
        }

        try must(context, [Symbol.semicolon])
    }
}

struct Type: NonTerminalTagLessElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return ""
    }

    mutating func compile(_ context: Context) throws {
        if may(context, [Keyword.int_, .char_, .boolean_]) {
        } else {
            try must(context, Identifier.self)
        }
    }
}

struct SubroutineDec: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "subroutineDec"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.constructor_, .function_, .method_])

        if may(context, [Keyword.void_]) {
        } else {
            try must(context, Type.self)
        }
        try must(context, Identifier.self)
        try must(context, [Symbol.bracketL])
        try must(context, ParameterList.self)
        try must(context, [Symbol.bracketR])
        try must(context, SubroutineBody.self)
    }
}

struct ParameterList: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "parameterList"
    }

    mutating func compile(_ context: Context) throws {
        if may(context, Type.self) {
            try must(context, Identifier.self)
        } else {
            return
        }

        while may(context, [Symbol.comma]) {
            try must(context, Type.self)
            try must(context, Identifier.self)
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
        try must(context, [Symbol.curlyBracketL])

        while may(context, VarDec.self) {}

        try must(context, Statements.self)
        try must(context, [Symbol.curlyBracketR])
    }
}

struct VarDec: NonTerminalElement {
    var elements: [any Element] = []
    init() {}

    var name: String {
        return "varDec"
    }

    mutating func compile(_ context: Context) throws {
        try must(context, [Keyword.var_])
        try must(context, Type.self)
        try must(context, Identifier.self)

        while may(context, [Symbol.comma]) {
            try must(context, Identifier.self)
        }

        try must(context, [Symbol.semicolon])
    }
}
