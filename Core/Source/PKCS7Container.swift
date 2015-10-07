//
//  PKCS7Container.swift
//  Kvitto
//
//  Created by Oliver Drobnik on 06/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

/**
 A simplified handler for a PKCS#7 Container. Only retrieves the unencrypted payloadData.
*/
@objc(DTPKCS7Container) public class PKCS7Container: NSObject, DTASN1ParserDelegate
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
        
        guard let rootSequence = DTASN1Serialization.objectWithData(data) as? [AnyObject],
                    unwrappedData = unwrapRootSequence(rootSequence)
        else { return nil }

        payloadData = NSData(data: unwrappedData)
        
        /*
        
        guard data.length > 0 else
        {
            return nil
        }
        
        // create an ASN.1 parser
        let parser = DTASN1Parser(data: data)
        parser.delegate = self
        
        // parsing must succeed
        guard parser.parse() else { return nil }
    */
    }
    
    func unwrapRootSequence(sequence: [AnyObject]) -> NSData?
    {
        guard sequence.count==2,
              let OID = sequence[0] as? String where OID == "1.2.840.113549.1.7.2",
              let containedSequence = sequence[1] as? [AnyObject] where containedSequence.count == 1,
              let actualSequence = containedSequence[0] as? [AnyObject] where actualSequence.count == 5,
              let dataSequence = actualSequence[2] as? [AnyObject]
        else
        {
            return nil
        }
        
        return unwrapSignedDataSequence(dataSequence)
    }
    
    func unwrapSignedDataSequence(sequence: [AnyObject]) -> NSData?
    {
        guard sequence.count==2,
            let OID = sequence[0] as? String where OID == "1.2.840.113549.1.7.1",
            let dataSequence = sequence[1] as? [NSData] where dataSequence.count == 1
            else
        {
            return nil
        }
        
        return dataSequence[0]
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
