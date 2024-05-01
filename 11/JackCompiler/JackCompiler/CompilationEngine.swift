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

    func compile() throws {
        element = try Class(context)
    }
}

class Context: CustomStringConvertible {
    let tokensList: [[any TerminalElement]]
    var currentLine: Int = 0
    var currentIndex: Int = 0
    var currentToken: any TerminalElement

    var varSymbolTable: VarSymbolTable
    var funcSymbolTable: FuncSymbolTable

    var elementsStack: [any Element] = []

    var description: String {
        return "(\(currentLine), \(currentIndex)), \(currentToken)"
    }

    required init(tokensList: [[any TerminalElement]]) {
        self.tokensList = tokensList

        while tokensList[currentLine].count == 0 {
            currentLine += 1
        }
        currentToken = tokensList[currentLine][currentIndex]

        varSymbolTable = VarSymbolTable()
        funcSymbolTable = FuncSymbolTable()
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
        instance.update(self)
        return instance
    }

    func update(_ context: Context) {
        currentLine = context.currentLine
        currentIndex = context.currentIndex
        currentToken = context.currentToken

        varSymbolTable = context.varSymbolTable
        funcSymbolTable = context.funcSymbolTable
    }

    func getCurrentScope() -> Scope {
        var fun: SubroutineDec? = nil
        for element in elementsStack.reversed() {
            if let f = element as? SubroutineDec {
                fun = f
            }

            if let cls = element as? Class {
                let className = cls.className!
                if let f = fun {
                    return .subroutine(className, f.funcName!)
                } else {
                    return .class_(className)
                }
            }
        }
        return .global
    }

    enum StatementKind: Hashable {
        case if_
        case while_
    }

    struct ScopeAndKind: Hashable {
        let scope: Scope
        let kind: StatementKind
    }

    var uniqueNumbers: [ScopeAndKind: Int] = [:]

    func getUniqueNumber(scope: Scope, kind: StatementKind) -> Int {
        let sk = ScopeAndKind(scope: scope, kind: kind)

        if !uniqueNumbers.keys.contains(sk) {
            uniqueNumbers[sk] = 0
        }

        let num: Int = uniqueNumbers[sk]!
        uniqueNumbers[sk] = num + 1
        return num
    }
}
