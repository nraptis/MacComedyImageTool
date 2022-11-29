//
//  FileUtils.swift
//  JokeSeedTool
//
//  Created by Nick Raptis on 11/24/22.
//

import Foundation
import AppKit

final class FileUtils {
    
    static let shared = FileUtils()
    
    private init() { /* Hur Hur Hur I'm A Singleton Hur Hur Hur */ }
    
    
    // Note: Every time you save and load an image, it will double in size.
    // This is a faulty side effect of "retina display?"
    func imageToPNG(_ image: NSImage) -> Data? {
        guard image.size.width > 0.0 && image.size.height > 0 else {
            print("Image \(image.size.width) x \(image.size.height) invalid dimension, canot save...")
            return nil
        }
        if let tiffData = image.tiffRepresentation {
            if let bitmapRepresentation = NSBitmapImageRep(data: tiffData) {
                return bitmapRepresentation.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey : Any]())
            } else {
                print("Image \(image.size.width) x \(image.size.height) cannot get BITMAP representation, TIFF is \(tiffData.count) bytes...")
            }
        } else {
            print("Image \(image.size.width) x \(image.size.height) cannot get TIFF representation...")
        }
        return nil
    }
    
    lazy var assetsDirectory: String = {
        "\(FileManager.default.currentDirectoryPath)/assets/"
    }()
    
    lazy var documentsDirectory: String = {
        "\(FileManager.default.currentDirectoryPath)/documents/"
    }()
    
    lazy var exportsDirectory: String = {
        "\(FileManager.default.currentDirectoryPath)/exports/"
    }()
    
    func assetsPath(_ fileName: String) -> String {
        assetsDirectory + fileName
    }
    
    func documentsPath(_ fileName: String) -> String {
        documentsDirectory + fileName
    }
    
    func exportsPath(_ fileName: String) -> String {
        exportsDirectory + fileName
    }
    
    func dataFromFilePath(_ path: String) -> Data? {
        var result: Data?
        do {
            let url = URL(fileURLWithPath: path)
            result = try Data(contentsOf: url)
        } catch let error {
            print("Data From Path: {\(path)}")
            print("ERROR!")
            print(error.localizedDescription)
        }
        
        return result
    }
    
    func imageFromFilePath(_ path: String) -> NSImage? {
        if let data = dataFromFilePath(path) {
            if let image = NSImage(data: data) {
                if image.size.width > 0 && image.size.height > 0 {
                    return image
                }
            }
        }
        return nil
    }
    
    func saveDataToFilePath(_ data: Data?, _ path: String) {
        
        guard let data = data else {
            print("Unable to save to {\(path)}, data is missing")
            return
        }
        
        if data.count <= 0 {
            print("Warning, saving blank file to {\(path)}")
        }
        
        do {
            let url = URL(fileURLWithPath: path)
            try data.write(to: url)
        } catch {
            do {
                let url = URL(fileURLWithPath: path).deletingLastPathComponent()
                print("Could not save file, trying to create directory: \(url.absoluteString)")
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
            } catch let directoryError {
                print("Saving Data To Path, Create Directory Error: {\(path)}")
                print("ERROR!")
                print(directoryError.localizedDescription)
            }
            do {
                let url = URL(fileURLWithPath: path)
                try data.write(to: url)
            } catch let secondaryFileError {
                print("Secondary Saving Data To Path Error: {\(path)}")
                print("ERROR!")
                print(secondaryFileError.localizedDescription)
            }
        }
    }
    
    func saveImageAsPNGToFilePath(_ image: NSImage?, _ path: String) {
        guard let image = image else {
            print("Unable to save to {\(path)}, image is missing...")
            return
        }
        if image.size.width <= 0 || image.size.height <= 0 {
            print("Warning, saving blank image to {\(path)}")
        }
        
        guard let data = imageToPNG(image) else {
            print("Unable to save to {\(path)}, image cannot be concerted to PNG...")
            return
        }
        
        saveDataToFilePath(data, path)
    }
        
    func dataFromAssetsFile(_ fileName: String) -> Data? {
        let path = assetsPath(fileName)
        return dataFromFilePath(path)
    }
    
    func dataFromDocumentsFile(_ fileName: String) -> Data? {
        let path = documentsPath(fileName)
        return dataFromFilePath(path)
    }
    
    func dataFromExportsFile(_ fileName: String) -> Data? {
        let path = exportsPath(fileName)
        return dataFromFilePath(path)
    }
    
    func imageFromAssetsFile(_ fileName: String) -> NSImage? {
        let path = assetsPath(fileName)
        return imageFromFilePath(path)
    }
    
    func imageFromDocumentsFile(_ fileName: String) -> NSImage? {
        let path = documentsPath(fileName)
        return imageFromFilePath(path)
    }
    
    func imageFromExportsFile(_ fileName: String) -> NSImage? {
        let path = exportsPath(fileName)
        return imageFromFilePath(path)
    }
    
    func saveDataToExportsFile(_ data: Data?, _ fileName: String) {
        saveDataToFilePath(data, exportsPath(fileName))
    }
    
    func saveImageAsPNGToExportsFile(_ image: NSImage?, _ fileName: String) {
        saveImageAsPNGToFilePath(image, exportsPath(fileName))
    }
    
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
}
