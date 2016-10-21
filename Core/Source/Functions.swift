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
enum ReceiptParsingError: Error
{
    case invalidRootObject
    case invalidInAppPurchases
    case cannotDecodeExpectedInt
    case cannotDecodeExpectedString
    case cannotDecodeDate
}

/**
Internal Helper Functions
*/
internal func _intFromData(_ data: Data) throws -> Int
{
    guard let number = DTASN1Serialization.object(with: data) as? NSNumber
    else
    {
        throw ReceiptParsingError.cannotDecodeExpectedInt
    }
    
    return number.intValue
}

internal func _stringFromData(_ data: Data) throws -> String
{
    guard let string = DTASN1Serialization.object(with: data) as? String
    else
    {
        throw ReceiptParsingError.cannotDecodeExpectedString
    }
    
    return string
}

internal func _dateFromData(_ data: Data) throws -> Date?
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
        throw ReceiptParsingError.cannotDecodeDate
    }
    
    return date
}

internal func _dateFromRFC3339String(_ string: String) -> Date?
{
    let rfc3339DateFormatter = DateFormatter()
    rfc3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
    rfc3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return rfc3339DateFormatter.date(from: string)
}
