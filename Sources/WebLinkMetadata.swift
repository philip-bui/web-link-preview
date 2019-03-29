//
//  WebLinkMetadata.swift
//  WebLinkPreview
//
//  Created by Philip on 23/3/19.
//  Copyright © 2019 Next Generation. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#else
#endif
public class WebLinkMetadata {
    public static var defaultCache = NSCache<NSString, WebLinkMetadata>()

    public let cache: NSCache<NSString, WebLinkMetadata>?
    public let url: URL
    public var contentType: String?
    public var content: ContentType? {
        guard let contentType = contentType else {
            return nil
        }
        if contentType.hasPrefix("text/html") {
            return .html
        } else if contentType.hasPrefix("image") {
            return .image(self.url)
        } else if contentType.hasPrefix("video") {
            return .video(self.url)
        } else {
            return .other(self.url)
        }
    }
    public enum ContentType {
        case html
        case image(URL)
        case video(URL)
        case other(URL)
    }

    public var themeColor: String?
    #if canImport(UIKit)
    public var themeUIColor: UIColor? {
        guard let themeColor = themeColor else {
            return nil
        }
        return UIColorFrom(hex: themeColor)
    }
    public func UIColorFrom(hex: String) -> UIColor? {
        var hex = hex
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        if hex.count != 6 {
            return nil
        }
        var rgb: UInt32 = 0
        Scanner(string: hex).scanHexInt32(&rgb)
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255,
            blue: CGFloat(rgb & 0x0000FF) / 255,
            alpha: 1)
    }
    #endif

    public var openGraph: [String: String]?

    public var iconLink: String?
    public var iconURL: URL? {
        guard let iconLink = iconLink else {
            return nil
        }
        return URLFrom(link: iconLink, url: url)
    }
    public func URLFrom(link: String, url: URL) -> URL? {
        if let baseURL = URL(string: "/", relativeTo: url), let iconURL = URL(string: link, relativeTo: baseURL)  {
            return iconURL
        }
        if let url = URL(string: link) {
            return url
        }
        return nil
    }

    public func fetch(url: URL, completion: @escaping (WebLinkMetadata?, WebLinkMetadataError?) -> Void) {
        if let webLinkMetadata = cache?.object(forKey: url.absoluteString as NSString) {
            completion(webLinkMetadata, nil)
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "HEAD"
        URLSession(configuration: URLSessionConfiguration.default).dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            self.handleHeadResponse(data: data, response: response, error: error) { metadata, error in
                if let metadata = metadata {
                    self.cache?.setObject(metadata, forKey: url.absoluteString as NSString)
                }
                completion(metadata, error)
            }
        }).resume()
    }

    private func handleHeadResponse(data: Data?, response: URLResponse?, error: Error?, callback: @escaping (WebLinkMetadata?, WebLinkMetadataError?) -> Void){
        switch (data, response, error) {
        case (_, _, let error?):
            callback(nil, WebLinkMetadataError.requestError(error))
            break
        case (_, let response as HTTPURLResponse, _):
            if !(200..<300).contains(response.statusCode) {
                callback(nil, WebLinkMetadataError.unsuccessfulStatusCode(response.statusCode, error))
            } else {
                guard let contentType = response.allHeaderFields["Content-Type"] as? String else {
                    callback(nil, WebLinkMetadataError.noContentType)
                    return
                }
                self.contentType = contentType
                if contentType.hasPrefix("text/html") {
                    URLSession(configuration: URLSessionConfiguration.default).dataTask(with: url, completionHandler: { (data, response, error) in
                        self.handleGetResponse(data: data, response: response, error: error, callback: callback)
                    }).resume()
                    return
                }
                callback(self, nil)
            }
            break
        default:
            break
        }
    }
    
    private func handleGetResponse(data: Data?, response: URLResponse?, error: Error?, callback: @escaping (WebLinkMetadata?, WebLinkMetadataError?) -> Void) {
        switch (data, response, error) {
        case (_, _, let error?):
            callback(nil, WebLinkMetadataError.requestError(error))
            break
        case (let data?, let response as HTTPURLResponse, _):
            if !(200..<300).contains(response.statusCode) {
                callback(nil, WebLinkMetadataError.unsuccessfulStatusCode(response.statusCode, error))
            } else {
                guard let htmlString = String(data: data, encoding: contentType?.hasSuffix("ISO-8859-1") ?? false ? .isoLatin1 : .utf8) else {
                    callback(nil, WebLinkMetadataError.encodingError)
                    return
                }
                guard let startIndex = htmlString.range(of: "<head>")?.upperBound, let endIndex = htmlString.range(of: "</head>")?.lowerBound else {
                    callback(nil, WebLinkMetadataError.noHeadTags)
                    return
                }
                parse(htmlString: String(htmlString[startIndex..<endIndex]))
                callback(self, nil)
            }
            break
        default:
            break
        }
    }
    
    public func parse(htmlString: String) {
        openGraph = parse(metadataFrom: htmlString)
        iconLink = parse(iconFrom: htmlString)
    }
    
    public func parse(metadataFrom htmlString: String) -> [String: String] {
        // Regex to extract meta tag regex.
        let metatagRegex  = try! NSRegularExpression(
            pattern: "<meta(?:\".*?\"|\'.*?\'|[^\'\"])*?>",
            options: [.dotMatchesLineSeparators]
        )
        let metaTagMatches = metatagRegex
            .matches(in: htmlString,
                     options: [],
                     range: NSMakeRange(0, htmlString.count))
        if metaTagMatches.isEmpty {
            return [:]
        }
        // Regex to extract og property, content and theme colors.
        let propertyRegex = try! NSRegularExpression(
            pattern: "\\sproperty=(?:\"|\')og:([a-zA_Z:]+?)(?:\"|\')",
            options: []
        )
        let contentRegex = try! NSRegularExpression(
            pattern: "\\scontent=\"(.*?)\"",
            options: []
        )
        let contentRegexSingleQuotation = try! NSRegularExpression(
            pattern: "\\scontent='(.*?)'",
            options: []
        )
        let themeColorRegex = try! NSRegularExpression(
            pattern: "\\sname=\"theme-color\"",
            options: []
        )
        let themeColorRegexSingleQuotation = try! NSRegularExpression(
            pattern: "\\sname=\'theme-color\'",
            options: []
        )
        let nsString = htmlString as NSString
        // Create [ogProperty: content] dictionary.
        return metaTagMatches.reduce([String: String]()) { (attributes, result) -> [String: String] in
            var attributes = attributes
            let property = { () -> (name: String, content: String)? in
                let metaTag = nsString.substring(with: result.range(at: 0))
                let range = NSMakeRange(0, metaTag.count)
                guard let contentMatch = contentRegex
                    .matches(in: metaTag,
                             options: [],
                             range: range).first
                    ?? contentRegexSingleQuotation
                                .matches(in: metaTag,
                                         options: [],
                                         range: range).first else {
                    return nil
                }
                let nsMetaTag = metaTag as NSString
                let content = nsMetaTag.substring(with: contentMatch.range(at: 1))
                // Gets property="og:*" || property='og:*' value.
                if let propertyMatch = propertyRegex
                    .matches(in: metaTag,
                             options: [],
                             range: range).first {
                    let property = nsMetaTag.substring(with: propertyMatch.range(at: 1))
                    return (name: property, content: content)
                } // Check if name="theme-color" || name='theme-color' exists.
                else if themeColorRegex
                    .matches(in: metaTag,
                             options: [],
                             range: range).first
                    ?? themeColorRegexSingleQuotation
                        .matches(in: metaTag,
                                 options: [], range: range).first != nil {
                    themeColor = content
                    return nil
                }
                return nil
            }()
            if let property = property {
                attributes[property.name] = property.content
            }
            return attributes
        }
    }

    public func parse(iconFrom htmlString: String) -> String? {
        let linkRegex = try! NSRegularExpression(
            pattern: "<link(?:\".*?\"|\'.*?\'|[^\'\"])*?>",
            options: [.dotMatchesLineSeparators]
        )
        let linkMatches = linkRegex
            .matches(in: htmlString,
                     options: [],
                     range: NSMakeRange(0, htmlString.count))
        if linkMatches.isEmpty {
            return nil
        }
        let relRegex = try! NSRegularExpression(
            pattern: "\\srel=\"icon\"",
            options: []
        )
        let relRegexSingleQuotation = try! NSRegularExpression(
            pattern: "\\srel='icon'",
            options: []
        )
        let hrefRegex = try! NSRegularExpression(
            pattern: "\\shref=\"(.*?)\"",
            options: []
        )
        let hrefRegexSingleQuotation = try! NSRegularExpression(
            pattern: "\\shref='(.*?)'",
            options: []
        )
        let sizesRegex = try! NSRegularExpression(
            pattern: "\\ssizes=\"(.*?)\"",
            options: []
        )
        let sizesRegexSingleQuotation = try! NSRegularExpression(
            pattern: "\\ssizes='(.*?)'",
            options: []
        )
        let nsString = htmlString as NSString
        var iconLink: String?
        var maxSize = 0
        for linkMatch in linkMatches {
            let linkTag = nsString.substring(with: linkMatch.range(at: 0))
            let range = NSMakeRange(0, linkTag.count)
            // Check if rel="icon" || rel='icon' exists.
            guard relRegex.matches(in: linkTag, options: [], range: range).first
                ?? relRegexSingleQuotation.matches(in: linkTag, options: [], range: range).first != nil else {
                    continue
            }

            let nsLinkTag = linkTag as NSString
            // Check if sizes="*" || sizes='*' exists, then performs checks to get largest size icon link.
            if let sizesMatch = sizesRegex
                .matches(in: linkTag,
                         options: [],
                         range: range).first
                ?? sizesRegexSingleQuotation
                    .matches(in: linkTag,
                             options: [], range: range).first,
                let sizes = nsLinkTag.substring(with: sizesMatch.range(at: 1)).components(separatedBy: "x").first, let size = Int(sizes) {
                if size > maxSize {
                    maxSize = size
                } else {
                    continue
                }
            }

            // Gets href="*" || href='*'
            guard let hrefMatch = hrefRegex
                .matches(in: linkTag,
                         options: [],
                         range: range).first
                ?? hrefRegexSingleQuotation
                .matches(in: linkTag,
                         options: [],
                         range: range).first else {
                continue
            }
            iconLink = String(nsLinkTag.substring(with: hrefMatch.range(at: 1)))
        }
        return iconLink
    }

    public init(url: URL, cache: NSCache<NSString, WebLinkMetadata>? = WebLinkMetadata.defaultCache, completion: @escaping (WebLinkMetadata?, WebLinkMetadataError?) -> Void) {
        self.url = url
        self.cache = cache
        fetch(url: url, completion: completion)
    }

    init(url: URL) {
        self.url = url
        self.cache = nil
    }

    public subscript(metadata: OpenGraphMetadata) -> String? {
        return openGraph?[metadata.rawValue]
    }

    public subscript(metadata: String) -> String? {
        return openGraph?[metadata]
    }
}

public enum WebLinkMetadataError: Error {
    case requestError(Error?)
    case unsuccessfulStatusCode(Int, Error?)
    case noContentType
    case encodingError
    case noHeadTags
}
