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
//    @Flag(help: "Include a counter with each repetition.")
//    var includeCounter = false
//
//    @Option(name: .shortAndLong, help: "The number of times to repeat 'phrase'.")
//    var count: Int? = nil
//
//    @Argument(help: "The phrase to repeat.")
//    var phrase: String

    @Argument(help: "The .jack file path to compile.")
    var filePath: String

    mutating func run() throws {
//        try tokenize()
        try compile()
    }

    func compile() throws {
        let fileURL = URL(filePath: filePath)
        let stem = fileURL.deletingPathExtension().lastPathComponent
        let outURL = fileURL.deletingLastPathComponent().appendingPathComponent("\(stem)_.xml")
        print(outURL.absoluteString)
        print(outURL.path())

        FileManager.default.createFile(atPath: outURL.path(), contents: nil)

        let outHandle = try FileHandle(forWritingTo: outURL)

        let jackTokenizer = JackTokenizer(fileURL: fileURL)
        do {
            try jackTokenizer.tokenize()

            for tokens in jackTokenizer.tokensList {
                for token in tokens {
                    print(token)
                }
            }

            let compilationEngine = CompilationEngine(tokensList: jackTokenizer.tokensList)
            compilationEngine.compile()

//            for tokens in jackTokenizer.tokensList {
//                for token in tokens {
//                    outHandle.write("\(token)".data(using: .utf8)!)
//                    outHandle.write("\n".data(using: .utf8)!)
//                }
//            }
            try outHandle.close()
        } catch JackError.tokenize(let str) {
            print("Tokenize error")
            print(str)
        }

    }

    func tokenize() throws {
        let fileURL = URL(filePath: filePath)
        let stem = fileURL.deletingPathExtension().lastPathComponent
        let outURL = fileURL.deletingLastPathComponent().appendingPathComponent("\(stem)T_.xml")
        print(outURL.absoluteString)
        print(outURL.path())

        FileManager.default.createFile(atPath: outURL.path(), contents: nil)

        let outHandle = try FileHandle(forWritingTo: outURL)

        let jackTokenizer = JackTokenizer(fileURL: fileURL)
        do {
            try jackTokenizer.tokenize()
            outHandle.write("<tokens>\n".data(using: .utf8)!)
            for tokens in jackTokenizer.tokensList {
                for token in tokens {
//                    print(token.XMLTag())
//                    try token.XMLTag().write(toFile: outURL.absoluteString, atomically: true, encoding: .utf8)
                    outHandle.write("\(token)".data(using: .utf8)!)
                    outHandle.write("\n".data(using: .utf8)!)
                }
            }
            outHandle.write("</tokens>".data(using: .utf8)!)
            try outHandle.close()
        } catch JackError.tokenize(let str) {
            print("Tokenize error")
            print(str)
        }
    }
}
