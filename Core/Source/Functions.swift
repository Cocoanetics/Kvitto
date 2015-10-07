//
//  Functions.swift
//  Kvitto
//
//  Created by Oliver Drobnik on 07/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

/**
Errors which can happen during parsing
*/
enum ReceiptParsingError: ErrorType
{
    case InvalidRootObject
    case InvalidInAppPurchases
    case CannotDecodeExpectedInt
    case CannotDecodeExpectedString
    case CannotDecodeDate
}

/**
Internal Helper Functions
*/
internal func _intFromData(data: NSData) throws -> Int
{
    guard let number = DTASN1Serialization.objectWithData(data) as? NSNumber
    else
    {
        throw ReceiptParsingError.CannotDecodeExpectedInt
    }
    
    return number.integerValue
}

internal func _stringFromData(data: NSData) throws -> String
{
    guard let string = DTASN1Serialization.objectWithData(data) as? String
    else
    {
        throw ReceiptParsingError.CannotDecodeExpectedString
    }
    
    return string
}

internal func _dateFromData(data: NSData) throws -> NSDate?
{
    let string = try _stringFromData(data)
    
    if string.isEmpty
    {
        // we accept a zero-length string as nil date
        return nil
    }
    
    guard let date = _dateFromRFC3339String(string)
    else
    {
        throw ReceiptParsingError.CannotDecodeDate
    }
    
    return date
}

internal func _dateFromRFC3339String(string: String) -> NSDate?
{
    let rfc3339DateFormatter = NSDateFormatter()
    rfc3339DateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    rfc3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    rfc3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
    return rfc3339DateFormatter.dateFromString(string)
}