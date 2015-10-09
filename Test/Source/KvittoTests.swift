//
//  DTReceiptTests.swift
//  DTReceiptTests
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import XCTest
import DTFoundation

@testable import Kvitto

class DTReceiptTests: XCTestCase
{
    func testReceiptExistsInTestBundle()
    {
        let data = dataForTestResource("receipt", ofType: nil)
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
        let data = dataForTestResource("receipt", ofType: nil)!
        let pkcs = PKCS7Container(data: data)
        
        XCTAssertEqual(pkcs?.payloadData?.length, 505)
    }

    func testDecodeSandboxReceiptPayload()
    {
        let data = dataForTestResource("sandboxReceipt", ofType: nil)!
        let pkcs = PKCS7Container(data: data)
        
        XCTAssertEqual(pkcs?.payloadData?.length, 2833)
    }

    func testDecodeRegularReceipt()
    {
        guard let receipt = receiptFromTestResource("receipt", ofType: nil)
            else
        {
            XCTFail("Error parsing receipt")
            return
        }
        
        XCTAssertEqual(receipt.bundleIdentifier, "com.apple.dt.Xcode")
        XCTAssertEqual(receipt.appVersion, "7.0")
        XCTAssertEqual(receipt.originalAppVersion, "4.3")
        XCTAssertEqual(receipt.opaqueValue?.length, 16)
        XCTAssertEqual(receipt.SHA1Hash?.length, 20)
        XCTAssertNil(receipt.receiptExpirationDate)
        XCTAssertNotNil(receipt.receiptCreationDate)
        XCTAssertEqual(receipt.ageRating, "4+")
        XCTAssertEqual(receipt.receiptType, "Production")
        XCTAssertNil(receipt.inAppPurchaseReceipts)
    }
    
    func testDecodeSandboxReceipt()
    {
        guard let receipt = receiptFromTestResource("sandboxReceipt", ofType: nil)
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
        
        guard let iap = receipt.inAppPurchaseReceipts?.first
            else
        {
            XCTFail("No IAP decoded")
            return
        }
        
        XCTAssertEqual(iap.productIdentifier, "com.cocoanetics.EmmiView.OneMonth")
        XCTAssertEqual(iap.transactionIdentifier, "1000000156449405")
        XCTAssertEqual(iap.originalTransactionIdentifier, "1000000156444989")
        XCTAssertNotNil(iap.subscriptionExpirationDate)
        XCTAssertNotNil(iap.webOrderLineItemIdentifier)
        XCTAssertNotNil(iap.purchaseDate)
        XCTAssertNil(iap.cancellationDate)
        // XCTAssertEqual(iap.webOrderLineItemIdentifier, 1000000029801037)
    }
    
    // MARK: - Helper
    
    func dataForTestResource(name: String?, ofType ext: String?) -> NSData?
    {
        let bundle = NSBundle(forClass: self.dynamicType)
        
        guard let path = bundle.pathForResource(name, ofType: ext) else { return nil }

        return NSData(contentsOfFile: path)
    }
    
    func receiptFromTestResource(name: String?, ofType ext: String?) -> Receipt?
    {
        let bundle = NSBundle(forClass: self.dynamicType)
        
        guard let URL = bundle.URLForResource(name, withExtension: ext) else { return nil }
        
        return Receipt(contentsOfURL: URL)
    }
}
