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
        var jackTokenizer: JackTokenizer? = nil
        
        do {
            jackTokenizer = try JackTokenizer(fileURL: fileURL)
            try jackTokenizer!.tokenize()
            print("Tokenization ended successfully")
            
            outTHandle.write("<tokens>\n".data(using: .utf8)!)
            for tokens in jackTokenizer!.tokensList {
                for token in tokens {
                    outTHandle.write("\(token)".data(using: .utf8)!)
                    outTHandle.write("\n".data(using: .utf8)!)
                }
            }
            outTHandle.write("</tokens>".data(using: .utf8)!)
            try outTHandle.close()
            print("Wrote to \(outTURL.path())")
            
            let compilationEngine = CompilationEngine(tokensList: jackTokenizer!.tokensList)
            try compilationEngine.compile()
            print("Compilation ended successfully")
            
            outHandle.write(String(describing: compilationEngine.element!).data(using: .utf8)!)
            try outHandle.close()
            print("Wrote to \(outURL.path())")
        } catch JackError.failedToOpenFile(let fileURL) {
            print("[Error] Failed to open file")
            print(fileURL.relativePath)
        } catch JackError.failedToTokenize(let lineNum, let message) {
            print("Tokenize error")
            print("At \(lineNum):", message)
        } catch JackError.failedToCompile(let lineNum, let message) {
            print("Compile error")
            if lineNum - 1 >= 0 {
                print("\(lineNum-1):", jackTokenizer!.lines[lineNum-1])
            }
            print("\(lineNum):", jackTokenizer!.lines[lineNum])
            if lineNum + 1 < jackTokenizer!.lines.count {
                print("\(lineNum+1):", jackTokenizer!.lines[lineNum+1])
            }
            print(message)
        }
    }
}
