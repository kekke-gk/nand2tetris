//
//  CompilationEngine.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/09.
//

import Foundation

class CompilationEngine {
    let context: Context
    var element: Element?

    init(tokensList: [[TerminalElement]]) {
        self.context = Context(tokensList: tokensList)
    }

    func compile() {
        do {
            element = try Class(context)

            print(element!)
        } catch JackError.compile(let lineNum, let message) {
            print("Compile Error")
            print(lineNum)
            print(message)
        } catch {
            print("Other Error")
        }
    }
}

class Context: CustomStringConvertible {
    let tokensList: [[TerminalElement]]
    var currentLine: Int = 0
    var currentIndex: Int = 0
    var currentToken: TerminalElement

    var description: String {
        return "(\(currentLine), \(currentIndex)), \(currentToken)"
    }

    init(tokensList: [[TerminalElement]]) {
        self.tokensList = tokensList

        while tokensList[currentLine].count == 0 {
            currentLine += 1
        }
        currentToken = tokensList[currentLine][currentIndex]
    }

    func next() -> TerminalElement? {
        let (line, index, token) = next_()
        currentLine = line
        currentIndex = index
        if let token: TerminalElement = token {
            currentToken = token
        }
        return token
    }

    func checkNext() -> TerminalElement? {
        let (_, _, token) = next_()
        return token
    }

    private func next_() -> (Int, Int, TerminalElement?) {
        var line = currentLine
        var index = currentIndex

        if tokensList[line].count - 1 == index {
            repeat {
                line += 1
                if tokensList.count == line {
                    return (line, index, nil)
                }
            } while tokensList[line].count == 0

            index = 0
        } else {
            index += 1
        }
        return (line, index, tokensList[line][index])
    }
}





