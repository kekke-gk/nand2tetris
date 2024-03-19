//
//  JackAnalyzer.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/04.
//

import Foundation
import ArgumentParser

@main
struct JackAnalyzer: ParsableCommand {
    @Argument(help: "The .jack file path to compile.")
    var filePath: String

    mutating func run() throws {
        try tokenizeAndCompile()
    }

    func tokenizeAndCompile() throws {
        let fileURL = URL(filePath: filePath)
        let stem = fileURL.deletingPathExtension().lastPathComponent
        let outTURL = fileURL.deletingLastPathComponent().appendingPathComponent("\(stem)T_.xml")
        let outURL = fileURL.deletingLastPathComponent().appendingPathComponent("\(stem)_.xml")

        FileManager.default.createFile(atPath: outTURL.path(), contents: nil)
        FileManager.default.createFile(atPath: outURL.path(), contents: nil)

        let outTHandle = try FileHandle(forWritingTo: outTURL)
        let outHandle = try FileHandle(forWritingTo: outURL)

        let jackTokenizer = JackTokenizer(fileURL: fileURL)
        do {
            try jackTokenizer.tokenize()
            print("Tokenization ended successfully")

            outTHandle.write("<tokens>\n".data(using: .utf8)!)
            for tokens in jackTokenizer.tokensList {
                for token in tokens {
                    outTHandle.write("\(token)".data(using: .utf8)!)
                    outTHandle.write("\n".data(using: .utf8)!)
                }
            }
            outTHandle.write("</tokens>".data(using: .utf8)!)
            try outTHandle.close()
            print("Wrote to \(outTURL.path())")

            let compilationEngine = CompilationEngine(tokensList: jackTokenizer.tokensList)
            compilationEngine.compile()
            print("Compilation ended successfully")

            outHandle.write(String(describing: compilationEngine.element!).data(using: .utf8)!)
            try outHandle.close()
            print("Wrote to \(outURL.path())")
        } catch JackError.tokenize(let str) {
            print("Tokenize error")
            print(str)
        } catch JackError.compile(let lineNum, let str) {
            print("Compile error")
            print(lineNum, str)
        }
    }
}
