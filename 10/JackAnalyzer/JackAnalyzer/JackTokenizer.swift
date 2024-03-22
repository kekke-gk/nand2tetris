//
//  JackTokenizer.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/04.
//

import Foundation

class JackTokenizer {
    let lines: [String]
    var tokensList: [[any TerminalElement]] = []
    
    var inComment = false
    var inString = false
    var tokens: [any TerminalElement] = []
    var curStr: String = ""
    
    init(fileURL: URL) throws {
        do {
            let textRead = try String(contentsOfFile: fileURL.relativePath, encoding: .utf8)
            lines = textRead.components(separatedBy: "\n")
        } catch {
            throw JackError.failedToOpenFile(fileURL)
        }
    }
    
    private func appendToken() throws {
        guard curStr.trimmingCharacters(in: .whitespaces) != "" else {
            return
        }
        if let token = initTerminalElement(curStr) {
            tokens.append(token)
        } else {
            throw JackError.tokenize(curStr)
        }
        curStr = ""
    }
    
    func tokenize() throws {
        inComment = false
        inString = false
        
        for line in lines {
            tokens = []
            curStr = ""
            
            let l = Array(line.trimmingCharacters(in: .whitespacesAndNewlines)).map { String($0) }
            for (i, c) in l.enumerated() {
                if inComment && l[i-1] == "*" && c == "/" {
                    inComment = false
                    continue
                }
                if inComment {
                    continue
                }
                if c == "/" && i+1 < l.count {
                    if l[i+1] == "*" {
                        inComment = true
                        continue
                    }
                    if l[i+1] == "/" {
                        break
                    }
                }
                
                if inString {
                    curStr += c
                    if c == "\"" {
                        inString = false
                        try appendToken()
                    }
                    continue
                }
                
                switch c {
                case " ":
                    try appendToken()
                case "\"":
                    curStr += c
                    inString = true
                case let c where Symbol.allValues.contains(c):
                    try appendToken()
                    curStr = c
                    try appendToken()
                default:
                    curStr += c
                }
            }
            if curStr != "" {
                try appendToken()
            }
            self.tokensList.append(tokens)
        }
    }
}
