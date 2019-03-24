# Web Link Preview
[![CI Status](http://img.shields.io/travis/philip-bui/web-link-preview.svg?style=flat)](https://travis-ci.org/philip-bui/web-link-preview)
[![Version](https://img.shields.io/cocoapods/v/WebLinkPreview.svg?style=flat)](http://cocoapods.org/pods/WebLinkPreview)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/WebLinkPreview.svg?style=flat)](http://cocoapods.org/pods/WebLinkPreview)
[![License](https://img.shields.io/cocoapods/l/WebLinkPreview.svg?style=flat)](https://github.com/philip-bui/web-link-preview/blob/master/LICENSE)

This library helps to extract important metadata from web links, performing `HEAD` HTTP checks, text subsets and regex to efficiently find relevant html tags.

- `HEAD` HTTP request to extract `Content-Type`, preventing loading files.
  - `GET` HTTP request for `text/html`, parsing OpenGraph, ThemeColor and Website icon URL.
  - Other `Content-Type` are matched into Image URL, Video URL or File URL.
- Injectable cache or NSCache.

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
	webLinkMetadata.iconURL // URL for largest sized <link rel="icon" ...>. Youtube icon.
	webLinkMetadata.themeUIColor // UIColor for <meta name="theme-color" ...>. Red for Youtube.
	webLinkMetadata["image"] // String for <meta property="image" ...>. Youtube title logo.
	webLinkMetadata[.image] // OpenGraph enum access with same value above.
	// Any UI operations should be performed on main thread.
}
```
 
## Improvements

- Use String Encoding from Content-Type charset. Currently uses UTF-8 which is also compatible with ASCII.
- Use Cache-Control and Expires headers for NSCache expiration.
- HTTP Stub testing.

## License

WebLinkPreview is available under the MIT license. [See LICENSE](https://github.com/philip-bui/web-link-preview/blob/master/LICENSE) for details.
