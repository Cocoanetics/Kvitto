//
//  SalesReceipt.swift
//  DTSalesReceipt
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

@objc(DTSalesReceipt)
public class SalesReceipt: NSObject, DTASN1ParserDelegate
{
    var bundleIdentifier: String?
    var bundleIdentifierData: NSData?
    var appVersion: String?
    var originalAppVersion: String?
    var opaqueValue: NSData?
    var SHA1Hash: NSData?
    var receiptExpirationDate: NSDate?
    
    /**
    Array of InAppPurchaseReceipt objects decribing IAPs
    */
    var inAppPurchaseReceipts: [AnyObject]?
    
    
    /**
    Internal Variables for parsing
    */
    var _objectIdentifier: String?
    var _type: Int?
    var _version: Int?
   
    

    /**
    The designated initializer
    */
    public init?(data: NSData)
    {
        super.init()
        
        // create an ASN.1 parser
        let parser = DTASN1Parser(data: data)
        parser.delegate = self
        
        // parsing must succeed
        guard parser.parse() else { return nil }
    }
    
    // MARK: DTASN1ParserDelegate
    
    public func parser(parser: DTASN1Parser!, didEndContainerWithType type: DTASN1Type)
    {
        if type == .Sequence
        {
            // reset
            _objectIdentifier = nil;
            _type = nil;
            _version = nil;
        }
    }
    
    public func parser(parser: DTASN1Parser!, foundObjectIdentifier objIdentifier: String!)
    {
        _objectIdentifier = objIdentifier
    }
    
    public func parser(parser: DTASN1Parser!, foundString string: String!)
    {
        // NOOP
    }
    
    public func parser(parser: DTASN1Parser!, foundNumber number: NSNumber!)
    {
        if _type == nil
        {
            _type = number.integerValue
        }
        else if _version == nil
        {
            _version = number.integerValue
        }
        else
        {
            NSLog("Found number %@ where not expected", number)
        }
    }
    
    public func parser(parser: DTASN1Parser!, foundData data: NSData!)
    {
        guard let type = _type
        else
        {
            NSLog("type is still nil, but trying to parse data")
            return
        }
        
        switch(type)
        {
            case 2:
                bundleIdentifier = _stringFromData(data)
                bundleIdentifierData = data!
            
            case 3:
                appVersion = _stringFromData(data)

            case 4:
                opaqueValue = NSData(data: data)

            case 5:
                SHA1Hash = NSData(data: data)
            
            case 17:
                if inAppPurchaseReceipts == nil
                {
                    inAppPurchaseReceipts = []

                    // TODO: Implement IAP
//                    InAppPurchaseReceipt *receipt = [[InAppPurchaseReceipt alloc] initWithData:data];
//                    [_inAppPurchaseReceipts addObject:receipt];
                }
            
            case 19:
                originalAppVersion = _stringFromData(data)
            
            case 21:
                guard let string = _stringFromData(data),
                          date = _dateFromRFC3339String(string)
                else
                {
                    NSLog("Cannot parse receiptExpirationDate")
                    break
                }
            
                receiptExpirationDate = date

            default:
                NSLog("Unknown type '%d'", _type!)
                break;
        }
    }
    
    
    // MARK: - Helpers
    
    func _stringFromData(data: NSData) -> String?
    {
        guard let string = DTASN1Serialization.objectWithData(data) as? String
        else
        {
            NSLog("Cannot parse data '%@' as string", data)
            return nil
        }
        
        return string
    }
    
    func _dateFromRFC3339String(string: String) -> NSDate?
    {
        let rfc3339DateFormatter = NSDateFormatter()
        rfc3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        rfc3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        rfc3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return rfc3339DateFormatter.dateFromString(string)
    }
}