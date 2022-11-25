//
//  ViewModel.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation
import Cocoa

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
    
    static func preview() -> ViewModel {
        ViewModel(app: ApplicationController.preview())
    }
    
    let fontImageTool = FontImageTool()
    let bitLoader = BitLoader()
    let edgeFixerTool = EdgeFixerTool()
    
    let app: ApplicationController
    init(app: ApplicationController) {
        self.app = app
    }
    
    func printFonts() {
        for font in NSFontManager.shared.availableFonts {
            print(font)
        }
    }
    
    func printBits() {
        bitLoader.load()
        print("__BEGIN__PHRASES:")
        for bit in bitLoader.bits {
            print(bit)
        }
        print("__END__PHRASES:")
    }
    
    func generateWords() {
        bitLoader.load()
        performOnMainQueue {
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
            fontImageTool.processBit(bit)
            
            performOnMainQueue {
                self.loadingText = "\(index + 1) of \(self.bitLoader.bits.count)"
            }
        }
        
        
    }
    
    func stampWords() {
        
        if let image = FileUtils.shared.imageFromAssetsFile("background.png") {
            stampWords(image)
            return
        }
        if let image = FileUtils.shared.imageFromAssetsFile("background.jpg") {
            stampWords(image)
            return
        }
        
        if let image = FileUtils.shared.imageFromDocumentsFile("background.png") {
            stampWords(image)
            return
        }
        if let image = FileUtils.shared.imageFromDocumentsFile("background.jpg") {
            stampWords(image)
            return
        }
        
        if let image = FileUtils.shared.imageFromExportsFile("background.png") {
            stampWords(image)
            return
        }
        if let image = FileUtils.shared.imageFromExportsFile("background.jpg") {
            stampWords(image)
            return
        }
    }
    
    func stampWords(_ background: NSImage) {
        
        guard background.size.width > 512, background.size.height > 512 else {
            print("Background is too small, size is \(background.size.width) x \(background.size.height)")
            return
        }
        
        bitLoader.load()
        
        performOnMainQueue {
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
            
            if let textImage = FileUtils.shared.imageFromAssetsFile("[text]/\(bit.fileNameText)") {
                stampWords(bit, background, textImage)
            } else if let textImage = FileUtils.shared.imageFromAssetsFile(bit.fileNameText) {
                stampWords(bit, background, textImage)
            } else if let textImage = FileUtils.shared.imageFromDocumentsFile("[text]/\(bit.fileNameText)") {
                stampWords(bit, background, textImage)
            } else if let textImage = FileUtils.shared.imageFromDocumentsFile(bit.fileNameText) {
                stampWords(bit, background, textImage)
            } else if let textImage = FileUtils.shared.imageFromExportsFile("[text]/\(bit.fileNameText)") {
                stampWords(bit, background, textImage)
            } else if let textImage = FileUtils.shared.imageFromExportsFile(bit.fileNameText) {
                stampWords(bit, background, textImage)
            } else {
                print("No image file for bit: {\(bit)}")
            }
        }
        
        
        
    }
    
    func stampWords(_ bit: Bit, _ background: NSImage, _ textImage: NSImage) {
        guard background.size.width > 512, background.size.height > 512 else {
            print("Background is too small, size is \(background.size.width) x \(background.size.height)")
            return
        }
        guard textImage.size.width > 32, textImage.size.height > 32 else {
            print("Text image is too small, size is \(textImage.size.width) x \(textImage.size.height)")
            return
        }
        
        let backgroundWidth = Int(background.size.width + 0.5)
        let backgroundHeight = Int(background.size.height + 0.5)
        
        let textImageWidth = Int(textImage.size.width + 0.5)
        let textImageHeight = Int(textImage.size.height + 0.5)
        
        let insetSize = 260
        
        let finalWidth = textImageWidth - (insetSize)
        let finalHeight = textImageHeight - (insetSize)
        
        let backgroundRect = CGRect(x: (finalWidth / 2) - (backgroundWidth / 2),
                                    y: (finalHeight / 2) - (backgroundHeight / 2),
                                    width: backgroundWidth,
                                    height: backgroundHeight)
        
        let textImageRect = CGRect(x: (finalWidth / 2) - (textImageWidth / 2),
                                   y: (finalHeight / 2) - (textImageHeight / 2),
                                   width: textImageWidth,
                                   height: textImageHeight)
        
        let result = NSImage(size: NSSize(width: finalWidth, height: finalHeight))
        result.lockFocus()
        background.draw(in: backgroundRect)
        textImage.draw(in: textImageRect)
        result.unlockFocus()
        
        FileUtils.shared.saveImageAsPNGToExportsFile(result, "[stamped]/\(bit.fileName)")
    }
    
    func fixEdges() {
        let inputDirectory = FileUtils.shared.assetsPath("[edges]/")
        let outputDirectory = FileUtils.shared.exportsPath("[edges_fixed]/")
        
        let allFiles = edgeFixerTool.getAllFiles(inputDirectory: inputDirectory)
                            
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
            self.edgeFixerTool.fixFile(fileURL: fileURL, outputDirectory: outputDirectory)
        }
    }
    
}
