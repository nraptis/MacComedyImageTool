//
//  Bit.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation

enum Bit: CustomStringConvertible {
    
    case oneLine(word: String)
    case twoLine(line1: [String], line2: [String])
    
    func isOneLiner() -> Bool {
        switch self {
        case .oneLine:
            return true
        case .twoLine:
            return false
        }
    }
    
    func line1Count() -> Int {
        switch self {
        case .oneLine(let word):
            return word.count
        case .twoLine(let line1, _):
            var result = line1.reduce(0) {
                $0 + $1.count
            }
            if line1.count > 1 {
                result += (line1.count - 1)
            }
            return result
        }
    }
    
    func line2Count() -> Int {
        switch self {
        case .oneLine:
            return 0
        case .twoLine(_ , let line2):
            var result = line2.reduce(0) {
                $0 + $1.count
            }
            if line2.count > 1 {
                result += (line2.count - 1)
            }
            return result
        }
    }
    
    func line1() -> String {
        switch self {
        case .oneLine(let word):
            return word
        case .twoLine(let line1, _):
            let result = line1.joined(separator: " ")
            return result
        }
    }
    
    func line2() -> String {
        switch self {
        case .oneLine:
            return ""
        case .twoLine(_, let line2):
            let result = line2.joined(separator: " ")
            return result
        }
    }
    
    var description: String {
        if isOneLiner() {
            return line1()
        } else {
            return "\(line1()) | \(line2())"
        }
    }
    
    var fileName: String {
        if isOneLiner() {
            return "\(line1().lowercased()).png"
        } else {
            return "\(line1().lowercased())_\(line2().lowercased()).png"
        }
    }
    
    var fileNameText: String {
        if isOneLiner() {
            return "_text_\(line1().lowercased()).png"
        } else {
            return "_text_\(line1().lowercased())_\(line2().lowercased()).png"
        }
    }
}
