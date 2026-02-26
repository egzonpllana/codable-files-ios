//
//  CodableFilesTests.swift
//  CodableFiles
//
//  Created by Egzon Pllana on 2.4.23.
//

import Foundation
import XCTest
import CodableFiles

// MARK: - String Literals

private extension String {
    static let testsDirectory = "TestsDirectory"
    static let anotherTestsDirectory = "AnotherTestsDirectory"
    static let userFileName = "User"
    static let usersArrayFileName = "UsersArray"
    static let nonExistentFileName = "NonExistentFile"
}

// MARK: - CodableFilesTests

final class CodableFilesTests: XCTestCase {

    // MARK: - Properties

    private lazy var sut: CodableFiles = CodableFiles.shared
    private let testsDirectory = CodableFilesDirectory.directoryName(.testsDirectory)
    private let anotherTestsDirectory = CodableFilesDirectory.directoryName(.anotherTestsDirectory)

    // MARK: - Test Life Cycle

    override func setUp() {
        super.setUp()
        sut.setBundle(Bundle.module)
    }

    override func tearDown() {
        try? sut.deleteDirectory()
        try? sut.deleteDirectory(directoryName: testsDirectory)
        try? sut.deleteDirectory(directoryName: anotherTestsDirectory)
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_initialization_returnsSharedInstance() {
        let instance = CodableFiles.shared
        XCTAssertNotNil(instance)
        XCTAssertTrue(instance === sut)
    }

    // MARK: - Save Tests

    func test_save_singleObject_createsFileAndReturnsURL() throws {
        let user: User = .fake()

        let savedURL = try sut.save(user, withFileName: .userFileName)

        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))
    }

    func test_save_arrayOfObjects_createsFileAndReturnsURL() throws {
        let users = [User.fake(), User.fake()]

        let savedURL = try sut.save(users, withFileName: .usersArrayFileName)

        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))
    }

    func test_save_toCustomDirectory_createsFileInCorrectLocation() throws {
        let user: User = .fake()

        let savedURL = try sut.save(user, withFileName: .userFileName, atDirectory: testsDirectory)

        XCTAssertTrue(savedURL.path.contains(String.testsDirectory))
        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))
    }

    // MARK: - Load Tests

    func test_load_singleObject_decodesCorrectly() throws {
        let user: User = try sut.load(withFileName: .userFileName, atDirectory: testsDirectory)

        XCTAssertFalse(user.firstName.isEmpty)
        XCTAssertFalse(user.lastName.isEmpty)
    }

    func test_load_arrayOfObjects_decodesCorrectly() throws {
        let users: [User] = try sut.load(withFileName: .usersArrayFileName, atDirectory: testsDirectory)

        XCTAssertFalse(users.isEmpty)
    }

    func test_load_savedObject_roundTripsCorrectly() throws {
        let original: User = .fake()
        try sut.save(original, withFileName: .userFileName)

        let loaded: User = try sut.load(withFileName: .userFileName)

        XCTAssertEqual(loaded.firstName, original.firstName)
        XCTAssertEqual(loaded.lastName, original.lastName)
    }

    // MARK: - Delete File Tests

    func test_deleteFile_removesOnlyTheTargetFile() throws {
        let user: User = .fake()
        try sut.save(user, withFileName: .userFileName)
        try sut.save(user, withFileName: .usersArrayFileName)

        try sut.deleteFile(withFileName: .userFileName)

        let isDeleted = try sut.isInDirectory(fileName: .userFileName)
        let otherExists = try sut.isInDirectory(fileName: .usersArrayFileName)
        XCTAssertFalse(isDeleted)
        XCTAssertTrue(otherExists)
    }

    func test_deleteFile_nonExistent_throwsFileNotFound() {
        XCTAssertThrowsError(try sut.deleteFile(withFileName: .nonExistentFileName)) { error in
            guard let codableError = error as? CodableFilesError else {
                XCTFail("Expected CodableFilesError, got \(error)")
                return
            }
            if case .fileNotFound(let name) = codableError {
                XCTAssertEqual(name, .nonExistentFileName)
            } else {
                XCTFail("Expected .fileNotFound, got \(codableError)")
            }
        }
    }

    // MARK: - Delete Directory Tests

    func test_deleteDirectory_removesEntireDirectory() throws {
        let user: User = .fake()
        try sut.save(user, withFileName: .userFileName)

        try sut.deleteDirectory()

        let exists = try sut.isInDirectory(fileName: .userFileName)
        XCTAssertFalse(exists)
    }

    func test_deleteDirectory_nonExistent_throwsDirectoryNotFound() {
        let nonExistent = CodableFilesDirectory.directoryName("NonExistentDir")

        XCTAssertThrowsError(try sut.deleteDirectory(directoryName: nonExistent)) { error in
            guard let codableError = error as? CodableFilesError else {
                XCTFail("Expected CodableFilesError, got \(error)")
                return
            }
            if case .directoryNotFound = codableError {
                // Expected
            } else {
                XCTFail("Expected .directoryNotFound, got \(codableError)")
            }
        }
    }

    // MARK: - Copy From Bundle Tests

    func test_copyFileFromBundle_copiesAndLoadsCorrectly() throws {
        let bundle = Bundle.module

        try sut.copyFileFromBundle(bundle: bundle, fileName: .userFileName)

        let user: User = try sut.load(withFileName: .userFileName)
        XCTAssertFalse(user.firstName.isEmpty)
    }

    func test_copyFileFromBundle_nonExistentFile_throwsBundleFileNotFound() {
        let bundle = Bundle.module

        XCTAssertThrowsError(
            try sut.copyFileFromBundle(bundle: bundle, fileName: .nonExistentFileName)
        ) { error in
            guard let codableError = error as? CodableFilesError else {
                XCTFail("Expected CodableFilesError, got \(error)")
                return
            }
            if case .bundleFileNotFound(let name) = codableError {
                XCTAssertEqual(name, .nonExistentFileName)
            } else {
                XCTFail("Expected .bundleFileNotFound, got \(codableError)")
            }
        }
    }

    // MARK: - File Path & Existence Tests

    func test_getFilePath_existingFile_returnsURL() throws {
        let user: User = .fake()
        try sut.save(user, withFileName: .userFileName)

        let path = try sut.getFilePath(forFileName: .userFileName)

        XCTAssertNotNil(path)
    }

    func test_getFilePath_nonExistentFile_returnsNil() throws {
        let path = try sut.getFilePath(forFileName: .nonExistentFileName)

        XCTAssertNil(path)
    }

    func test_isInDirectory_existingFile_returnsTrue() throws {
        let user: User = .fake()
        try sut.save(user, withFileName: .userFileName)

        let exists = try sut.isInDirectory(fileName: .userFileName)

        XCTAssertTrue(exists)
    }

    func test_isInDirectory_nonExistentFile_returnsFalse() throws {
        let exists = try sut.isInDirectory(fileName: .nonExistentFileName)

        XCTAssertFalse(exists)
    }

    // MARK: - Configuration Tests

    func test_setDefaultDirectoryName_updatesWriteDirectoryName() {
        let customName = "CustomDirectory"

        sut.setDefaultDirectoryName(directoryName: customName)

        XCTAssertEqual(sut.writeDirectoryName, customName)
        sut.setDefaultDirectoryName(directoryName: "CodableFilesDirectory")
    }
}
