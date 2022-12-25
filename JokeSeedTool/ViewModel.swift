//
//  ViewModel.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation
import Cocoa
import AppKit

func performOnMainQueue(_ block: () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}

class ViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var loadingText = ""
    @Published var bitCount = 0
    
    static func preview() -> ViewModel {
        ViewModel(app: ApplicationController.preview())
    }
    
    let fontImageTool = FontImageTool()
    let stamperTool = TextOnBackgroundStamperTool()
    let bitLoader = BitLoader()
    let edgeFixerTool = EdgeFixerTool()
    
    let app: ApplicationController
    init(app: ApplicationController) {
        self.app = app
        self.bitLoader.load()
        self.bitCount = bitLoader.bits.count
        
        //upjoke_seeds.txt
        //uniquifySeeds("upjoke_seeds.txt")
        //de_double_filenames()
    }
    
    private var legalCharacters: Set<Character> {
        let string = "abcdefghijklmnopqrstuvwxyz0123456789"
        let array = Array(string)
        let set = Set<Character>(array)
        return set
    }
    
    private func escapeToUnderscore(_ string: String) -> String {
        let legal = legalCharacters
        var array = Array(string.lowercased())
        for index in array.indices {
            let char = array[index]
            if !legal.contains(char) {
                array[index] = "_"
            }
        }
        return String(array)
    }
    
    func de_double_filenames() {
        
        let directory = FileUtils.shared.assetsPath("[borq]")
        let directoryOutput = FileUtils.shared.exportsPath("[borq]/")
        
        let files = FileUtils.shared.getAllFiles(inputDirectory: directory)
        
        for file in files {
            
            let nameOriginal = file.absoluteString
            
            if let data = try? Data(contentsOf: file) {
                let nameTrimmed = (nameOriginal as NSString).lastPathComponent
                let split = nameTrimmed.split(separator: ".")
                if let first = split.first {
                    let newName = escapeToUnderscore(String(first))
                    
                    let exportDir = directoryOutput + newName + ".png"
                    
                    FileUtils.shared.saveDataToFilePath(data, exportDir)
                    print("data \(data.count), name = \(first)")
                }
                
            }
            
            
        }
        
        
    }
    
    func uniquifySeeds(_ fileName: String) {
        
        let path = FileUtils.shared.assetsPath(fileName)
        guard let data = FileUtils.shared.dataFromFilePath(path) else {
            print("no data at \(path)")
            return
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            print("no string at \(path)")
            return
        }
        
        let lines = BitLoader.linesFromText(string)
        
        for (index, line) in lines.enumerated() {
            if (index % 2) == 1 {
                print(line.lowercased())
            }
        }
        print("\(lines.count) words")
    }
    
    func printFonts() {
        for font in NSFontManager.shared.availableFonts {
            print(font)
        }
    }
    
    func printBits() {
        bitLoader.load()
        self.bitCount = bitLoader.bits.count
        print("__BEGIN__PHRASES:")
        for bit in bitLoader.bits {
            print(bit)
        }
        print("__END__PHRASES:")
    }
    
    func generateWords() {
        bitLoader.load()
        performOnMainQueue {
            self.bitCount = bitLoader.bits.count
            isLoading = true
            loadingText = "\(1) of \(bitLoader.bits.count)"
        }
        DispatchQueue.global(qos: .default).async {
            self.generateWordsAsync()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
                self.loadingText = ""
            }
        }
    }
    
    private func generateWordsAsync() {
        for (index, bit) in bitLoader.bits.enumerated() {
            autoreleasepool {
                fontImageTool.processBit(bit)
            }
            performOnMainQueue {
                self.loadingText = "\(index + 1) of \(self.bitLoader.bits.count)"
            }
        }
        
        
    }
    
    func stampWords() {
        autoreleasepool {
            if let background = stamperTool.getBackground() {
                stampWords(background)
            } else {
                print("Cannot find background image. \"background.png\" or \"background.jpg\" in \"Assets\" folder...")
            }
        }
    }
    
    func stampWords(_ background: NSImage) {
        
        guard background.size.width > 512, background.size.height > 512 else {
            print("Background is too small, size is \(background.size.width) x \(background.size.height)")
            return
        }
        
        bitLoader.load()
        
        performOnMainQueue {
            self.bitCount = bitLoader.bits.count
            isLoading = true
            loadingText = "\(1) of \(bitLoader.bits.count)"
        }
        
        DispatchQueue.global(qos: .default).async {
            self.stampWordsAsync(background)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
                self.loadingText = ""
            }
        }
        
    }
    
    func stampWordsAsync(_ background: NSImage) {
        for (index, bit) in bitLoader.bits.enumerated() {
            performOnMainQueue {
                self.loadingText = "\(index + 1) of \(self.bitLoader.bits.count)"
            }
            autoreleasepool {
                if let textImage = self.stamperTool.textImageFor(bit: bit) {
                    self.stamperTool.stampWords(bit, background, textImage)
                } else {
                    print("Could notfind text image for bit \(bit), expected in \"\(FileUtils.shared.assetsPath("[text]/\(bit.fileNameText)"))\"")
                }
            }
        }
    }
    
    
    
    func fixEdges() {
        let inputDirectory = FileUtils.shared.assetsPath("[edges]/")
        let outputDirectory = FileUtils.shared.exportsPath("[edges_fixed]/")
        
        let allFiles = FileUtils.shared.getAllFiles(inputDirectory: inputDirectory)
        
        if allFiles.count <= 0 {
            print("There are no files in \"\(inputDirectory)\" to fix edges on...")
            return
        }
        
        performOnMainQueue {
            isLoading = true
            loadingText = "\(1) of \(allFiles.count)"
        }
        
        DispatchQueue.global(qos: .default).async {
            self.fixEdgesAsync(allFiles: allFiles, outputDirectory: outputDirectory)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
                self.loadingText = ""
            }
        }
    }
    
    
    func fixEdgesAsync(allFiles: [URL], outputDirectory: String) {
    
        for (index, fileURL) in allFiles.enumerated() {
            performOnMainQueue {
                self.loadingText = "\(index + 1) of \(allFiles.count)"
            }
            autoreleasepool {
                self.edgeFixerTool.fixFile(fileURL: fileURL, outputDirectory: outputDirectory)
            }
        }
    }
    
    func parseUpjoke() {
        
        performOnMainQueue {
            isLoading = true
            loadingText = "downloading..."
        }
        
        DispatchQueue.global(qos: .default).async {
            self.parseUpjokeAsync()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isLoading = false
                self.loadingText = ""
            }
        }
    }
    
    func parseUpjokeAsync() {
        
        let parser = UpjokeParser()
        let words = parser.toWordList()
        
        print("=== BEGIN UPJOKE DUMP ===")
        
        for word in words {
            print(word)
        }
        
        print("=== END UPJOKE DUMP ===")
    }
    
}
