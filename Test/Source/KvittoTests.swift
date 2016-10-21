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
        let emptyData = Data()
        let pkcs7 = PKCS7Container(data: emptyData)
        
        XCTAssertNil(pkcs7)
    }
    
    func testDecodeReceiptPayload()
    {
        let data = dataForTestResource("receipt", ofType: nil)!
        let pkcs = PKCS7Container(data: data)
        
        XCTAssertEqual(pkcs?.payloadData?.count, 505)
    }

    func testDecodeSandboxReceiptPayload()
    {
        let data = dataForTestResource("sandboxReceipt", ofType: nil)!
        let pkcs = PKCS7Container(data: data)
        
        XCTAssertEqual(pkcs?.payloadData?.count, 2833)
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
        XCTAssertEqual(receipt.opaqueValue?.count, 16)
        XCTAssertEqual(receipt.SHA1Hash?.count, 20)
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
        XCTAssertEqual(receipt.opaqueValue?.count, 16)
        XCTAssertEqual(receipt.SHA1Hash?.count, 20)
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
    
    func dataForTestResource(_ name: String?, ofType ext: String?) -> Data?
    {
        let bundle = Bundle(for: type(of: self))
        
        guard let path = bundle.path(forResource: name, ofType: ext) else { return nil }

        return (try? Data(contentsOf: URL(fileURLWithPath: path)))
    }
    
    func receiptFromTestResource(_ name: String?, ofType ext: String?) -> Receipt?
    {
        let bundle = Bundle(for: type(of: self))
        
        guard let URL = bundle.url(forResource: name, withExtension: ext) else { return nil }
        
        return Receipt(contentsOfURL: URL)
    }
}
