//
//  Token.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/05.
//

import Foundation

enum Token {
    case keyword(Keyword)
    case symbol(Symbol)
    case intConst(UInt)
    case strConst(String)
    case identifier(String)

    init?(str: String) {
        let regexIdentifier = /^[a-zA-Z_][\w_]*$/

        if let keyword = Keyword(rawValue: str) {
            self = .keyword(keyword)
        } else if let symbol = Symbol(rawValue: str) {
            self = .symbol(symbol)
        } else if let uintValue = UInt(str) {
            self = .intConst(uintValue)
        } else if str.hasPrefix("\"") && str.hasSuffix("\"") {
            self = .strConst(String(str.dropFirst().dropLast()))
        } else if str.contains(regexIdentifier) {
            self = .identifier(str)
        } else {
            return nil
        }
    }

    func value() -> String {
        switch self {
        case .keyword(let keyword):
            return keyword.rawValue
        case .symbol(let symbol):
            return symbol.rawValue
        case .intConst(let int):
            return String(int)
        case .strConst(let str):
            return str
        case .identifier(let id):
            return id
        }
    }

    func XMLTag() -> String {
        let tagName = XMLTagName()
        let tag = "<\(tagName)>\(self.value())</\(tagName)>"
        return tag
    }

    func XMLTagName() -> String {
        switch self {
        case .keyword:
            return "keyword"
        case .symbol:
            return "symbol"
        case .intConst:
            return "intConst"
        case .strConst:
            return "stringConst"
        case .identifier:
            return "identifier"
        }
    }
}

enum Keyword: String, CaseIterable {
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

    static let allValues = {() -> [String] in
        return allCases.map { $0.rawValue }
    }()
}

enum Symbol: String, CaseIterable {
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

    static let allValues = {() -> [String] in
        return allCases.map { $0.rawValue }
    }()
}
