//
//  CodableFilesProtocol.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 26.2.26.
//

import Foundation

/// A protocol defining the public API for CodableFiles operations.
///
/// Conform to this protocol to create mock implementations for testing,
/// or use the default `CodableFiles.shared` instance for production code.
///
/// All file operations target the documents directory and persist data as JSON.
public protocol CodableFilesProviding {

    /// The name of the current default directory used for file operations.
    var writeDirectoryName: String { get }

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
    /// - Throws: `CodableFilesError` if the documents directory is unavailable.
    @discardableResult
    func save<T: Encodable>(
        _ object: T,
        encoder: JSONEncoder,
        withFileName fileName: String,
        atDirectory directory: CodableFilesDirectory
    ) throws -> URL

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
    /// - Throws: `CodableFilesError.fileNotFound` if the file cannot be located.
    func load<T: Decodable>(
        withFileName fileName: String,
        decoder: JSONDecoder,
        atDirectory directory: CodableFilesDirectory
    ) throws -> T

    /// Deletes a specific JSON file from the given directory.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file to delete (without `.json` extension).
    ///   - directory: The directory containing the file. Defaults to `.defaultDirectory`.
    /// - Throws: `CodableFilesError.fileNotFound` if the file does not exist.
    func deleteFile(
        withFileName fileName: String,
        atDirectory directory: CodableFilesDirectory
    ) throws

    /// Deletes an entire directory and all its contents.
    ///
    /// - Parameter directory: The directory to delete. Defaults to `.defaultDirectory`.
    /// - Throws: `CodableFilesError.directoryNotFound` if the directory does not exist.
    func deleteDirectory(directoryName directory: CodableFilesDirectory) throws

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
        toDirectory directory: CodableFilesDirectory
    ) throws -> URL

    /// Returns the URL of a file if it exists in the specified directory.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file (without `.json` extension).
    ///   - directory: The directory to search. Defaults to `.defaultDirectory`.
    /// - Returns: The file URL, or `nil` if the file does not exist.
    /// - Throws: `CodableFilesError.documentsDirectoryUnavailable` if the base path cannot be resolved.
    func getFilePath(
        forFileName fileName: String,
        fromDirectory directory: CodableFilesDirectory
    ) throws -> URL?

    /// Checks whether a file exists in the specified directory.
    ///
    /// - Parameters:
    ///   - fileName: The name of the file (without `.json` extension).
    ///   - directory: The directory to check. Defaults to `.defaultDirectory`.
    /// - Returns: `true` if the file exists, `false` otherwise.
    /// - Throws: `CodableFilesError.documentsDirectoryUnavailable` if the base path cannot be resolved.
    func isInDirectory(
        fileName: String,
        directory: CodableFilesDirectory
    ) throws -> Bool

}
