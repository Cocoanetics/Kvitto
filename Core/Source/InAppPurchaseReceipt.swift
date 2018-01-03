//
//  InAppPurchaseReceipt.swift
//  Kvitto
//
//  Created by Oliver Drobnik on 07/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

import Foundation
import DTFoundation

@objcMembers

/**
 A purchase receipt for an IAP
*/
@objc(DTInAppPurchaseReceipt) public final class InAppPurchaseReceipt: NSObject
{
    /**
    The number of items purchased. This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
    */
    fileprivate(set) public var quantity: Int?
    
    /**
     ObjectiveC support of quantity(NSInteger:- quantityNumber.integerValue)
     The number of items purchased. This value corresponds to the quantity property of the SKPayment object stored in the transaction’s payment property.
     */
    public var quantityNumber : NSNumber? {
        get {
            return quantity as NSNumber?
        }
    }
    
    /**
    The product identifier of the item that was purchased. This value corresponds to the productIdentifier property of the SKPayment object stored in the transaction’s payment property.
    */
    fileprivate(set) public var productIdentifier: String?
    
    /**
    The transaction identifier of the item that was purchased. This value corresponds to the transaction’s transactionIdentifier property.
    */
    fileprivate(set) public var transactionIdentifier: String?
    
    /**
    For a transaction that restores a previous transaction, the transaction identifier of the original transaction. Otherwise, identical to the transaction identifier. This value corresponds to the original transaction’s transactionIdentifier property.
    
    All receipts in a chain of renewals for an auto-renewable subscription have the same value for this field.
    */
    fileprivate(set) public var originalTransactionIdentifier: String?
    
    /**
    The date and time that the item was purchased. This value corresponds to the transaction’s transactionDate property.
    
    For a transaction that restores a previous transaction, the purchase date is the date of the restoration. Use Original Purchase Date to get the date of the original transaction.
    
    In an auto-renewable subscription receipt, this is always the date when the subscription was purchased or renewed, regardless of whether the transaction has been restored.
    */
    fileprivate(set) public var purchaseDate: Date?
    
    /**
    For a transaction that restores a previous transaction, the date of the original transaction. This value corresponds to the original transaction’s transactionDate property.
    
    In an auto-renewable subscription receipt, this indicates the beginning of the subscription period, even if the subscription has been renewed.
    */
    fileprivate(set) public var originalPurchaseDate: Date?
    
    /**
    The expiration date for the subscription. This key is only present for auto-renewable subscription receipts.
    */
    fileprivate(set) public var subscriptionExpirationDate: Date?
    
    /**
    For a transaction that was canceled by Apple customer support, the time and date of the cancellation. Treat a canceled receipt the same as if no purchase had ever been made.
    */
    fileprivate(set) public var cancellationDate: Date?
    
    /**
    The primary key for identifying subscription purchases.
    */
    fileprivate(set) public var webOrderLineItemIdentifier: Int?
    
    /**
     ObjectiveC support of webOrderLineItemIdentifier(NSInteger:- webOrderLineItemIdentifierNumber.integerValue)
     The primary key for identifying subscription purchases.
     */
    public var webOrderLineItemIdentifierNumber : NSNumber? {
        get {
            return webOrderLineItemIdentifier as NSNumber?
        }
    }
    
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
    
    // MARK: Parsing
    
    fileprivate func parseData(_ data: Data) throws -> Bool
    {
        guard let rootArray = DTASN1Serialization.object(with: data) as? [[AnyObject]]
            else
        {
            throw ReceiptParsingError.invalidRootObject
        }
        
        for var item in rootArray
        {
            guard item.count == 3,
                let type = (item[0] as? NSNumber)?.intValue,
                let version = (item[1] as? NSNumber)?.intValue,
                let data = item[2] as? Data
                , version > 0
                else
            {
                throw ReceiptParsingError.invalidRootObject
            }
            
            try processItem(type, data: data)
        }
        
        return true
    }
    
    fileprivate func processItem(_ type: Int, data: Data) throws
    {
        switch(type)
        {
        case 1701:
            quantity = try _intFromData(data)
            
        case 1702:
            productIdentifier = try _stringFromData(data)
            
        case 1703:
            transactionIdentifier = try _stringFromData(data)
            
        case 1704:
            purchaseDate = try _dateFromData(data)
            
        case 1705:
            originalTransactionIdentifier = try _stringFromData(data)
            
        case 1706:
            originalPurchaseDate = try _dateFromData(data)
            
        case 1708:
            subscriptionExpirationDate = try _dateFromData(data)
            
        case 1711:
            webOrderLineItemIdentifier = try _intFromData(data)
            
        case 1712:
            cancellationDate = try _dateFromData(data)
            
        default:
            // all other types are private
            break;
        }
    }
}
