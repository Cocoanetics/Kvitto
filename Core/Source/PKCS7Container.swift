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

        payloadData = unwrappedData
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
}
