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
@objc(DTPKCS7Container) @objcMembers open class PKCS7Container: NSObject, DTASN1ParserDelegate
{
    /**
     The data of the payload
    */
    fileprivate(set) open var payloadData: Data!
    
    /**
     Internal Variable for parsing
    */
    var _objectIdentifier: String?
    
    /**
     The designated initializer
    */
    public init?(data: Data)
    {
        super.init()
        
        guard let rootSequence = DTASN1Serialization.object(with: data) as? [AnyObject],
                    let unwrappedData = unwrapRootSequence(rootSequence)
        else {
			return nil
		}

        payloadData = unwrappedData
    }
    
    func unwrapRootSequence(_ sequence: [AnyObject]) -> Data?
    {
		guard sequence.count==2,
			  let OID = sequence[0] as? String,
			  OID == "1.2.840.113549.1.7.2" else
		{
			return nil
		}
		
		let containedSequence: [AnyObject]
		
        if let sequence = sequence[1] as? [AnyObject],
		   sequence.count == 1
        {
			// no extra context containers
			containedSequence = sequence
        }
		else if let context = sequence[1] as? [Int: AnyObject],
				let contained = context[0] as? [AnyObject],
				let sequence = contained[0] as? [AnyObject]
		{
			// container with context 0
			containedSequence = sequence
		}
		else
		{
			return nil
		}
		
		guard let actualSequence = containedSequence[0] as? [AnyObject],
			actualSequence.count > 2,
			let dataSequence = actualSequence[2] as? [AnyObject] else
		{
			return nil
		}
		
		return unwrapSignedDataSequence(dataSequence)
    }
    
    func unwrapSignedDataSequence(_ sequence: [AnyObject]) -> Data?
    {
        guard sequence.count==2,
            let OID = sequence[0] as? String,
			OID == "1.2.840.113549.1.7.1"
            else
        {
            return nil
        }
		
		if let context = sequence[1] as? [Int: AnyObject],
		   let contents = context[0]
		{
			return unwrapData(from: contents)
		}
		else
		{
			return unwrapData(from: sequence[1])
		}
    }
}

fileprivate func unwrapData(from object: AnyObject) -> Data?
{
	var currentObject = object
	
	while let array = currentObject as? [AnyObject],
		  array.count == 1
	{
		currentObject = array.first!
	}
	
	return currentObject as? Data
}
