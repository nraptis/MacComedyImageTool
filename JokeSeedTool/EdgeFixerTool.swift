//
//  EdgeFixerTool.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation
import AppKit

class EdgeFixerTool {
    
    let edgeColorRed: UInt8 = 255
    let edgeColorGreen: UInt8 = 255
    let edgeColorBlue: UInt8 = 255
    let edgeTolerance: UInt8 = 16
    
    let resultPadding = 80
    
    func getAllFiles(inputDirectory: String) -> [URL] {
        let directoryURL = URL(fileURLWithPath: inputDirectory)
        do {
            if directoryURL.startAccessingSecurityScopedResource() {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles])
                directoryURL.stopAccessingSecurityScopedResource()

                return fileURLs
            }
        } catch {
            directoryURL.stopAccessingSecurityScopedResource()
            print("Could not load directory \"\(inputDirectory)\"")
        }
        return [URL]()
    }
    
    func fixFile(fileURL: URL, outputDirectory: String) {
        do {
            let data = try Data(contentsOf: fileURL)
            if let image = NSImage(data: data) {
                fixImage(image, fileURL.lastPathComponent, outputDirectory)
            } else {
                print("Could not load image for \(fileURL.absoluteString), with \(data.count) bytes")
            }
        } catch let error {
            print("Could not load data for \(fileURL.absoluteString)")
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func trim(image: NSImage, rect: CGRect) -> NSImage {
        let result = NSImage(size: rect.size)
        result.lockFocus()
        let destRect = CGRect(origin: .zero, size: result.size)
        image.draw(in: destRect, from: rect, operation: .copy, fraction: 1.0)
        result.unlockFocus()
        return result
    }
    
    private func fixImage(_ image: NSImage, _ name: String, _ outputDirectory: String) {
        
        var imageWidth = Int(image.size.width + 0.5)
        var imageHeight = Int(image.size.height + 0.5)
        
        if imageWidth < 32 || imageHeight < 32 {
            print("Image \(imageWidth) x \(imageHeight) with path \"\(name)\" is too small to fix...")
            return
        }
        
        let cgImageRect = NSRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let unsafeRect = UnsafeMutablePointer<NSRect>.allocate(capacity: 1)
        unsafeRect.initialize(to: cgImageRect)
        guard let cgImage = image.cgImage(forProposedRect: unsafeRect, context: NSGraphicsContext.current, hints: nil) else {
            print("Image \(imageWidth) x \(imageHeight) with path \"\(name)\" cannot convert to CGImage...")
            return
        }
        
        imageWidth = cgImage.width
        imageHeight = cgImage.height
        
        if imageWidth < 32 || imageHeight < 32 {
            print("Image (CGImage) \(imageWidth) x \(imageHeight) with path \"\(name)\" is too small...")
            return
        }
        
        guard cgImage.bitsPerComponent > 0 else {
            print("Image \(imageWidth) x \(imageHeight) with path \"\(name)\" bits per component is \(cgImage.bitsPerComponent), must me > 0...")
            return
        }
        
        guard let imageData = cgImage.dataProvider?.data else {
            print("Image \(imageWidth) x \(imageHeight) with path \"\(name)\" no data provider...")
            return
        }
        
        guard let imageBytes = CFDataGetBytePtr(imageData) else {
            print("Image \(imageWidth) x \(imageHeight) with path \"\(name)\" unable to get byte pointer...")
            return
        }
        
        let bytesPerPixel = cgImage.bitsPerPixel / cgImage.bitsPerComponent
        
        var left = imageWidth
        var right = 0
        var top = imageHeight
        var bottom = Int(0)
        
        var x = 0
        while x < imageWidth {
            
            var y = 0
            while y < imageHeight {
                
                let offset = (y * cgImage.bytesPerRow) + (x * bytesPerPixel)
                let red = imageBytes[offset]
                let green = imageBytes[offset + 1]
                let blue = imageBytes[offset + 2]
                
                let deltaRed = abs(Int(edgeColorRed) - Int(red))
                let deltaGreen = abs(Int(edgeColorGreen) - Int(green))
                let deltaBlue = abs(Int(edgeColorBlue) - Int(blue))
                
                if (deltaRed <= edgeTolerance) && (deltaGreen <= edgeTolerance) && (deltaBlue <= edgeTolerance) {
                    if x < left { left = x }
                    if x > right { right = x }
                    if y < top { top = y }
                    if y > bottom { bottom = y }
                }
                
                y += 1
            }
            x += 1
        }
        
        if (right - left) < 8 {
            print("Image \(image.size.width) x \(image.size.height) with path \"\(name)\" cannot find border (left: \(left) right: \(right) top: \(top) bottom: \(bottom))")
            return
        }
        
        if (bottom - top) < 8 {
            print("Image \(image.size.width) x \(image.size.height) with path \"\(name)\" cannot find border (left: \(left) right: \(right) top: \(top) bottom: \(bottom))")
            return
        }
        
        let resultWidth = (right - left) + (resultPadding + resultPadding)
        let resultHeight = (bottom - top) + (resultPadding + resultPadding)
        
        let rect = CGRect(x: -left + resultPadding,
                          y: -top + resultPadding,
                          width: imageWidth,
                          height: imageHeight)
        
        //let result = NSImage(size: NSSize(width: imageWidth, height: imageHeight))
        let result = NSImage(size: NSSize(width: resultWidth, height: resultHeight))
        result.lockFocus()
        image.draw(in: rect)
        result.unlockFocus()
        
        let outputFilePath = outputDirectory + name
        
        FileUtils.shared.saveImageAsPNGToFilePath(result, outputFilePath)
    }
    
    /*
    
    private func fixImage(_ image: NSImage, _ name: String, _ outputDirectory: String) {
        print("image: \(image.size.width) x \(image.size.height), path = \(name)")
        
        let imageWidth = Int(image.size.width + 0.5)
        let imageHeight = Int(image.size.height + 0.5)
        
        if imageWidth < 32 || imageHeight < 32 {
            print("Image \(imageWidth) x \(imageHeight) with path \"\(name)\" is too small to fix...")
            return
        }
        
        let cgImageRect = NSRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let unsafeRect = UnsafeMutablePointer<NSRect>.allocate(capacity: 1)
        unsafeRect.initialize(to: cgImageRect)
        let cgImage = image
            .cgImage(forProposedRect: unsafeRect, context: NSGraphicsContext.current, hints: nil)
        
        print("cgImage = \(cgImage)")
        
        
        
        guard let tiffData = image.tiffRepresentation else {
            print("Image \(image.size.width) x \(image.size.height) with path \"\(name)\" cannot be made into TIFF...")
            return
        }
        
        guard let bitmapRepresentation = NSBitmapImageRep(data: tiffData) else {
            print("Image \(image.size.width) x \(image.size.height) with path \"\(name)\" TIFF data cannot be made into NSBitmapImageRep...")
            return
        }
        
        
        
        var left = Int(image.size.width)
        var right = Int(0)
        var top = Int(image.size.height)
        var bottom = Int(0)
        
        
        
        var x = 0
        while x < imageWidth {
            
            var y = 0
            while y < imageHeight {
                
                if let color = bitmapRepresentation.colorAt(x: x, y: y) {
                    let red = color.redComponent
                    let green = color.greenComponent
                    let blue = color.blueComponent
                    
                    let deltaRed = abs(edgeColorRed - red)
                    let deltaGreen = abs(edgeColorGreen - green)
                    let deltaBlue = abs(edgeColorBlue - blue)
                    
                    if (deltaRed <= edgeTolerance) && (deltaGreen <= edgeTolerance) && (deltaBlue <= edgeTolerance) {
                        if x < left { left = x }
                        if x > right { right = x }
                        if y < top { top = y }
                        if y > bottom { bottom = y }
                    }
                }
                y += 1
            }
            x += 1
        }
        
        if (right - left) < 8 {
            print("Image \(image.size.width) x \(image.size.height) with path \"\(name)\" cannot find border (left: \(left) right: \(right) top: \(top) bottom: \(bottom))")
            return
        }
        
        if (bottom - top) < 8 {
            print("Image \(image.size.width) x \(image.size.height) with path \"\(name)\" cannot find border (left: \(left) right: \(right) top: \(top) bottom: \(bottom))")
            return
        }
        
        
        print("\(name) Cropped => left: \(left) right: \(right) top: \(top) bottom: \(bottom)")
        
        //bitmapRepresentation.colorAt(x: <#T##Int#>, y: <#T##Int#>)
        
        let resultWidth = (right - left) + (resultPadding + resultPadding)
        let resultHeight = (bottom - top) + (resultPadding + resultPadding)
        
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: imageWidth,
                          height: imageHeight)
        
        
        let cropRect = CGRect(x: left - resultPadding,
                          
                              y: top - resultPadding,
                              width: resultWidth,
                              height: resultHeight)
        
        
        
        
        let result = NSImage(size: NSSize(width: imageWidth, height: imageHeight))
        
        result.lockFocus()
        
        image.draw(in: rect)
        
        NSColor(red: 1.0, green: 1.0, blue: 0.2, alpha: 0.5).drawSwatch(in: cropRect)
        
        result.unlockFocus()
        
        
        let outputFilePath = outputDirectory + name
        
        FileUtils.shared.saveImageAsPNGToFilePath(result, outputFilePath)
    }
    
    */
    
    //edgeTolerance
    
    
    
}
