//
//  JackError.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/06.
//

import Foundation

enum JackError: Error {
    case invalidPath(URL)
    case failedToOpenFile(URL)
    case failedToTokenize(Int, String)
    case failedToCompile(Int, String)
}
