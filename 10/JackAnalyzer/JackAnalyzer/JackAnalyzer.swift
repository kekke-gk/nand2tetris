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
//        let repeatCount = count ?? 2
//
//        for i in 1...repeatCount {
//            if includeCounter {
//                print("\(i): \(phrase)")
//            } else {
//                print(phrase)
//            }
//        }

        let jackTokenizer = JackTokenizer(fileURL: URL(filePath: filePath))
        do {
            try jackTokenizer.tokenize()
            for tokens in jackTokenizer.tokens_list {
                for token in tokens {
//                    print(token.XMLTag())
                }
            }
        } catch JackError.tokenize(let str) {
            print("Tokenize error")
            print(str)
        }
    }
}
