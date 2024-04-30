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

protocol NonTerminalElement: Element, AnyObject {
    init()
    init(_ context: Context) throws
    func compile(_ context: Context) throws
    func must<T: Element>(_ context: Context, _ type: T.Type) throws -> T
    func may<T: Element>(_ context: Context, _ type: T.Type) -> T?
    func must<T: TerminalElement>(_ context: Context, _ filters: [T]) throws -> T
    func may<T: TerminalElement>(_ context: Context, _ filters: [T]) -> T?
    var elements: [Element] { get set }
    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String 
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

    func must<T: Element>(_ context: Context, _ type: T.Type) throws -> T {
        guard let element = try T(context) else {
            let message = "At \(context.currentLine), '\(type)' expected but '\(context.currentToken.name) (\(context.currentToken.value())' found"
            throw JackError.failedToCompile(context.currentLine, message)
        }
        elements.append(element)
        return element
    }

    func may<T: Element>(_ context: Context, _ type: T.Type) -> T? {
        let initialContext = context.copy()
        guard let element = try? T(context) else {
            context.update(initialContext)
            return nil
        }
        elements.append(element)
        return element
    }

    func must<T: TerminalElement>(_ context: Context, _ filters: [T]) throws -> T {
        guard let element = T(context), filters.contains(element) else {
            let filtersStr = filters.map { $0.value() }.joined(separator: ", ")
            let message = "At \(context.currentLine), '\(T.self) ( \(filtersStr) )' expected but '\(context.currentToken.name) ( \(context.currentToken.value()) )' found"
            throw JackError.failedToCompile(context.currentLine, message)
        }
        elements.append(element)
        return element
    }

    func may<T: TerminalElement>(_ context: Context, _ filters: [T]) -> T? {
        let initialContext = context.copy()
        guard let element = T(context), filters.contains(element) else {
            context.update(initialContext)
            return nil
        }
        elements.append(element)
        return element
    }

    init(_ context: Context) throws {
        self.init()
        let initialContext = context.copy()
        do {
            context.elementsStack.append(self)
            try compile(context)
            context.elementsStack.popLast()
        } catch JackError.failedToCompile(let lineNum, let message) {
            context.elementsStack.popLast()
            var newMessage = "\(message)\n"
            newMessage += "while compile \(name)"
            context.update(initialContext)
            throw JackError.failedToCompile(lineNum, newMessage)
        }
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        throw JackError.failedToCompile(0, "\(self.name) element has no vmcode.")
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
