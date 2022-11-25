//
//  FontImageTool.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation
import Cocoa
import SwiftUI

class FontImageTool {
    
    let fontName = "CandyBeans"
    //let fontName = "Arial-BoldMT"
    //let fontName = "Helvetica"
    
    //let fontName = "HelveticaNeue-Bold"
    
    
    let imageWidth = 3800
    let imageHeight = 2600
    
    let imageScale1234: CGFloat = 0.45 + 0.08
    
    let imageScale_min: CGFloat = 0.25 + 0.07
    let imageScale3: CGFloat = 0.35 + 0.06
    let imageScale4: CGFloat = 0.45 + 0.05
    let imageScale5: CGFloat = 0.55 + 0.04
    let imageScale6: CGFloat = 0.65 + 0.03
    let imageScale7: CGFloat = 0.75 + 0.02
    let imageScale_max: CGFloat = 0.85
    
    let spacingBetweenLinesTextImageExport = 200
    let paddingAroundEdgesTextImageExport = 400
    
    private let cropper = ImageTransparencyCropper()
    
    private let fontImagePadding = 128
    func imageSize(forText text: String, withFont font: NSFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let result = NSString(string: text).size(withAttributes: attributes)
        
        /*let result = NSString(string: text).boundingRect(with: NSSize(width: 1000000, height: 1000000), options: NSString.DrawingOptions.init(rawValue: 0), attributes: attributes, context: nil)
         */
        
        return NSSize(width: Int(result.width + 0.5) + fontImagePadding + fontImagePadding,
                      height: Int(result.height + 0.5) + fontImagePadding + fontImagePadding)
    }
    
    func image(forText text: String, withFont font: NSFont) -> NSImage? {
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines).count <= 0 { return nil }
        
        let size = imageSize(forText: text, withFont: font)
        
