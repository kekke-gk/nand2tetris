//
//  JackTokenizer.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/04.
//

import Foundation

class JackTokenizer {
    let lines: [String]
    var tokens_list: [[Token]] = []

    let delimiters = {() -> [String] in
        return Symbol.allValues + [" "]
    }()

    init(fileURL: URL) {
        do {
            let textRead = try String(contentsOfFile: fileURL.relativePath, encoding: .utf8)
            print("ファイル読み込み成功")
            print(textRead)
            lines = textRead.components(separatedBy: "\n")
        } catch {
            print("ファイル読み込み失敗")
            print(error.localizedDescription)
            lines = []
        }
    }

    func tokenize() throws {
        var inComment = false
        var inString = false
        for line in lines {
//            print(line)
            var tokens: [Token] = []
            var curStr: String = ""
            let l = Array(line.trimmingCharacters(in: .whitespacesAndNewlines))
            for (i, c) in l.enumerated() {
                if inComment && c == "/" && l[i-1] == "*" {
                    inComment = false
                    continue
                }
                if inComment {
                    continue
                }
                if c == "/" && i+1 < l.count && l[i+1] == "*" {
                    inComment = true
                    continue
                }
                if c == "/" && i+1 < l.count && l[i+1] == "/" {
                    break
                }

                if inString {
                    if c == "\"" {
                        inString = false
                        curStr += String(c)
                        if let token = Token(str: curStr) {
                            tokens.append(token)
//                            print(token.XMLTag())
                        } else {
                            throw JackError.tokenize(curStr)
                        }
                        curStr = ""

                        continue
                    } else {
                        curStr += String(c)
                        continue
                    }
                }

                if curStr != "" && delimiters.contains(String(c)) {
                    if let token = Token(str: curStr) {
                        tokens.append(token)
//                        print(token.XMLTag())
                    } else {
                        throw JackError.tokenize(curStr)
                    }
                    if Symbol.allValues.contains(String(c)) {
                        if let token = Token(str: String(c)) {
                            tokens.append(token)
//                            print(token.XMLTag())
                        } else {
                            throw JackError.tokenize(String(c))
                        }
                    }
                    curStr = ""
                } else if curStr == "" && c == " " {
                    continue
                } else if curStr == "" && c == "\"" {
                    curStr += String(c)
                    inString = true
                } else if Symbol.allValues.contains(String(c)) {
                    if let token = Token(str: String(c)) {
                        tokens.append(token)
//                        print(token.XMLTag())
                    } else {
                        throw JackError.tokenize(String(c))
                    }
                }else {
                    curStr += String(c)
                }
            }
            if curStr != "" {
                if let token = Token(str: curStr) {
                    tokens.append(token)
//                    print(token.XMLTag())
                } else {
                    throw JackError.tokenize(curStr)
                }
            }
            self.tokens_list.append(tokens)
        }
    }
}
