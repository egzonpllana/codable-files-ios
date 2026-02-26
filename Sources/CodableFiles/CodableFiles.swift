//
//  CodableFiles.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 2.4.23.
//

import Foundation

// MARK: - CodableFiles

/// A lightweight facade for persisting and loading `Codable` objects as JSON files.
///
/// Use `CodableFiles.shared` to access the singleton instance.
/// All operations target subdirectories within the app's documents directory.
///
/// ```swift
/// let url = try CodableFiles.shared.save(user, withFileName: "profile")
/// let loaded: User = try CodableFiles.shared.load(withFileName: "profile")
/// ```
public final class CodableFiles: CodableFilesProviding {

    // MARK: - Properties

    /// Shared singleton instance.
    public static let shared = CodableFiles()

    private let fileManager: FileManager
    private var writeDirectory: String
    private lazy var bundle: Bundle = Bundle(for: type(of: self))
    private let urlBuilder: FileURLBuilder

    // MARK: - Initialization

    private init() {
        let manager = FileManager.default
        self.fileManager = manager
        self.writeDirectory = "CodableFilesDirectory"
        self.urlBuilder = FileURLBuilder(fileManager: manager)
    }
}

// MARK: - Public API

public extension CodableFiles {

    /// A string representation of the current default directory name.
    var writeDirectoryName: String {
        writeDirectory
    }

    /// Saves an encodable object as a JSON file.
    ///
    /// Creates the target directory if it does not already exist.
    /// Uses atomic writes to prevent partial file corruption.
    ///
    /// - Parameters:
    ///   - object: The encodable object to persist.
    ///   - encoder: The JSON encoder to use. Defaults to a standard `JSONEncoder`.
    ///   - fileName: The name of the file (without `.json` extension).
    ///   - directory: The target directory. Defaults to `.defaultDirectory`.
    /// - Returns: The URL of the saved file.
    /// - Throws: `CodableFilesError.documentsDirectoryUnavailable` if the documents directory cannot be resolved.
    @discardableResult
    func save<T: Encodable>(
        _ object: T,
        encoder: JSONEncoder = .init(),
        withFileName fileName: String,
        atDirectory directory: CodableFilesDirectory = .defaultDirectory
    ) throws -> URL {
        let directoryURL = try urlBuilder.directoryURL(for: directory, defaultName: writeDirectory)
        try urlBuilder.ensureDirectoryExists(directoryURL)

        let fileURL = try urlBuilder.fileURL(fileName: fileName, directory: directory, defaultName: writeDirectory)
        let data = try encoder.encode(object)
        try data.write(to: fileURL, options: [.atomicWrite])
        return fileURL
    }

    /// Loads a decodable object from a JSON file.
    ///
    /// If the file does not exist in the target directory, attempts to copy it
    /// from the configured bundle before loading.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file (without `.json` extension).
    ///   - decoder: The JSON decoder to use. Defaults to a standard `JSONDecoder`.
    ///   - directory: The source directory. Defaults to `.defaultDirectory`.
    /// - Returns: The decoded object of type `T`.
    /// - Throws: `CodableFilesError.fileNotFound` if the file cannot be located in the directory or bundle.
    func load<T: Decodable>(
        withFileName fileName: String,
        decoder: JSONDecoder = .init(),
        atDirectory directory: CodableFilesDirectory = .defaultDirectory
    ) throws -> T {
        let fileURL = try copyFromBundleIfNeeded(fileName: fileName, toDirectory: directory)
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(T.self, from: data)
    }

    /// Deletes a specific JSON file from the given directory.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file to delete (without `.json` extension).
    ///   - directory: The directory containing the file. Defaults to `.defaultDirectory`.
    /// - Throws: `CodableFilesError.fileNotFound` if the file does not exist.
    func deleteFile(
        withFileName fileName: String,
        atDirectory directory: CodableFilesDirectory = .defaultDirectory
    ) throws {
        let fileURL = try urlBuilder.fileURL(
            fileName: fileName,
            directory: directory,
            defaultName: writeDirectory
        )

        guard fileManager.fileExists(atPath: fileURL.path) else {
            throw CodableFilesError.fileNotFound(fileName: fileName)
        }

        try fileManager.removeItem(at: fileURL)
    }

