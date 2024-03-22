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
    @Argument(help: "The .jack file or the directory contains .jack files path to compile.")
    var filePath: String
    
    mutating func run() throws {
        let fileOrDirURL = URL(filePath: filePath)
        
        do {
            if fileOrDirURL.pathExtension == "jack" {
                try tokenizeAndCompile(fileURL: fileOrDirURL)
            } else if fileOrDirURL.isDirectory {
                let filePaths = try FileManager.default.contentsOfDirectory(at: fileOrDirURL, includingPropertiesForKeys: [])
                let jackFilePaths = filePaths.filter({ $0.pathExtension == "jack" })
                if jackFilePaths.count == 0 {
                    throw JackError.invalidPath(fileOrDirURL)
                }
                for (i, fileURL) in jackFilePaths.enumerated() {
                    print("(\(i+1)/\(jackFilePaths.count)): \(fileURL.relativePath)")
                    try tokenizeAndCompile(fileURL: fileURL)
                }
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
    
    func tokenizeAndCompile(fileURL: URL) throws {
        var jackTokenizer: JackTokenizer? = nil
        
        let stem = fileURL.deletingPathExtension().lastPathComponent
        let outTURL = fileURL.deletingLastPathComponent().appendingPathComponent("\(stem)T_.xml")
        let outURL = fileURL.deletingLastPathComponent().appendingPathComponent("\(stem)_.xml")
        
        FileManager.default.createFile(atPath: outTURL.path(), contents: nil)
        FileManager.default.createFile(atPath: outURL.path(), contents: nil)
        
        let outTHandle = try FileHandle(forWritingTo: outTURL)
        let outHandle = try FileHandle(forWritingTo: outURL)
        
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
    }
}

// https://stackoverflow.com/questions/65152001/how-to-check-if-swift-url-is-directory
extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
