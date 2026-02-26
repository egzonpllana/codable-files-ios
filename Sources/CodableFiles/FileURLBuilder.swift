//
//  FileURLBuilder.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

// MARK: - FileURLBuilder

/// Centralizes file and directory URL construction for the documents directory.
///
/// Eliminates repeated path-building logic across CodableFiles methods
/// and provides a single place for directory existence checks and creation.
struct FileURLBuilder {

    // MARK: - Properties

    private let fileManager: FileManager

    // MARK: - Initialization

    /// Creates a builder backed by the given file manager.
    /// - Parameter fileManager: The file manager used for path resolution and directory operations.
    init(fileManager: FileManager) {
        self.fileManager = fileManager
    }

    // MARK: - Directory Operations

    /// Resolves the full URL for a directory inside the documents directory.
    ///
    /// - Parameter directory: The logical directory to resolve.
    /// - Parameter writeDirectory: The default directory name when `.defaultDirectory` is used.
    /// - Returns: The resolved directory URL.
    /// - Throws: `CodableFilesError.documentsDirectoryUnavailable` if the documents directory cannot be resolved.
    func directoryURL(
        for directory: CodableFilesDirectory,
        defaultName writeDirectory: String
    ) throws -> URL {
        let documentsURL = try resolveDocumentsDirectory()
        let directoryName = directory.resolvedName(defaultName: writeDirectory)
        return documentsURL.appendingPathComponent(directoryName)
    }

    /// Creates the directory at the given URL if it does not already exist.
    ///
    /// - Parameter url: The directory URL to ensure exists.
    /// - Throws: FileManager errors if directory creation fails.
    func ensureDirectoryExists(_ url: URL) throws {
        guard !fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    }

    // MARK: - File Operations

    /// Builds the full file URL by appending the file name and `.json` extension to a directory URL.
    ///
    /// - Parameters:
    ///   - fileName: The file name (without extension).
    ///   - directory: The logical directory containing the file.
    ///   - writeDirectory: The default directory name when `.defaultDirectory` is used.
    /// - Returns: The full file URL with `.json` extension.
    /// - Throws: `CodableFilesError.documentsDirectoryUnavailable` if the documents directory cannot be resolved.
    func fileURL(
        fileName: String,
        directory: CodableFilesDirectory,
        defaultName writeDirectory: String
    ) throws -> URL {
        let dirURL = try directoryURL(for: directory, defaultName: writeDirectory)
        return dirURL
            .appendingPathComponent(fileName)
            .appendingPathExtension("json")
    }

    // MARK: - Private Helpers

    private func resolveDocumentsDirectory() throws -> URL {
        do {
            return try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
        } catch {
            throw CodableFilesError.documentsDirectoryUnavailable(underlyingError: error)
        }
    }
}
