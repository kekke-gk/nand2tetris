//
//  Element.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/12.
//

import Foundation

protocol Element: CustomStringConvertible {
    var name: String { get }
    func start() -> String
    func end() -> String
    init?(_ context: Context) throws
}

extension Element {
    func start() -> String {
        return "<\(name)>"
    }
    
    func end() -> String {
        return "</\(name)>"
    }
}

protocol TerminalElement: Element, Equatable {
    init?(_ str: String)
    init?(_ context: Context)
    init?(_ context: Context, filters: [Self])
    func value() -> String
}

extension TerminalElement {
    var description: String {
        let escapeTable: [String: String] = [
            "<": "&lt;",
            ">": "&gt;",
            "&": "&amp;",
            "\"": "&quot;",
        ]
        
        let escapedValue = escapeTable[value(), default: value()]
        return "\(start()) \(escapedValue) \(end())"
    }
    
    init?(_ context: Context) {
        if let element = context.currentToken as? Self {
            self = element
            _ = context.next()
        } else {
            return nil
        }
    }
    
    init?(_ context: Context, filters: [Self]) {
        if filters.isEmpty {
            self.init(context)
            return
        }
        
        if let element = context.currentToken as? Self {
            if filters.contains(element) {
                self.init(context)
                return
            }
        }
        
        return nil
    }
}

protocol NonTerminalElement: Element {
    init()
    init(_ context: Context) throws
    mutating func compile(_ context: Context) throws
    mutating func must<T: Element>(_ context: Context, _ type: T.Type) throws
    mutating func may<T: Element>(_ context: Context, _ type: T.Type) -> Bool
    mutating func must<T: TerminalElement>(_ context: Context, _ filters: [T]) throws
    mutating func may<T: TerminalElement>(_ context: Context, _ filters: [T]) -> Bool
    var elements: [Element] { get set }
}

extension NonTerminalElement {
    var description: String {
        var desc = ""
        desc += start() + "\n"
        
        for element in elements {
            desc += "\(element)"
                .components(separatedBy: .newlines)
                .map { "  \($0)\n"}
                .joined()
        }
        
        desc += end()
        
        return desc
    }
    
    mutating func must<T: Element>(_ context: Context, _ type: T.Type) throws {
        guard let element = try T(context) else {
            let message = "At \(context.currentLine), '\(type)' expected but '\(context.currentToken.name) (\(context.currentToken.value())' found"
            throw JackError.compile(context.currentLine, message)
        }
        elements.append(element)
    }
    
    mutating func may<T: Element>(_ context: Context, _ type: T.Type) -> Bool {
        let initialContext = context.copy()
        guard let element = try? T(context) else {
            context.update(initialContext)
            return false
        }
        elements.append(element)
        return true
    }
    
    mutating func must<T: TerminalElement>(_ context: Context, _ filters: [T]) throws {
        guard let element = T(context), filters.contains(element) else {
            let filtersStr = filters.map { $0.value() }.joined(separator: ", ")
            let message = "At \(context.currentLine), '\(T.self) ( \(filtersStr) )' expected but '\(context.currentToken.name) ( \(context.currentToken.value()) )' found"
            throw JackError.compile(context.currentLine, message)
        }
        elements.append(element)
    }
    
    mutating func may<T: TerminalElement>(_ context: Context, _ filters: [T]) -> Bool {
        let initialContext = context.copy()
        guard let element = T(context), filters.contains(element) else {
            context.update(initialContext)
            return false
        }
        elements.append(element)
        return true
    }
    
    init(_ context: Context) throws {
        self = Self.init()
        let initialContext = context.copy()
        do {
            try compile(context)
        } catch JackError.compile(let lineNum, let message) {
            var newMessage = "\(message)\n"
            newMessage += "while compile \(name)"
            context.update(initialContext)
            throw JackError.compile(lineNum, newMessage)
        }
    }
}

protocol NonTerminalTagLessElement: NonTerminalElement {
}

extension NonTerminalTagLessElement {
    var description: String {
        var desc = ""
        
        for element in elements {
            desc += "\(element)"
                .components(separatedBy: .newlines)
                .map { "\($0)\n"}
                .joined()
        }
        
        desc = String(desc.dropLast())
        
        return desc
    }
}
