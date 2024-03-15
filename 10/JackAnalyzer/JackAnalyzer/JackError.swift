//
//  JackError.swift
//  JackAnalyzer
//
//  Created by Keisuke Gomi on 2024/03/06.
//

import Foundation

enum JackError: Error {
    case tokenize(String)
    case compile(Int, String)
}
