//
//  Token.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/05.
//

import Foundation

func initTerminalElement(_ str: String) -> (any TerminalElement)? {
    if let keyword = Keyword(str) {
        return keyword
    } else if let symbol = Symbol(str) {
        return symbol
    } else if let intConst = IntConst(str) {
        return intConst
    } else if let strConst = StrConst(str) {
        return strConst
    } else if let identifier = Identifier(str) {
        return identifier
    } else {
        return nil
    }
}

enum Keyword: String, CaseIterable, TerminalElement {
    var name: String { "keyword" }

    case class_ = "class"
    case constructor_ = "constructor"
    case function_ = "function"
    case method_ = "method"
    case field_ = "field"
    case static_ = "static"
    case var_ = "var"
    case int_ = "int"
    case char_ = "char"
    case boolean_ = "boolean"
    case void_ = "void"
    case true_ = "true"
    case false_ = "false"
    case null_ = "null"
    case this_ = "this"
    case let_ = "let"
    case do_ = "do"
    case if_ = "if"
    case else_ = "else"
    case while_ = "while"
    case return_ = "return"

    init?(_ str: String) {
        self.init(rawValue: str)
    }

    func value() -> String { self.rawValue }

    static let allValues = allCases.map(\.rawValue)
}

enum Symbol: String, CaseIterable, TerminalElement {
    var name: String { "symbol" }

    case curlyBracketL = "{"
    case curlyBracketR = "}"
    case bracketL = "("
    case bracketR = ")"
    case squareBracketL = "["
    case squareBracketR = "]"
    case period = "."
    case comma = ","
    case semicolon = ";"
    case plus = "+"
    case minus = "-"
    case asterisk = "*"
    case slash = "/"
    case and = "&"
    case or = "|"
    case angleBracketL = "<"
    case angleBracketR = ">"
    case equal = "="
    case tilde = "~"

    init?(_ str: String) {
        self.init(rawValue: str)
    }

    func value() -> String { self.rawValue }

    static let allValues = allCases.map(\.rawValue)
}

struct IntConst: TerminalElement {
    var name: String { "integerConstant" }

    let intValue: Int

    init?(_ str: String) {
        guard let int = Int(str) else {
            return nil
        }
        self.intValue = int
    }

    func value() -> String { String(intValue) }
}

struct StrConst: TerminalElement {
    var name: String { "stringConstant" }

    let strValue: String

    init?(_ str: String) {
        guard str.hasPrefix("\"") && str.hasSuffix("\"") else {
            return nil
        }
        self.strValue = String(str.dropFirst().dropLast())
    }

    func value() -> String { strValue }
}

struct Identifier: TerminalElement {
    var name: String { "identifier" }

    let identifier: String


    init?(_ str: String) {
        let regexIdentifier = /^[a-zA-Z_][\w_]*$/

        guard str.contains(regexIdentifier) else {
            return nil
        }
        self.identifier = str
    }

    func value() -> String { identifier }
}
