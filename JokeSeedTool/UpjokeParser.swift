//
//  UpjokeParser.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/29/22.
//

import Foundation

class UpjokeParser {
    
    func toWordList() -> [String] {
        
        var result = [String]()
        
        let urlString = "https://upjoke.com"
        guard let url = URL(string: urlString) else {
            return result
        }
        
        do {
        
            let data = try Data(contentsOf: url)
            
            guard let dataString = String(data: data, encoding: .utf8) else {
                return result
            }
            
            result = parseStep1(dataString: dataString)
                
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
        return result
    }
    
    func findStart(_ text: [Character], _ word: [Character], _ index: Int) -> Int? {
        var stringIndex = index
        while stringIndex < text.count {
            guard stringIndex + word.count <= text.count else {
                stringIndex += 1
                continue
            }
            var match = true
            for wordIndex in 0..<word.count {
                if text[stringIndex + wordIndex] != word[wordIndex] {
                    match = false
                    break
                }
            }
            if match {
                return stringIndex
            }
            stringIndex += 1
        }
        return nil
    }
    
    func findEnd(_ text: [Character], _ word: [Character], _ index: Int) -> Int? {
        var stringIndex = index
        while stringIndex < text.count {
            guard stringIndex + word.count <= text.count else {
                stringIndex += 1
                continue
            }
            var match = true
            for wordIndex in 0..<word.count {
                if text[stringIndex + wordIndex] != word[wordIndex] {
                    match = false
                    break
                }
            }
            if match {
                return stringIndex + word.count
            }
            stringIndex += 1
        }
        return nil
    }
    
    func substring(text: [Character], _ si: Int, _ ei: Int) -> String {
        var resultArray = [Character]()
        for i in si..<ei {
            resultArray.append(text[i])
        }
        return String(resultArray)
    }
    
    func parseStep1(dataString: String) -> [String] {
        
        var aTags = [String]()
        
        let text = Array(dataString)
        let opener = Array("<a href")
        let closer = Array("</a>")
        
        
        var index = 0
        while true {
            guard let start = findStart(text, opener, index) else {
                break
            }
            guard let end = findEnd(text, closer, start + 1) else {
                break
            }
            
            if end > start {
                let tag = substring(text: text, start, end)
                aTags.append(tag)
            }
            index = end + 1
        }
        let mappd = aTags.map { Array($0) }
        return parseStep2(aTags: mappd)
    }
    
    func parseStep2(aTags: [[Character]]) -> [String] {
        var result = [String]()
        
        let opener = Array("<a href=\"/")
        let closer = Array("-jokes")
        
        for tag in aTags {
            
            guard let startEnd = findEnd(tag, opener, 0) else {
                continue
            }
            guard let endStart = findStart(tag, closer, startEnd + 1) else {
                continue
            }
            let word = substring(text: tag, startEnd, endStart)
            result.append(word)
        }
        return result
    }
    
}
