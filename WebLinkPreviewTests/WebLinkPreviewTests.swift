//
//  WebLinkPreviewTests.swift
//  WebLinkPreviewTests
//
//  Created by Philip on 23/3/19.
//  Copyright © 2019 Next Generation. All rights reserved.
//

import XCTest

class WebLinkPreviewTests: XCTestCase {
    let url = URL(string: "https://www.youtube.com/")!
    lazy var webLinkMetadata: WebLinkMetadata = {
        WebLinkMetadata(url: url) { _, _ in
            
        }
    }()
    
    func testWebLinkMetadata() {
        // TODO: Add OkHttpStubs
    }

    func testOpenGraphParsing() {
        let openGraph = webLinkMetadata.parse(metadataFrom: """
            <meta property="og:image" content="/yts/img/yt_1200-vfl4C3T0K.png">
        """)
        XCTAssertFalse(openGraph.isEmpty)
        XCTAssertEqual(1, openGraph.count)
        XCTAssertNotNil(openGraph["image"])
        XCTAssertEqual("/yts/img/yt_1200-vfl4C3T0K.png", openGraph["image"])
        webLinkMetadata.openGraph = openGraph
        XCTAssertEqual(webLinkMetadata[OpenGraphMetadata.image], openGraph["image"])
    }

    func testThemeColorParsing() {
        let openGraph = webLinkMetadata.parse(metadataFrom: """
            <meta name="theme-color" content="#ff0000">
        """)
        XCTAssertTrue(openGraph.isEmpty)
        XCTAssertNotNil(webLinkMetadata.themeColor)
        XCTAssertEqual(webLinkMetadata.themeColor, "#ff0000")
        #if canImport(UIKit)
        XCTAssertNotNil(webLinkMetadata.themeUIColor)
        XCTAssertEqual(webLinkMetadata.themeUIColor, UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        
        let green = webLinkMetadata.UIColorFrom(hex: "#00ff00")
        XCTAssertNotNil(green)
        XCTAssertEqual(green, UIColor(red: 0, green: 1, blue: 0, alpha: 1))
        
        let blue = webLinkMetadata.UIColorFrom(hex: "#0000ff")
        XCTAssertNotNil(blue)
        XCTAssertEqual(blue, UIColor(red: 0, green: 0, blue: 1, alpha: 1))
        #endif
    }

    func testIconLinkParsing() {
        let iconLink = webLinkMetadata.parse(iconFrom: """
            <link rel="icon" href="/yts/img/favicon_32-vflOogEID.png" sizes="32x32">
        """)
        XCTAssertNotNil(iconLink)
        XCTAssertEqual(iconLink, "/yts/img/favicon_32-vflOogEID.png")
        
        let relativeURL = webLinkMetadata.URLFrom(link: iconLink!, url: url)
        XCTAssertNotNil(relativeURL)
        XCTAssertEqual(relativeURL?.absoluteString, "https://www.youtube.com/yts/img/favicon_32-vflOogEID.png")
        
        let absoluteURL = webLinkMetadata.URLFrom(link: "https://www.youtube.com/yts/img/favicon_32-vflOogEID.png", url: url)
        XCTAssertNotNil(absoluteURL)
        XCTAssertEqual(absoluteURL?.absoluteString, "https://www.youtube.com/yts/img/favicon_32-vflOogEID.png")
        
        let iconLinkLargestSize = webLinkMetadata.parse(iconFrom: """
            <link rel="shortcut icon" href="https://s.ytimg.com/yts/img/favicon-vfl8qSV2F.ico" type="image/x-icon">
            <link rel="icon" href="/yts/img/favicon_32-vflOogEID.png" sizes="32x32">
            <link rel="icon" href="/yts/img/favicon_48-vflVjB_Qk.png" sizes="48x48">
            <link rel="icon" href="/yts/img/favicon_144-vfliLAfaB.png" sizes="144x144">
            <link rel="icon" href="/yts/img/favicon_96-vflW9Ec0w.png" sizes="96x96">
        """)
        XCTAssertNotNil(iconLinkLargestSize)
        XCTAssertEqual(iconLinkLargestSize, "/yts/img/favicon_144-vfliLAfaB.png")
        
        let iconLinkNoSize = webLinkMetadata.parse(iconFrom: """
            <link rel="icon" href="/yts/img/favicon_32-vflOogEID.png">
            <link rel="icon" href="/yts/img/favicon_48-vflVjB_Qk.png">
            <link rel="icon" href="/yts/img/favicon_144-vfliLAfaB.png">
            <link rel="icon" href="/yts/img/favicon_96-vflW9Ec0w.png">
        """)
        XCTAssertNotNil(iconLinkNoSize)
        XCTAssertEqual(iconLinkNoSize, "/yts/img/favicon_96-vflW9Ec0w.png")
        
        let iconLinkEmpty = webLinkMetadata.parse(iconFrom: """
            <link rel="manifest" href="/manifest.json">
            <link rel="shortlink" href="https://youtu.be/m_TTWN4K8ec">
            <link rel="search" type="application/opensearchdescription+xml" href="https://www.youtube.com/opensearch?locale=en_US" title="YouTube Video Search">
        """)
        XCTAssertNil(iconLinkEmpty)
    }
}
