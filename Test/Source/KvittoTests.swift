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
	
	func testDecodeStoreKitTestReceipt()
	{
		guard let receipt = receiptFromTestResource("storeKitTestReceipt", ofType: nil)
		else
		{
			XCTFail("Error parsing receipt")
			return
		}
		
		XCTAssertEqual(receipt.bundleIdentifier, "com.rd.eehelper")
		XCTAssertEqual(receipt.appVersion, "2020.10.02.1149")
		XCTAssertEqual(receipt.originalAppVersion, nil)
		XCTAssertEqual(receipt.opaqueValue?.count, 8)
		XCTAssertEqual(receipt.SHA1Hash?.count, 20)
		XCTAssertEqual(receipt.receiptExpirationDate, Date.distantFuture)
		XCTAssertNotNil(receipt.receiptCreationDate)
		XCTAssertNil(receipt.ageRating)
		XCTAssertEqual(receipt.receiptType, "Xcode")
		
		guard let iap = receipt.inAppPurchaseReceipts?.first
			else
		{
			XCTFail("No IAP decoded")
			return
		}
		
		XCTAssertEqual(iap.productIdentifier, "com.rd.eehelper.pro_subscription")
		XCTAssertEqual(iap.transactionIdentifier, "0")
		XCTAssertNil(iap.originalTransactionIdentifier)
		XCTAssertNotNil(iap.subscriptionExpirationDate)
		XCTAssertNil(iap.webOrderLineItemIdentifier)
		XCTAssertNotNil(iap.purchaseDate)
		XCTAssertNil(iap.cancellationDate)
		// XCTAssertEqual(iap.webOrderLineItemIdentifier, 1000000029801037)
	}
    
    // MARK: - Helper
    
	func urlForTestResource(name: String, ofType ext: String?) -> URL?
	{
		let bundle = Bundle(for: type(of: self))
		
		#if SWIFT_PACKAGE
		
		// there is a bug where Bundle.module points to the path of xcrun inside the Xcode.app bundle, instead of the test bundle
		// that aborts unit tests with message:
		//   Fatal error: could not load resource bundle: /Applications/Xcode.app/Contents/Developer/usr/bin/Kvitto_KvittoTests.bundle: file KvittoTests/resource_bundle_accessor.swift, line 7
		
		// workaround: try to find the resource bundle at the build path
		let buildPathURL = bundle.bundleURL.deletingLastPathComponent()
		
		guard let resourceBundle = Bundle(url: buildPathURL.appendingPathComponent("Kvitto_KvittoTests.bundle")),
		   let path = resourceBundle.path(forResource: name, ofType: ext) else
		{
			return nil
		}
		
		return URL(fileURLWithPath: path)
		
		#else
		
		guard let path = bundle.path(forResource: name, ofType: ext) else
		{
			return nil
		}
		
		return URL(fileURLWithPath: path)
		
		#endif
	}
	
    func dataForTestResource(_ name: String, ofType ext: String?) -> Data?
    {
		guard let url = urlForTestResource(name: name, ofType: ext) else
		{
			return nil
		}

		return (try? Data(contentsOf: url))
    }
    
    func receiptFromTestResource(_ name: String, ofType ext: String?) -> Receipt?
    {
		guard let url = urlForTestResource(name: name, ofType: ext) else
		{
			return nil
		}

        return Receipt(contentsOfURL: url)
    }
}
