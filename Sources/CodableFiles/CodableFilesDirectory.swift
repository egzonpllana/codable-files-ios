//
//  CodableFilesDirectory.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 2.4.23.
//

import Foundation

// MARK: - CodableFilesDirectory

/// Represents a target directory for file operations within the documents directory.
public enum CodableFilesDirectory {

    /// The SDK's default directory, configurable via `setDefaultDirectoryName`.
    case defaultDirectory

    /// A custom directory identified by name.
    case directoryName(_ name: String)
}

// MARK: - Internal Helpers

extension CodableFilesDirectory {

    /// Returns the concrete directory name string.
    ///
    /// - Parameter defaultName: The name to use when the case is `.defaultDirectory`.
    /// - Returns: The resolved directory name.
    func resolvedName(defaultName: String) -> String {
        switch self {
        case .defaultDirectory:
            return defaultName
        case .directoryName(let name):
            return name
        }
    }
}
