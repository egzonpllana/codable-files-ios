//
//  CodableFilesError.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 2.4.23.
//

import Foundation

/// Errors thrown by CodableFiles operations.
///
/// Each case provides context about what went wrong, including
/// the file or directory name involved in the failed operation.
public enum CodableFilesError: Error, CustomDebugStringConvertible, LocalizedError {

    /// The specified file was not found in the given bundle.
    case bundleFileNotFound(fileName: String)

    /// The documents directory could not be resolved by FileManager.
    case documentsDirectoryUnavailable(underlyingError: Error)

    /// The specified directory does not exist at the expected path.
    case directoryNotFound(directoryName: String)

    /// The specified file does not exist in the target directory.
    case fileNotFound(fileName: String)

    // MARK: - CustomDebugStringConvertible

    public var debugDescription: String {
        switch self {
        case .bundleFileNotFound(let fileName):
            return "File '\(fileName)' not found in the provided Bundle."
        case .documentsDirectoryUnavailable(let underlyingError):
            return "Failed to resolve the documents directory URL. Underlying error: \(underlyingError.localizedDescription)"
        case .directoryNotFound(let directoryName):
            return "Directory '\(directoryName)' not found."
        case .fileNotFound(let fileName):
            return "File '\(fileName)' not found."
        }
    }

    // MARK: - LocalizedError

    public var errorDescription: String? {
        debugDescription
    }
}
