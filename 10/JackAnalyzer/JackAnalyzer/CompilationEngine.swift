//
//  CompilationEngine.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/09.
//

import Foundation

class CompilationEngine {

}

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
    var elements: [Element] { get }
    func compile() -> Element
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

