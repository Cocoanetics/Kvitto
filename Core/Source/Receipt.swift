//
//  Receipt.swift
//  Kvitto
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

/**
An iTunes store sales receipt.
*/
@objc(DTReceipt) public class Receipt: NSObject
{
    /**
     The app’s bundle identifier. This corresponds to the value of CFBundleIdentifier in the Info.plist file.
    */
    private(set) public var bundleIdentifier: String?
    
    /**
    The app’s bundle identifier original data. This is required for validation.
    */
    private(set) public var bundleIdentifierData: NSData?
    
    /**
    The app’s version number. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist.
    */
    private(set) public var appVersion: String?
    
    /**
    An opaque value used, with other data, to compute the SHA-1 hash during validation.
    */
    private(set) public var opaqueValue: NSData?
    
    /**
    A SHA-1 hash, used to validate the receipt.
    */
    private(set) public var SHA1Hash: NSData?

    /**
    The version of the app that was originally purchased. This corresponds to the value of CFBundleVersion (in iOS) or CFBundleShortVersionString (in OS X) in the Info.plist file when the purchase was originally made.
    
    In the sandbox environment, the value of this field is always “1.0”.
    
    Receipts prior to June 20, 2013 omit this field. It is populated on all new receipts, regardless of OS version. If you need the field but it is missing, manually refresh the receipt using the SKReceiptRefreshRequest class
    */
    private(set) public var originalAppVersion: String?
    
    /**
    The date when the app receipt was created. When validating a receipt, use this date to validate the receipt’s signature.
    */
    private(set) public var receiptCreationDate: NSDate?

    /**
    The date that the app receipt expires. When validating a receipt, compare this date to the current date to determine whether the receipt is expired. Do not try to use this date to calculate any other information, such as the time remaining before expiration.
    */
    private(set) public var receiptExpirationDate: NSDate?

    // extra string fields, not documented
    
    /**
    The app's age rating. Note: not documented
    */
    private(set) public var ageRating: NSString?
    
    /**
    The type of the receipt. For example 'ProductionSandbox'. Note: not documented
    */
    private(set) public var receiptType: NSString?
    
    /**
    Date with type code 18, unknown purpose
    */
    private(set) public var unknownPurposeDate: NSDate?
    
    /**
    Array of InAppPurchaseReceipt objects decribing IAPs.
    
    The in-app purchase receipt for a consumable product is added to the receipt when the purchase is made. It is kept in the receipt until your app finishes that transaction. After that point, it is removed from the receipt the next time the receipt is updated—for example, when the user makes another purchase or if your app explicitly refreshes the receipt.
    
    The in-app purchase receipt for a non-consumable product, auto-renewable subscription, non-renewing subscription, or free subscription remains in the receipt indefinitely.
    */
    private(set) public var inAppPurchaseReceipts: [InAppPurchaseReceipt]?
    
    
    /**
    The designated initializer
    */
    public init?(data: NSData)
    {
        super.init()
        
        do
        {
            try parseData(data)
        }
        catch
        {
            return nil
        }
    }
    
    // MARK: Parsing
    
    private func parseData(data: NSData) throws -> Bool
    {
        guard let rootArray = DTASN1Serialization.objectWithData(data) as? [[AnyObject]]
            else
        {
            throw ReceiptParsingError.InvalidRootObject
        }
        
        for var item in rootArray
        {
            guard item.count == 3,
                let type = (item[0] as? NSNumber)?.integerValue,
                 version = (item[1] as? NSNumber)?.integerValue,
                    data = item[2] as? NSData
                where version > 0
                else
            {
                throw ReceiptParsingError.InvalidRootObject
            }
            
            do
            {
                try processItem(type, data: data)
            }
            catch
            {
                return false
            }
        }
        
        return true
    }
    
    func processItem(type: Int, data: NSData) throws
    {
        switch(type)
        {
            case 0:
                receiptType = try _stringFromData(data)
            
            case 2:
                bundleIdentifier = try _stringFromData(data)
                bundleIdentifierData = data
            
            case 3:
                appVersion = try _stringFromData(data)

            case 4:
                opaqueValue = NSData(data: data)

            case 5:
                SHA1Hash = NSData(data: data)
            
            case 10:
                ageRating = try _stringFromData(data)
            
            case 12:
                receiptCreationDate = try _dateFromData(data)
            
            case 17:
                guard let IAP = InAppPurchaseReceipt(data: data)
                else
                {
                    throw ReceiptParsingError.InvalidInAppPurchases
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