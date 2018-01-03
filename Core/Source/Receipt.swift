//
//  Receipt.swift
//  Kvitto
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

@objcMembers

/**
An iTunes store sales receipt.
*/
@objc(DTReceipt) public final class Receipt: NSObject
{
    /**
     The app’s bundle identifier. This corresponds to the value of CFBundleIdentifier in the Info.plist file.
    */
    fileprivate(set) public var bundleIdentifier: String?
    
    /**
    The app’s bundle identifier original data. This is required for validation.
    */
    fileprivate(set) public var bundleIdentifierData: Data?
    
    /**
    The app’s version number. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist.
    */
    fileprivate(set) public var appVersion: String?
    
    /**
    An opaque value used, with other data, to compute the SHA-1 hash during validation.
    */
    fileprivate(set) public var opaqueValue: Data?
    
    /**
    A SHA-1 hash, used to validate the receipt.
    */
    fileprivate(set) public var SHA1Hash: Data?

    /**
    The version of the app that was originally purchased. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was originally made.
    
    In the sandbox environment, the value of this field is always “1.0”.
    
    Receipts prior to June 20, 2013 omit this field. It is populated on all new receipts, regardless of OS version. If you need the field but it is missing, manually refresh the receipt using the SKReceiptRefreshRequest class
    */
    fileprivate(set) public var originalAppVersion: String?
    
    /**
    The date when the app receipt was created. When validating a receipt, use this date to validate the receipt’s signature.
    */
    fileprivate(set) public var receiptCreationDate: Date?

    /**
    The date that the app receipt expires. When validating a receipt, compare this date to the current date to determine whether the receipt is expired. Do not try to use this date to calculate any other information, such as the time remaining before expiration.
    */
    fileprivate(set) public var receiptExpirationDate: Date?

    // extra string fields, not documented
    
    /**
    The app's age rating. Note: not documented
    */
    fileprivate(set) public var ageRating: String?
    
    /**
    The type of the receipt. For example 'ProductionSandbox'. Note: not documented
    */
    fileprivate(set) public var receiptType: String?
    
    /**
    Date with type code 18, unknown purpose
    */
    fileprivate(set) public var unknownPurposeDate: Date?
    
    /**
    Array of InAppPurchaseReceipt objects decribing IAPs.
    
    The in-app purchase receipt for a consumable product is added to the receipt when the purchase is made. It is kept in the receipt until your app finishes that transaction. After that point, it is removed from the receipt the next time the receipt is updated—for example, when the user makes another purchase or if your app explicitly refreshes the receipt.
    
    The in-app purchase receipt for a non-consumable product, auto-renewable subscription, non-renewing subscription, or free subscription remains in the receipt indefinitely.
    */
    fileprivate(set) public var inAppPurchaseReceipts: [InAppPurchaseReceipt]?
    
    
    /**
    The designated initializer
    */
    public init?(data: Data)
    {
        super.init()
        
        do
        {
            _ = try parseData(data)
        }
        catch
        {
            return nil
        }
    }

    /** 
    Convenience initializer. Decodes the PKCS7Container at the given file URL and decodes its payload as Receipt.
    */
    public convenience init?(contentsOfURL URL: Foundation.URL)
    {
        guard let   data = try? Data(contentsOf: URL),
            let container = PKCS7Container(data: data),
            let payloadData = container.payloadData
        else
        {
            return nil
        }
        
        self.init(data: payloadData)
    }
    
    // MARK: Parsing
    
    fileprivate func parseData(_ data: Data) throws -> Bool
    {
        guard let rootArray = DTASN1Serialization.object(with: data) as? [[AnyObject]]
            else
        {
            throw ReceiptParsingError.invalidRootObject
        }
        
        for var element in rootArray
        {
            guard element.count == 3,
                let type = (element[0] as? NSNumber)?.intValue,
                 let version = (element[1] as? NSNumber)?.intValue,
                    let data = element[2] as? Data
                , version > 0
                else
            {
                throw ReceiptParsingError.invalidRootObject
            }
            
            try processItem(type, data: data)
        }
        
        return true
    }
    
    func processItem(_ type: Int, data: Data) throws
    {
        switch(type)
        {
            case 0:
                receiptType = try _stringFromData(data) as String?
            
            case 2:
                bundleIdentifier = try _stringFromData(data)
                bundleIdentifierData = data
            
            case 3:
                appVersion = try _stringFromData(data)

            case 4:
                opaqueValue = Data(data)

            case 5:
                SHA1Hash = Data(data)
            
            case 10:
                ageRating = try _stringFromData(data) as String?
            
            case 12:
                receiptCreationDate = try _dateFromData(data)
            
            case 17:
                guard let IAP = InAppPurchaseReceipt(data: data)
                else
                {
                    throw ReceiptParsingError.invalidInAppPurchases
                }
                
                if inAppPurchaseReceipts == nil
                {
                    inAppPurchaseReceipts = []
                }
                
                inAppPurchaseReceipts!.append(IAP)
            
            case 18:
                unknownPurposeDate = try _dateFromData(data)
        
            case 19:
                originalAppVersion = try _stringFromData(data)
            
            case 21:
                receiptExpirationDate = try _dateFromData(data)

            default:
                // all other types are private
                break;
        }
    }
}
