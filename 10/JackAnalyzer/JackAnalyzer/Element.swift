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
}

extension Element {
    func start() -> String {
        return "<\(name)>"
    }

    func end() -> String {
        return "</\(name)>"
    }
}

protocol TerminalElement: Element {
    init?(_ str: String)
    init?(_ context: Context)
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
}

protocol NonTerminalElement: Element {
    init?(_ context: Context) throws
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
}
