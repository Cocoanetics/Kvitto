//
//  DTSalesReceiptTests.swift
//  DTSalesReceiptTests
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import XCTest
import DTFoundation

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

    func testDecodeRegularReceipt()
    {
        let data = dataForTestResource("receipt", ofType: "pk7")!
        let pkcs = PKCS7Container(data: data)
        guard let payload = pkcs?.payloadData
            else
        {
            XCTFail()
            return
        }
        
        guard let receipt = SalesReceipt(data: payload)
            else
        {
            XCTFail("Error parsing receipt")
            return
        }
        
        XCTAssertEqual(receipt.bundleIdentifier, "com.cocoanetics.EmmiView")
        XCTAssertEqual(receipt.appVersion, "238")
        XCTAssertEqual(receipt.originalAppVersion, "1.0")
        XCTAssertEqual(receipt.opaqueValue?.length, 16)
        XCTAssertEqual(receipt.SHA1Hash?.length, 20)
        XCTAssertNil(receipt.receiptExpirationDate)
        XCTAssertNotNil(receipt.receiptCreationDate)
        XCTAssertEqual(receipt.ageRating, "4+")
        XCTAssertEqual(receipt.receiptType, "ProductionSandbox")
    }
    
    func testDecodeSandboxReceipt()
    {
        let data = dataForTestResource("sandboxReceipt", ofType: nil)!
        let pkcs = PKCS7Container(data: data)
        guard let payload = pkcs?.payloadData
        else
        {
            XCTFail()
            return
        }
        
        guard let receipt = SalesReceipt(data: payload)
        else
        {
            XCTFail("Error parsing receipt")
            return
        }
        
        XCTAssertEqual(receipt.bundleIdentifier, "com.cocoanetics.EmmiView")
        XCTAssertEqual(receipt.appVersion, "246")
        XCTAssertEqual(receipt.originalAppVersion, "1.0")
        XCTAssertEqual(receipt.opaqueValue?.length, 16)
        XCTAssertEqual(receipt.SHA1Hash?.length, 20)
        XCTAssertNil(receipt.receiptExpirationDate)
        XCTAssertNotNil(receipt.receiptCreationDate)
        XCTAssertEqual(receipt.ageRating, "4+")
        XCTAssertEqual(receipt.receiptType, "ProductionSandbox")
    }
    
    // MARK: - Helper
    
    func dataForTestResource(name: String?, ofType ext: String?) -> NSData?
    {
        let bundle = NSBundle(forClass: self.dynamicType)
        
        guard let path = bundle.pathForResource(name, ofType: ext) else { return nil }

        return NSData(contentsOfFile: path)
    }
    
    
}
