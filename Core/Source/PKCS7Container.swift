//
//  PKCS7Container.swift
//  DTSalesReceipt
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

@objc(DTPKCS7Container)
public class PKCS7Container: NSObject, DTASN1ParserDelegate
{
    /**
     The data of the payload
    */
    private(set) public var payloadData: NSData!
    
    /**
     Internal Variable for parsing
    */
    var _objectIdentifier: String?
    
    /**
     The designated initializer
    */
    public init?(data: NSData)
    {
        super.init()
        
        guard data.length > 0 else
        {
            return nil
        }
        
        // create an ASN.1 parser
        let parser = DTASN1Parser(data: data)
        parser.delegate = self
        
        // parsing must succeed
        guard parser.parse() else { return nil }
    }
    
    
    // MARK: DTASN1ParserDelegate
    
    public func parser(parser: DTASN1Parser!, didEndContainerWithType type: DTASN1Type)
    {
        _objectIdentifier = nil
    }
    
    public func parser(parser: DTASN1Parser!, foundObjectIdentifier objIdentifier: String!)
    {
        _objectIdentifier = objIdentifier
    }
    
    public func parser(parser: DTASN1Parser!, foundData data: NSData!)
    {
        if let objectID = _objectIdentifier where objectID == "1.2.840.113549.1.7.1"
        {
            // make a copy of the data if it is immutable
            payloadData = NSData(data: data)
        }
    }
}
