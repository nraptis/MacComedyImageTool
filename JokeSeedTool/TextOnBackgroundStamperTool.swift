//
//  TextOnBackgroundStamperTool.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/27/22.
//

import Foundation
import Cocoa

class TextOnBackgroundStamperTool {
    
    func getBackground() -> NSImage? {
        
        if let image = FileUtils.shared.imageFromAssetsFile("background.png") {
            return image
        }
        if let image = FileUtils.shared.imageFromAssetsFile("background.jpg") {
            return image
        }
        
        if let image = FileUtils.shared.imageFromDocumentsFile("background.png") {
            return image
        }
        if let image = FileUtils.shared.imageFromDocumentsFile("background.jpg") {
            return image
        }
        
        if let image = FileUtils.shared.imageFromExportsFile("background.png") {
            return image
        }
        if let image = FileUtils.shared.imageFromExportsFile("background.jpg") {
            return image
        }
        return nil
    }
    
    func textImageFor(bit: Bit) -> NSImage? {
        if let textImage = FileUtils.shared.imageFromAssetsFile("[text]/\(bit.fileNameText)") {
            return textImage
        } else if let textImage = FileUtils.shared.imageFromAssetsFile(bit.fileNameText) {
            return textImage
        } else if let textImage = FileUtils.shared.imageFromDocumentsFile("[text]/\(bit.fileNameText)") {
            return textImage
        } else if let textImage = FileUtils.shared.imageFromDocumentsFile(bit.fileNameText) {
            return textImage
        } else if let textImage = FileUtils.shared.imageFromExportsFile("[text]/\(bit.fileNameText)") {
            return textImage
        } else if let textImage = FileUtils.shared.imageFromExportsFile(bit.fileNameText) {
            return textImage
        }
        return nil
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
        
        //let insetSize = 260
        let insetSize = 540
        
        
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
}