    /// Deletes an entire directory and all its contents.
    ///
    /// - Parameter directory: The directory to delete. Defaults to `.defaultDirectory`.
    /// - Throws: `CodableFilesError.directoryNotFound` if the directory does not exist.
    func deleteDirectory(directoryName directory: CodableFilesDirectory = .defaultDirectory) throws {
        let directoryURL = try urlBuilder.directoryURL(for: directory, defaultName: writeDirectory)
        let directoryName = directory.resolvedName(defaultName: writeDirectory)

        guard fileManager.fileExists(atPath: directoryURL.path) else {
            throw CodableFilesError.directoryNotFound(directoryName: directoryName)
        }

        try fileManager.removeItem(at: directoryURL)
    }

    /// Copies a JSON file from a bundle into the specified directory.
    ///
    /// Overwrites the file if it already exists in the target directory.
    /// Creates the target directory if it does not already exist.
    ///
    /// - Parameters:
    ///   - bundle: The bundle containing the source file.
    ///   - fileName: The name of the file (without `.json` extension).
    ///   - directory: The target directory. Defaults to `.defaultDirectory`.
    /// - Returns: The URL of the copied file.
    /// - Throws: `CodableFilesError.bundleFileNotFound` if the file is not in the bundle.
    @discardableResult
    func copyFileFromBundle(
        bundle: Bundle,
        fileName: String,
        toDirectory directory: CodableFilesDirectory = .defaultDirectory
    ) throws -> URL {
        guard let bundlePath = bundle.url(forResource: fileName, withExtension: "json") else {
            throw CodableFilesError.bundleFileNotFound(fileName: fileName)
        }

        let directoryURL = try urlBuilder.directoryURL(for: directory, defaultName: writeDirectory)
        try urlBuilder.ensureDirectoryExists(directoryURL)

        let fileURL = try urlBuilder.fileURL(fileName: fileName, directory: directory, defaultName: writeDirectory)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }

        try fileManager.copyItem(at: bundlePath, to: fileURL)
        return fileURL
    }

    /// Returns the URL of a file if it exists in the specified directory.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file (without `.json` extension).
    ///   - directory: The directory to search. Defaults to `.defaultDirectory`.
    /// - Returns: The file URL, or `nil` if the file does not exist.
    /// - Throws: `CodableFilesError.documentsDirectoryUnavailable` if the base path cannot be resolved.
    func getFilePath(
        forFileName fileName: String,
        fromDirectory directory: CodableFilesDirectory = .defaultDirectory
    ) throws -> URL? {
        let fileURL = try urlBuilder.fileURL(
            fileName: fileName,
            directory: directory,
            defaultName: writeDirectory
        )

        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }

        return fileURL
    }

    /// Checks whether a file exists in the specified directory.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file (without `.json` extension).
    ///   - directory: The directory to check. Defaults to `.defaultDirectory`.
    /// - Returns: `true` if the file exists, `false` otherwise.
    /// - Throws: `CodableFilesError.documentsDirectoryUnavailable` if the base path cannot be resolved.
    func isInDirectory(
        fileName: String,
        directory: CodableFilesDirectory = .defaultDirectory
    ) throws -> Bool {
        let fileURL = try urlBuilder.fileURL(
            fileName: fileName,
            directory: directory,
            defaultName: writeDirectory
        )
        return fileManager.fileExists(atPath: fileURL.path)
    }

    /// Overrides the default directory name used for file operations.
    ///
    /// - Parameter directoryName: The new default directory name.
    func setDefaultDirectoryName(directoryName: String) {
        writeDirectory = directoryName
    }

    /// Sets the bundle used for bundle-to-directory copy operations.
    ///
    /// Primarily used for testing to inject a test bundle.
    ///
    /// - Parameter bundle: The bundle to use for file lookups.
    func setBundle(_ bundle: Bundle) {
        self.bundle = bundle
    }
}

// MARK: - Private Helpers

private extension CodableFiles {

    /// Copies a file from the app bundle if it does not already exist in the target directory.
    ///
    /// - Parameters:
    ///   - fileName: The file name (without extension).
    ///   - directory: The target directory.
    /// - Returns: The URL of the file (existing or newly copied).
    /// - Throws: `CodableFilesError.bundleFileNotFound` if the file exists in neither the directory nor the bundle.
    func copyFromBundleIfNeeded(
        fileName: String,
        toDirectory directory: CodableFilesDirectory
    ) throws -> URL {
        if let existingPath = try getFilePath(forFileName: fileName, fromDirectory: directory) {
            return existingPath
        }
        return try copyFileFromBundle(bundle: bundle, fileName: fileName, toDirectory: directory)
    }
}
