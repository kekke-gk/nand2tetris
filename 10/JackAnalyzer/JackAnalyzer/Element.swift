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
    mutating func must(_ element: (any Element)?) throws
    mutating func may(_ element: (any Element)?) -> Bool
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

    mutating func must(_ element: (any Element)?) throws {
        guard let elem = element else {
            throw JackError.compile(0, "")
        }
        elements.append(elem)
    }

    mutating func may(_ element: (any Element)?) -> Bool {
        guard let elem = element else {
            return false
        }
        elements.append(elem)
        return true
    }

    mutating func must<T: Element>(_ context: Context, type: T.Type) throws {
        guard let element = try T(context) else {
            throw JackError.compile(0, "")
        }
        elements.append(element)
    }

    mutating func may<T: Element>(_ context: Context, type: T.Type) -> Bool {
        guard let element = try? T(context) else {
            return false
        }
        elements.append(element)
        return true
    }

    mutating func must<T: TerminalElement>(_ context: Context, filters: [T] = []) throws {
        guard let element = T(context) else {
            throw JackError.compile(0, "")
        }
        elements.append(element)
    }

    mutating func may<T: TerminalElement>(_ context: Context, filters: [T] = []) -> Bool {
        guard let element = T(context) else {
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
            context.update(initialContext)
            throw JackError.compile(context.currentLine, name)
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
