# Web Link Preview
[![CI Status](http://img.shields.io/travis/philip-bui/web-link-preview.svg?style=flat)](https://travis-ci.org/philip-bui/web-link-preview)
[![Version](https://img.shields.io/cocoapods/v/WebLinkPreview.svg?style=flat)](http://cocoapods.org/pods/WebLinkPreview)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/WebLinkPreview.svg?style=flat)](http://cocoapods.org/pods/WebLinkPreview)
[![License](https://img.shields.io/cocoapods/l/WebLinkPreview.svg?style=flat)](https://github.com/philip-bui/web-link-preview/blob/master/LICENSE)

This library aims to help developers to create website link previews, given a web link. There are a few web conventions to use; a site's theme color or icon, or [OpenGraph](http://ogp.me/) describing the link.

- Performant - HEAD requests to not download file binaries, regex for parsing.
- Cached - Inject own cache or uses default NSCache.
- Extensible - Additionally parse different metadata from HEAD tag.
- Preview Methods - Additional methods to parse metadata into relevant information.
  - URL parsing - Create URLs from absolute or relative hyperlink references.
  - Hex colors - UIColor from Hex string (6,7,8,9 length)
  - Text color - UIColor for [black or white](https://stackoverflow.com/questions/3942878/how-to-decide-font-color-in-white-or-black-depending-on-background-color) text above a site's theme color.

## Requirements

- iOS 8.0+ / macOS 10.9+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 10.3+
- Swift 4.2+

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate WebLinkPreview into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'WebLinkPreview'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate WebLinkPreview into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "philip-bui/web-link-preview"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but WebLinkPreview does support its use on supported platforms.

Once you have your Swift package set up, adding WebLinkPreview as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/philip-bui/web-link-preview.git", from: "1.0.0"))
]
```

## Usage

```swift
import WebLinkPreview

// ViewController.swift - Load url.
_ = WebLinkMetadata(url: "https://www.youtube.com") { webLinkMetadata, error in
	guard let webLinkMetadata = webLinkMetadata else {
		return // Handle error.
	}
	webLinkMetadata.content // enum [.html, .image(URL), .video(URL), .other(URL)]
	webLinkMetadata.iconURL // URL for largest sized <link rel="icon" ...>
	webLinkMetadata.themeUIColor // UIColor for <meta name="theme-color" ...>
	webLinkMetadata["image"] // String for <meta property="og:image" ...>
	webLinkMetadata[.image] // OpenGraph enum for above
	// Any UI operations should be performed on main thread.
}
```
 
## Improvements

- Support more String Encodings from Content-Type charset. Supports UTF-8 and Latin1.
- Use Cache-Control and Expires headers for NSCache expiration.
- HTTP Stub testing.
- Youtube Link Type. Youtube provides embedded video links and not video files, which [other libraries](https://github.com/youtube/youtube-ios-player-helper) solve.
- Duplicate OpenGraph tags. Common for sites to have multiple images, should arrays be used instead.

## License

WebLinkPreview is available under the MIT license. [See LICENSE](https://github.com/philip-bui/web-link-preview/blob/master/LICENSE) for details.