        guard size.width > 0 && size.height > 0 else {
            print("Invalid calculated size for \"\(text)\", size \(size.width) x \(size.height), exiting...")
            return nil
        }
        
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.red,
        ]
        let image: NSImage = NSImage(size: size)
        guard let bitmapRepresentation = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                          pixelsWide: Int(size.width + 0.5),
                                                          pixelsHigh: Int(size.height + 0.5),
                                                          bitsPerSample: 8,
                                                          samplesPerPixel: 4,
                                                          hasAlpha: true,
                                                          isPlanar: false,
                                                          colorSpaceName: NSColorSpaceName.calibratedRGB,
                                                          bytesPerRow: 0,
                                                          bitsPerPixel: 0) else {
            print("Could not get bitmap representation for \"\(text)\", size \(image.size.width) x \(image.size.height), exiting...")
            return nil
        }
        
        image.addRepresentation(bitmapRepresentation)
        image.lockFocus()
        
        //text.draw(in: textRect, withAttributes: textFontAttributes)
        text.draw(at: NSPoint(x: fontImagePadding, y: fontImagePadding), withAttributes: textFontAttributes)
        
        image.unlockFocus()
        return image
    }
    
    func getLineImage(_ line: String) -> NSImage? {
        
        if line.trimmingCharacters(in: .whitespacesAndNewlines).count <= 0 { return nil }
        
        var maxWidth = imageWidth
        
        if line.count <= 2 {
            maxWidth = Int(round(CGFloat(maxWidth) * imageScale_min))
        } else if line.count <= 3 {
            maxWidth = Int(round(CGFloat(maxWidth) * imageScale3))
        } else if line.count <= 4 {
            maxWidth = Int(round(CGFloat(maxWidth) * imageScale4))
        } else if line.count <= 5 {
            maxWidth = Int(round(CGFloat(maxWidth) * imageScale5))
        } else if line.count <= 6 {
            maxWidth = Int(round(CGFloat(maxWidth) * imageScale6))
        } else if line.count <= 7 {
            maxWidth = Int(round(CGFloat(maxWidth) * imageScale7))
        } else {
            maxWidth = Int(round(CGFloat(maxWidth) * imageScale_max))
        }
        
        var chosenFont: NSFont? = nil
        
        let fontSizeStep = 25
        let fontMinSize = 25
        var fontSize = fontMinSize
        var fudge = 0
        while fudge < 2048 {
            guard let font = NSFont(name: fontName, size: CGFloat(fontSize)) else {
                print("Cannot load font with name \"\(fontName)\" of size \(fontSize), exiting...")
                return nil
            }
            
            let imageSize = imageSize(forText: line, withFont: font)
            if chosenFont == nil { chosenFont = font }
            if Int(imageSize.width) > maxWidth {
                break
            } else {
                chosenFont = font
                fontSize += fontSizeStep
                fudge += 1
            }
        }
        
        guard let font = chosenFont else {
            print("No font selected for \(line), cannot product image...")
            return nil
        }
        
        guard let image = image(forText: line, withFont: font) else {
            print("Image could not be created for line \"\(line)\" with font \(font)")
            return nil
        }
        
        //return image
        
        guard let result = cropper.trimmingTransparentPixels(image: image) else {
            print("Image could not be cropped for line \"\(line)\" with font \(font), original image was \(image.size.width) x \(image.size.height)")
            return nil
        }
        
        return result
    }
    
    func processBit(_ bit: Bit) {
        if let image1 = getLineImage(bit.line1()) {
            if let image2 = getLineImage(bit.line2()) {
                
                let resultWidth = Int(max(image1.size.width, image2.size.width)) + (paddingAroundEdgesTextImageExport + paddingAroundEdgesTextImageExport)
                let resultHeight = Int(image1.size.height + image2.size.height) + (paddingAroundEdgesTextImageExport + paddingAroundEdgesTextImageExport) + spacingBetweenLinesTextImageExport
                
                let rect1 = CGRect(x: resultWidth / 2 - Int(image1.size.width) / 2,
                                   y: paddingAroundEdgesTextImageExport + Int(image2.size.height) + spacingBetweenLinesTextImageExport,
                                   width: Int(image1.size.width),
                                   height: Int(image1.size.height))
                
                let rect2 = CGRect(x: resultWidth / 2 - Int(image2.size.width) / 2,
                                   y: paddingAroundEdgesTextImageExport,
                                   width: Int(image2.size.width),
                                   height: Int(image2.size.height))
                
                let image: NSImage = NSImage(size: NSSize(width: resultWidth, height: resultHeight))
                image.lockFocus()
                image1.draw(in: rect1)
                image2.draw(in: rect2)
                image.unlockFocus()
                FileUtils.shared.saveImageAsPNGToExportsFile(image, "[words]/\(bit.fileNameText)")
                
                
                //FileUtils.shared.saveImageAsPNGToExportsFile(image1, "[words]/1_\(bit.fileNameText)")
                //FileUtils.shared.saveImageAsPNGToExportsFile(image2, "[words]/2_\(bit.fileNameText)")
                
            } else {
                
                let resultWidth = Int(image1.size.width) + (paddingAroundEdgesTextImageExport + paddingAroundEdgesTextImageExport)
                let resultHeight = Int(image1.size.height) + (paddingAroundEdgesTextImageExport + paddingAroundEdgesTextImageExport)
                
                let rect = CGRect(x: resultWidth / 2 - Int(image1.size.width) / 2,
                                  y: paddingAroundEdgesTextImageExport,
                                  width: Int(image1.size.width),
                                  height: Int(image1.size.height))
                
                let image: NSImage = NSImage(size: NSSize(width: resultWidth, height: resultHeight))
                image.lockFocus()
                image1.draw(in: rect)
                image.unlockFocus()
                FileUtils.shared.saveImageAsPNGToExportsFile(image, "[words]/\(bit.fileNameText)")
            }
        }
    }
}
