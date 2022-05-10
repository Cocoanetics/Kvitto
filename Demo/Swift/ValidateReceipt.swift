//
//  ValidateReceipt.swift
//  Kvitto
//
//  Created by Marius Grüter on 09.05.22.
//  Copyright © 2022 Marius Grüter. All rights reserved.
//

import StoreKit
import CryptoKit

import Kvitto

/**
Example validation of the Kvitto Receipt in Swift5 and decide if a refresh is necessary
*/
func refreshReceiptIsNecessary() -> Bool {
    
    // Get the receipt if it's available
    guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
          FileManager.default.fileExists(atPath: appStoreReceiptURL.path) else { return true }
    
    guard let receipt = Receipt(contentsOfURL: appStoreReceiptURL) else { return true }
    
    // ingredients for validation
    let mainBundle = Bundle.main
    let bundleIdentifier = mainBundle.bundleIdentifier // could also be hard-coded
    let appVersion = mainBundle.infoDictionary?[kCFBundleVersionKey as String] as? String // could be hard-coded
    
    if receipt.bundleIdentifier != bundleIdentifier {
        print("Incorrect bundle identifier in receipt")
        return true
    }
    
    /*
     In iOS, use the value returned by the identifierForVendor property of UIDevice as the computer’s GUID.
     
     To compute the hash, first concatenate the GUID value with the opaque value (the attribute of type 4) and the bundle identifier.
     Use the raw bytes from the receipt without performing any UTF-8 string interpretation or normalization.
     Then compute the SHA-1 hash of this concatenated series of bytes.
     */
    guard let vendorIdentifier = UIDevice.current.identifierForVendor  else { return true }
    let vendorData = withUnsafePointer(to: vendorIdentifier.uuid) {
        Data(bytes: $0, count: MemoryLayout.size(ofValue: vendorIdentifier.uuid))
    }
    
    guard let receiptOpaqueValue = receipt.opaqueValue else { return true }
    guard let receiptBundleIdentifierData = receipt.bundleIdentifierData else { return true }
    
    // concatenate data for vendor identifier, opaque value and bundle identifier
    var hashData = Data()
    hashData.append(vendorData)
    hashData.append(receiptOpaqueValue)
    hashData.append(receiptBundleIdentifierData)
    
    // calculate SHA1
    let hash = Insecure.SHA1.hash(data: hashData)
    
    guard let receiptSHA1Hash = receipt.SHA1Hash else { return true }
    
    if hash == receiptSHA1Hash {
        print("Receipt is Valid")
        return false
    }
    
    print("Receipt is Invalid")
    return true
    
}
