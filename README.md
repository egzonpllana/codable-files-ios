<p align="center">
    <img src="logo.png" width="300" max-width="50%" alt="CodableFiles" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-5.5+-orange.svg" />
    <a href="https://cocoapods.org/pods/CodableFiles">
        <img src="https://img.shields.io/cocoapods/v/CodableFiles.svg" alt="CocoaPods" />
    </a>
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
</p>

Welcome to **CodableFiles**, a simple library that provides an easier way to save, load or delete Codable objects in the Documents directory. It's primarily aimed to save Encodable objects as JSON and load them back as Decodable objects. It's essentially a thin wrapper around the `FileManager` APIs that `Foundation` provides.

## Why CodableFiles?

Every app has a filing cabinet — a quiet corner of the filesystem where structured data needs to live between launches. **CodableFiles** is the clerk that manages that cabinet. You hand it a `Codable` object and a name; it encodes, files, and retrieves it without you ever thinking about paths, extensions, or directory creation. The clerk never loses a document, never misfiled one, and never leaves the cabinet door open. You focus on the data; CodableFiles handles the paperwork.

## Features

- [X] Protocol-based API (`CodableFilesProviding`) for easy mocking and testability.
- [X] Unified, simple `do, try, catch` error handling with contextual error messages.
- [X] Automatic directory creation and atomic file writes.
- [X] Custom encoder/decoder support for flexible serialization.
- [X] Unit test coverage with both happy-path and error-scenario tests.

## Examples

Codable object and constants for example purposes.
```swift
struct User: Codable {
    let name: String
    let lastName: String
}

let user = User(name: "First name", lastName: "Last name")
let users = [user]
let fileName = "Users"
```

CodableFiles shared reference.

```swift
let codableFiles = CodableFiles.shared
```

Save object in default directory.
```swift
try codableFiles.save(user, withFileName: fileName)
```

Save object with custom encoder.
```swift
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
try codableFiles.save(user, encoder: encoder, withFileName: fileName)
```

Load object from default directory.
```swift
let user: User = try codableFiles.load(withFileName: fileName)
```

Load array of objects from default directory.
```swift
let users: [User] = try codableFiles.load(withFileName: fileName)
```

Delete a file.
```swift
try codableFiles.deleteFile(withFileName: fileName)
```

Delete default directory.
```swift
try codableFiles.deleteDirectory()
```

Delete a custom directory.
```swift
try codableFiles.deleteDirectory(directoryName: .directoryName("MyFolder"))
```

Copy a file from Bundle to documents directory.
```swift
let bundle = Bundle(for: type(of: self))
let pathURL = try codableFiles.copyFileFromBundle(bundle: bundle, fileName: fileName)
```

Save and load to a custom directory.
```swift
let customDir = CodableFilesDirectory.directoryName("UserData")

try codableFiles.save(user, withFileName: fileName, atDirectory: customDir)
let loaded: User = try codableFiles.load(withFileName: fileName, atDirectory: customDir)
```

Recommended way to handle errors.
```swift
do {
    let user: User = try codableFiles.load(withFileName: fileName)
} catch {
    print("CodableFiles - Error: \(error.localizedDescription)")
}
```

### App Bundle
AppBundle is read-only, so you cannot write to it programmatically. That's the reason we use the Documents Directory for read & write operations. Read more:
https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html

## Installation

### Swift Package Manager through Manifest File

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding CodableFiles as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/egzonpllana/CodableFiles.git", .upToNextMajor(from: "2.0.0"))
]
```

### Swift Package Manager through Xcode
To add CodableFiles as a dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter the repository URL:
```ogdl
https://github.com/egzonpllana/CodableFiles.git
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate CodableFiles into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'CodableFiles'
```

## Backstory

So, why was this made? While I was working on a project to provide mocked URL sessions with dynamic JSON data, I found that we can have these data saved in a file in Document Directory or loaded from Bundle so later we can update, read or delete based on our app needs. The objects that have to be saved or loaded must conform to the Codable protocol. So, I made **Codable Files** that make it possible to work with JSON data quicker, in an expressive way.

## Questions or feedback?

Feel free to [open an issue](https://github.com/egzonpllana/CodableFiles/issues/new), or find me [@egzonpllana on LinkedIn](https://www.linkedin.com/in/egzon-pllana/).
