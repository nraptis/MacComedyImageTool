//
//  BitLoader.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation

class BitLoader {
    
    var bits = [Bit]()
    func load() {
        
        bits.removeAll()
        
        var data: Data?
        
        if data == nil { data = FileUtils.shared.dataFromAssetsFile("words.txt") }
        if data == nil { data = FileUtils.shared.dataFromAssetsFile("words") }
        if data == nil { data = FileUtils.shared.dataFromAssetsFile("words.dat") }
        if data == nil { data = FileUtils.shared.dataFromAssetsFile("words.cfg") }
        if data == nil { data = FileUtils.shared.dataFromAssetsFile("words.rtf") }
        
        guard let data = data else {
            print("Could not load \"words.txt\" file...")
            return
        }
        
        guard let text = String(data: data, encoding: .utf8) else {
            print("Could not convert \"words.txt\" into UTF8...")
            return
        }
        
        loadBits(text)
    }
    
    static func linesFromText(_ text: String) -> [String] {
        let linesNL = text.split(separator: "\n")
            .map {
                $0
                    .uppercased()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter {
            $0
                .count > 0
        }
        
        var lines = [String]()
        var linesSet = Set<String>()
        for lineNL in linesNL {
            let linesCR = lineNL.split(separator: "\r")
                .map {
                    $0
                        .trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter {
                $0
                    .count > 0
            }
            for line in linesCR {
                if !linesSet.contains(line) {
                    linesSet.insert(line)
                    lines.append(line)
                }
            }
        }
        return lines.sorted {
            if $0.count == $1.count {
                return $0 < $1
            } else {
                return $0.count < $1.count
            }
            
        }
    }
    
    static func linesAsWordsFromText(_ text: String) -> [[String]] {
        
        let wholeLines = Self.linesFromText(text)
        
        var lines = [[String]]()
        var set = Set<[String]>()
        for line in wholeLines {
            var words = [String]()
            let splitOnSpace = line.split(separator: " ")
            for checkWord in splitOnSpace {
                let innerWords = checkWord.split(separator: "_")
                for innerWord in innerWords {
                    let word = innerWord.trimmingCharacters(in: .whitespacesAndNewlines)
                    if word.count > 0 {
                        words.append(word)
                    }
                }
            }
            if words.count > 0 {
                if !set.contains(words) {
                    lines.append(words)
                    set.insert(words)
                }
            }
        }
        return lines
    }
    
    private func loadBits(_ text: String) {
        bits.removeAll()
        
        let lines = Self.linesAsWordsFromText(text)
        
        for line in lines {
            if line.count <= 0 {
                
            } else if line.count <= 1 {
                bits.append(Bit.oneLine(word: line[0]))
            } else {
                var bestConfigurationLine1 = [String]()
                var bestConfigurationLine2 = [String]()
                bestConfigurationLine1.append(line[0])
                for i in 1..<line.count { bestConfigurationLine2.append(line[i]) }
                let count1 = bestConfigurationLine1.reduce(0) { $0 + $1.count }
                let count2 = bestConfigurationLine2.reduce(0) { $0 + $1.count }
                var bestDiff = abs(count1 - count2)
                var splitIndex = 2
                while splitIndex < line.count {
                    
                    var checkConfigurationLine1 = [String]()
                    var checkConfigurationLine2 = [String]()
                    for i in 0..<splitIndex { checkConfigurationLine1.append(line[i]) }
                    for i in splitIndex..<line.count { checkConfigurationLine2.append(line[i]) }
                    let count1 = checkConfigurationLine1.reduce(0) { $0 + $1.count }
                    let count2 = checkConfigurationLine2.reduce(0) { $0 + $1.count }
                    let checkDiff = abs(count1 - count2)
                    if checkDiff < bestDiff {
                        bestDiff = checkDiff
                        bestConfigurationLine1 = checkConfigurationLine1
                        bestConfigurationLine2 = checkConfigurationLine2
                    }
                    splitIndex += 1
                }
                bits.append(Bit.twoLine(line1: bestConfigurationLine1, line2: bestConfigurationLine2))
            }
        }
    }
}
