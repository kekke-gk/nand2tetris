//
//  Expressions.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

struct Expression: NonTerminalElement {
    var elements: [any Element] = []
    init() {}
    
    var name: String {
        return "expression"
    }
    
    mutating func compile(_ context: Context) throws {
        try must(context, Term.self)
        
        while may(context, [Symbol.plus, .minus, .asterisk, .slash, .and, .or, .angleBracketL, .angleBracketR, .equal]) {
            try must(context, Term.self)
        }
    }
}

struct ExpressionList: NonTerminalElement {
    var elements: [any Element] = []
    init() {}
    
    var name: String {
        return "expressionList"
    }
    
    mutating func compile(_ context: Context) throws {
        if may(context, Expression.self) {
            while may(context, [Symbol.comma]) {
                try must(context, Expression.self)
            }
        }
    }
}

struct Term: NonTerminalElement {
    var elements: [any Element] = []
    init() {}
    
    var name: String {
        return "term"
    }
    
    mutating func compile(_ context: Context) throws {
        if may(context, IntConst.self) { return }
        if may(context, StrConst.self) { return }
        if may(context, [Keyword.true_, .false_, .null_, .this_]) { return }
        
        if may(context, Identifier.self) {
            if may(context, [Symbol.squareBracketL]) {
                try must(context, Expression.self)
                try must(context, [Symbol.squareBracketR])
            } else if may(context, [Symbol.bracketL]) {
                try must(context, ExpressionList.self)
                try must(context, [Symbol.bracketR])
            } else if may(context, [Symbol.period]) {
                try must(context, Identifier.self)
                try must(context, [Symbol.bracketL])
                try must(context, ExpressionList.self)
                try must(context, [Symbol.bracketR])
            }
            return
        }
        
        if may(context, [Symbol.bracketL]) {
            try must(context, Expression.self)
            try must(context, [Symbol.bracketR])
            return
        }
        
        try must(context, [Symbol.minus, .tilde])
        try must(context, Term.self)
    }
}
