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
        XCTAssertEqual(webLinkMetadata.themeUIColor, UIColor.red)
        
        XCTAssertNotNil(webLinkMetadata.textUIColor)
        XCTAssertEqual(webLinkMetadata.textUIColor, UIColor.white)
        #endif
    }
    
    #if canImport(UIKit)
    func testUIColorFrom() {
        let green = webLinkMetadata.UIColorFrom(hex: "00ff00") //6
        XCTAssertNotNil(green)
        XCTAssertEqual(green, UIColor.green)
        
        let blue = webLinkMetadata.UIColorFrom(hex: "#0000ff") // 7
        XCTAssertNotNil(blue)
        XCTAssertEqual(blue, UIColor.blue)
        
        let alphaBlue = webLinkMetadata.UIColorFrom(hex: "ff0000ff") // 8
        XCTAssertNotNil(alphaBlue)
        XCTAssertEqual(alphaBlue, UIColor.blue)
        
        let alphaClear = webLinkMetadata.UIColorFrom(hex: "#000000ff") // 9
        XCTAssertNotNil(alphaClear)
        XCTAssertEqual(alphaClear, UIColor(red: 0, green: 0, blue: 1, alpha: 0))
    }
    
    func testTextColorFrom() {
        let blackTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.black)
        XCTAssertNotNil(blackTextColor)
        XCTAssertEqual(blackTextColor, UIColor.white)
        
        let whiteTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.white)
        XCTAssertNotNil(whiteTextColor)
        XCTAssertEqual(whiteTextColor, UIColor.black)
        
        let tertiaryLabelTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor(white: 0.75, alpha: 1))
        XCTAssertNotNil(tertiaryLabelTextColor)
        XCTAssertEqual(tertiaryLabelTextColor, UIColor.black)
        
        let lightGrayTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.lightGray)
        XCTAssertNotNil(lightGrayTextColor)
        XCTAssertEqual(lightGrayTextColor, UIColor.white)
        
        let darkGrayTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.darkGray)
        XCTAssertNotNil(darkGrayTextColor)
        XCTAssertEqual(darkGrayTextColor, UIColor.white)
        
        let redTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.red)
        XCTAssertNotNil(redTextColor)
        XCTAssertEqual(redTextColor, UIColor.white)
        
        let greenTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.green)
        XCTAssertNotNil(greenTextColor)
        XCTAssertEqual(greenTextColor, UIColor.white)
        
        let blueTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.blue)
        XCTAssertNotNil(blueTextColor)
        XCTAssertEqual(blueTextColor, UIColor.white)
        
        let purpleTextColor = webLinkMetadata.UITextColorFor(backgroundColor: UIColor.purple)
        XCTAssertNotNil(purpleTextColor)
        XCTAssertEqual(purpleTextColor, UIColor.white)
    }
    #endif

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
