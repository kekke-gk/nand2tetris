//
//  JackCompiler.swift
//  JackCompiler
//
//  Created by Keisuke Gomi on 2024/03/23.
//

import Foundation
import ArgumentParser

@main
struct JackCompiler: ParsableCommand {
    @Argument(help: "The .jack file or the directory contains .jack files path to compile.")
    var filePath: String

    mutating func run() throws {
        let fileOrDirURL = URL(filePath: filePath)

        do {
            if fileOrDirURL.pathExtension == "jack" {
                try tokenizeAndCompile(jackURLs: [fileOrDirURL])
            } else if fileOrDirURL.isDirectory {
                let filePaths = try FileManager.default.contentsOfDirectory(at: fileOrDirURL, includingPropertiesForKeys: [])
                let jackFilePaths = filePaths.filter({ $0.pathExtension == "jack" })
                if jackFilePaths.count == 0 {
                    throw JackError.invalidPath(fileOrDirURL)
                }
                try tokenizeAndCompile(jackURLs: jackFilePaths)
            } else {
                throw JackError.invalidPath(fileOrDirURL)
            }
        } catch JackError.invalidPath(let fileURL) {
            print("The path is neither .jack file nor directory contains .jack files")
            print(fileURL.relativePath)
        } catch JackError.failedToOpenFile(let fileURL) {
            print("[Error] Failed to open file")
            print(fileURL.relativePath)
        } catch JackError.failedToTokenize(let lineNum, let message) {
            print("Tokenize error")
            print("At \(lineNum):", message)
        } catch JackError.failedToCompile(_, let message) {
            print("Compile error")
            print(message)
        }
    }

    func tokenizeAndCompile(jackURLs: [URL]) throws {
        let vmURLs = jackURLs.map { $0.deletingPathExtension().appendingPathExtension("vm") }

        var classElements: [String: Class] = [:]
        let varSymbolTable = VarSymbolTable()
        let funcSymbolTable = FuncSymbolTable()

        try varSymbolTable.define(name: "Memory", type: "Memory", kind: .class_, scope: .global)
        try varSymbolTable.define(name: "Keyboard", type: "Keyboard", kind: .class_, scope: .global)
        try varSymbolTable.define(name: "Screen", type: "Screen", kind: .class_, scope: .global)
        try varSymbolTable.define(name: "Sys", type: "Sys", kind: .class_, scope: .global)
        try varSymbolTable.define(name: "Array", type: "Array", kind: .class_, scope: .global)
        try varSymbolTable.define(name: "Output", type: "Output", kind: .class_, scope: .global)
        try varSymbolTable.define(name: "Math", type: "Math", kind: .class_, scope: .global)

        for (i, jackURL) in jackURLs.enumerated() {
            let jackTokenizer = try JackTokenizer(fileURL: jackURL)
            try jackTokenizer.tokenize()
            print("[\(i+1)/\(jackURLs.count)] Tokenization ended successfully")

            let compilationEngine = CompilationEngine(tokensList: jackTokenizer.tokensList)
            try compilationEngine.context.varSymbolTable.update(varSymbolTable)
            try compilationEngine.context.funcSymbolTable.update(funcSymbolTable)
            try compilationEngine.compile()
            print("[\(i+1)/\(jackURLs.count)] Compilation ended successfully")

            try varSymbolTable.update(compilationEngine.context.varSymbolTable)
            try funcSymbolTable.update(compilationEngine.context.funcSymbolTable)

            let className = jackURL.deletingPathExtension().lastPathComponent
            classElements[className] = (compilationEngine.element! as! Class)
        }

        for vmURL in vmURLs {
            let className = vmURL.deletingPathExtension().lastPathComponent
            let vmcode: String = try classElements[className]!.vmcode(varSymbolTable, funcSymbolTable)

            FileManager.default.createFile(atPath: vmURL.path(), contents: nil)
            let outHandle = try FileHandle(forWritingTo: vmURL)
            outHandle.write(vmcode.data(using: .utf8)!)
            try outHandle.close()
        }
    }
}

// https://stackoverflow.com/questions/65152001/how-to-check-if-swift-url-is-directory
extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
