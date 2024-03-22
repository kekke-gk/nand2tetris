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

    init(tokensList: [[any TerminalElement]]) {
        self.context = Context(tokensList: tokensList)
    }

    func compile() {
        do {
            element = try Class(context)
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
    let tokensList: [[any TerminalElement]]
    var currentLine: Int = 0
    var currentIndex: Int = 0
    var currentToken: any TerminalElement

    var description: String {
        return "(\(currentLine), \(currentIndex)), \(currentToken)"
    }

    required init(tokensList: [[any TerminalElement]]) {
        self.tokensList = tokensList

        while tokensList[currentLine].count == 0 {
            currentLine += 1
        }
        currentToken = tokensList[currentLine][currentIndex]
    }

    func next() -> (any TerminalElement)? {
        let (line, index, token) = next_()
        currentLine = line
        currentIndex = index
        if let token: any TerminalElement = token {
            currentToken = token
        }
        return token
    }

    func checkNext() -> (any TerminalElement)? {
        let (_, _, token) = next_()
        return token
    }

    private func next_() -> (Int, Int, (any TerminalElement)?) {
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

    func copy() -> Self {
        let instance = Self.init(tokensList: self.tokensList)
        instance.currentLine = currentLine
        instance.currentIndex = currentIndex
        instance.currentToken = currentToken
        return instance
    }

    func update(_ context: Context) {
        currentLine = context.currentLine
        currentIndex = context.currentIndex
        currentToken = context.currentToken
    }
}
