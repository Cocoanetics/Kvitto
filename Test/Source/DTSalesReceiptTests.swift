//
//  DTSalesReceiptTests.swift
//  DTSalesReceiptTests
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import XCTest
@testable import Kvitto

class DTSalesReceiptTests: XCTestCase
{
    func testReceiptExistsInTestBundle()
    {
        let data = dataForTestResource("receipt", ofType: "pk7")
        XCTAssertNotNil(data)
    }
    
    func testSandboxReceiptExistsInTestBundle()
    {
        let data = dataForTestResource("sandboxReceipt", ofType: nil)
        XCTAssertNotNil(data)
    }
    
    func testEmptyData()
    {
        let emptyData = NSData()
        let pkcs7 = PKCS7Container(data: emptyData)
        
        XCTAssertNil(pkcs7)
    }
    
    func testDecodeReceiptPayload()
    {
        let data = dataForTestResource("receipt", ofType: "pk7")!
        let pkcs = PKCS7Container(data: data)
        
        XCTAssertEqual(pkcs?.payloadData?.length, 890)
    }

    func testDecodeSandboxReceiptPayload()
    {
        let data = dataForTestResource("sandboxReceipt", ofType: nil)!
        let pkcs = PKCS7Container(data: data)
        
        XCTAssertEqual(pkcs?.payloadData?.length, 2833)
    }
    
    // MARK: - Helper
    
    func dataForTestResource(name: String?, ofType ext: String?) -> NSData?
    {
        let bundle = NSBundle(forClass: self.dynamicType)
        
        guard let path = bundle.pathForResource(name, ofType: ext) else { return nil }

        return NSData(contentsOfFile: path)
    }
    
    
}
