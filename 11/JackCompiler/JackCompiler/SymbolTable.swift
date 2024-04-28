//
//  SymbolTable.swift
//  JackCompiler
//
//  Created by Keisuke Gomi on 2024/03/23.
//

import Foundation

class VarSymbolTable {
    var symbols: [VarSymbol] = []

    func define(name: String, type: String = "", kind: VarSymbolKind, scope: Scope) throws {
//        print("try to define", name, "in", scope)
        guard symbols.filter({ $0.name == name && $0.scope == scope }).isEmpty else {
//            print("    Failed")
            throw JackError.failedToCompile(0, "\(name) is already defined in this scope.")
        }
        let symbol = VarSymbol(name: name, type: type, kind: kind, index: varCount(kind: kind, scope: scope), scope: scope)
//        print("defined", name, "in", scope, type, kind)
        symbols.append(symbol)
    }

    subscript(name: String, scope: Scope) -> VarSymbol? {
        get {
            let filteredSymbols = symbols.filter { $0.name == name && scope.isIn(scope: $0.scope) }
            if filteredSymbols.isEmpty {
                return nil
            }
            let sortedSymbols = filteredSymbols.sorted { $0.scope < $1.scope }
            return sortedSymbols[0]
        }
    }

    func varCount(kind: VarSymbolKind, scope: Scope) -> Int {
        symbols.filter { $0.kind == kind && $0.scope == scope }.count
    }

    func update(_ symbolTable: VarSymbolTable) throws {
        symbols = Array(Set(symbols).union(Set(symbolTable.symbols)))
    }
}

class FuncSymbolTable {
    var symbols: [FuncSymbol] = []

    func define(name: String, returnType: String = "", kind: FuncSymbolKind, scope: Scope) throws {
        guard symbols.filter({ $0.name == name && $0.scope == scope }).isEmpty else {
            throw JackError.failedToCompile(0, "\(name) is already defined in this scope.")
        }
        let symbol = FuncSymbol(name: name, returnType: returnType, kind: kind, scope: scope)
        print(symbol)
        symbols.append(symbol)
    }

    subscript(name: String, scope: Scope) -> FuncSymbol? {
        get {
            let filteredSymbols = symbols.filter { $0.name == name && scope.isIn(scope: $0.scope) }
            if filteredSymbols.isEmpty {
                return nil
            }
            let sortedSymbols = filteredSymbols.sorted { $0.scope < $1.scope }
            return sortedSymbols[0]
        }
    }

    func update(_ symbolTable: FuncSymbolTable) throws {
        symbols = Array(Set(symbols).union(Set(symbolTable.symbols)))
    }
}


struct VarSymbol: Hashable {
    var name: String
    var type: String
    var kind: VarSymbolKind
    var index: Int
    var scope: Scope
}

struct FuncSymbol: Hashable {
    var name: String
    var returnType: String
    var kind: FuncSymbolKind
    var scope: Scope
}

enum VarSymbolKind: String, Hashable {
    case static_ = "static"
    case field_ = "this"
    case arg_ = "argument"
    case var_ = "local"
    case class_ = "class"
}

enum FuncSymbolKind: String, Hashable {
    case function
    case method
    case constructor
}

enum Scope: Comparable, Hashable {
    case subroutine(String, String)
    case class_(String)
    case global

    func isIn(scope: Scope) -> Bool {
        switch self {
        case .subroutine(let className, let funcName):
            switch scope {
            case .subroutine(let cName, let fName):
                return className == cName && funcName == fName
            case .class_(let cName):
                return className == cName
            case .global:
                return true
            }


        case .class_(let className):
           switch scope {
           case .subroutine:
               return false
           case .class_(let cName):
               return className == cName
           case .global:
               return true
           }

        case .global:
            return scope == .global
        }
    }
}
