//
//  ProgramStructure.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/16.
//

import Foundation

class Class: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "class" }

    var className: String?

    var subroutineDecs: [SubroutineDec] = []

    func compile(_ context: Context) throws {
        try must(context, [Keyword.class_])
        let identifier = try must(context, Identifier.self)
        className = identifier.value()
        try must(context, [Symbol.curlyBracketL])

        try context.varSymbolTable.define(name: className!, type: className!, kind: .class_, scope: .global)

        while let _ = may(context, ClassVarDec.self) {}

        while let subroutineDec = may(context, SubroutineDec.self) {
            subroutineDecs.append(subroutineDec)
        }

        try must(context, [Symbol.curlyBracketR])
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String  {
        var code = ""
        for subroutineDec in subroutineDecs {
            code += try subroutineDec.vmcode(varSymbolTable, funcSymbolTable)
        }
        return code
    }
}

class ClassVarDec: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "classVarDec" }

    func compile(_ context: Context) throws {
        let keyword = try must(context, [Keyword.static_, .field_])
        let kind: VarSymbolKind = keyword == .static_ ? .static_ : .field_
        let type = try must(context, Type.self)
        let varName = try must(context, Identifier.self)

        try context.varSymbolTable.define(name: varName.value(), type: type.value!, kind: kind, scope: context.getCurrentScope())

        while let _ = may(context, [Symbol.comma]) {
            let varName = try must(context, Identifier.self)
            try context.varSymbolTable.define(name: varName.value(), type: type.value!, kind: kind, scope: context.getCurrentScope())
        }

        try must(context, [Symbol.semicolon])
    }
}

class Type: NonTerminalTagLessElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "" }

    var value: String?

    func compile(_ context: Context) throws {
        if let type = may(context, [Keyword.int_, .char_, .boolean_]) {
            value = type.value()
        } else {
            let type = try must(context, Identifier.self)
            value = type.value()
        }
    }
}

class SubroutineDec: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "subroutineDec" }

    var funcName: String?

    var className: String?
    var subroutineBody: SubroutineBody?

    var scope: Scope?
    var funcScope: Scope?

    func compile(_ context: Context) throws {
        let keyword = try must(context, [Keyword.constructor_, .function_, .method_])

        let type: String
        if let void = may(context, [Keyword.void_]) {
            type = void.value()
        } else {
            let t = try must(context, Type.self)
            type = t.value!
        }
        let identifier = try must(context, Identifier.self)
        self.funcName = identifier.value()

        scope = context.getCurrentScope()
        if case .subroutine(let className, _) = scope {
            self.className = className
        } else {
            throw JackError.failedToCompile(0, "This subroutine is defined outside a class.")
        }

        let kind = FuncSymbolKind(rawValue: keyword.value())!
        funcScope = Scope.class_(className!)
        try context.funcSymbolTable.define(name: self.funcName!, returnType: type, kind: kind, scope: funcScope!)

        try must(context, [Symbol.bracketL])
        let parameterList = try must(context, ParameterList.self)
        try must(context, [Symbol.bracketR])
        subroutineBody = try must(context, SubroutineBody.self)
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        guard let funcSymbol = funcSymbolTable[funcName!, funcScope!] else {
            throw JackError.failedToCompile(0, "\(funcName!) is not defined.")
        }

        let varNum = varSymbolTable.varCount(kind: .var_, scope: scope!)
        var code = "function \(className!).\(funcName!) \(varNum)\n"

        switch funcSymbol.kind {
        case .constructor:
            let fieldNum = varSymbolTable.varCount(kind: .field_, scope: funcScope!)
            code += "push constant \(fieldNum)\n"
            code += "call Memory.alloc 1\n"
            code += "pop pointer 0\n"
        case .method:
            code += "push argument 0\n"
            code += "pop pointer 0\n"
        default:
            break
        }

        code += try subroutineBody!.vmcode(varSymbolTable, funcSymbolTable)

        return code
    }
}

class ParameterList: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "parameterList" }

    func compile(_ context: Context) throws {
        let scope = context.getCurrentScope()

        guard case .subroutine(let className, let funcName) = scope else {
            throw JackError.failedToCompile(0, "\(name) has wrong scope.")
        }

        guard let funcSymbol = context.funcSymbolTable[funcName, .class_(className)] else {
            throw JackError.failedToCompile(0, "\(funcName) is not defined.")
        }

        if let type = may(context, Type.self) {
            let identifier = try must(context, Identifier.self)
            try context.varSymbolTable.define(name: identifier.value(), type: type.value!, kind: .arg_, scope: scope, definedIn: funcSymbol.kind)
        } else {
            return
        }

        while let _ = may(context, [Symbol.comma]) {
            let type = try must(context, Type.self)
            let identifier = try must(context, Identifier.self)
            try context.varSymbolTable.define(name: identifier.value(), type: type.value!, kind: .arg_, scope: scope, definedIn: funcSymbol.kind)
        }
    }
}

class SubroutineBody: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "subroutineBody" }

    var statements: Statements?

    func compile(_ context: Context) throws {
        try must(context, [Symbol.curlyBracketL])

        while let _ = may(context, VarDec.self) {}

        statements = try must(context, Statements.self)
        try must(context, [Symbol.curlyBracketR])
    }

    func vmcode(_ varSymbolTable: VarSymbolTable, _ funcSymbolTable: FuncSymbolTable) throws -> String {
        return try statements!.vmcode(varSymbolTable, funcSymbolTable)
    }
}

class VarDec: NonTerminalElement {
    var elements: [any Element] = []
    required init() {}

    var name: String { "varDec" }

    func compile(_ context: Context) throws {
        try must(context, [Keyword.var_])
        let type = try must(context, Type.self)
        let identifier = try must(context, Identifier.self)

        let scope = context.getCurrentScope()

        try context.varSymbolTable.define(name: identifier.value(), type: type.value!, kind: .var_, scope: scope)

        while let _ = may(context, [Symbol.comma]) {
            let identifier = try must(context, Identifier.self)
            try context.varSymbolTable.define(name: identifier.value(), type: type.value!, kind: .var_, scope: scope)
        }

        try must(context, [Symbol.semicolon])
    }
}
