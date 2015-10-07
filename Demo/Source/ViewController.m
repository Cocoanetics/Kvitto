//
//  ViewController.m
//  Kvitto Demo
//
//  Created by Oliver Drobnik on 07/10/15.
//  Copyright © 2015 Oliver Drobnik. All rights reserved.
//

#import "ViewController.h"

@import Kvitto;
@import DTFoundation;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self _refreshReceiptIsNecessary])
    {
        self.label.textColor = [UIColor redColor];
        self.label.text = @"Receipt needs to be refreshed";
    }
    else
    {
        self.label.textColor = [UIColor greenColor];
        self.label.text = @"Receipt is ok";
    }
}

#pragma mark - Receipt Checking

- (DTReceipt *)_purchaseReceipt
{
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *receiptURL = [mainBundle appStoreReceiptURL];
    
    // override path for demo
    receiptURL = [mainBundle URLForResource:@"newReceipt" withExtension:nil];
    
    // load receipt
    return [[DTReceipt alloc] initWithContentsOfURL: receiptURL];
}

- (BOOL)_refreshReceiptIsNecessary
{
    DTReceipt *receipt = [self _purchaseReceipt];
    
    if (!receipt)
    {
        DTLogDebug(@"No valid Receipt found");
        return YES;
    }
    
    // ingredients for validation
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundleIdentifier = mainBundle.bundleIdentifier; // could also be hard-coded
    NSString *appVersion = mainBundle.infoDictionary[(__bridge NSString *)kCFBundleVersionKey]; // could be hard-coded
    NSUUID *vendorIdentifier = [[UIDevice currentDevice] identifierForVendor];
    
    // for demo: override values so that the receipt validates
    bundleIdentifier = @"de.emmi-club.manager";
    appVersion = @"372";
    vendorIdentifier = [[NSUUID alloc] initWithUUIDString:@"7EB61F70-E56D-46F1-AC3A-84D1B43829D3"];
    
    if (![receipt.bundleIdentifier isEqualToString:bundleIdentifier])
    {
        DTLogDebug(@"Incorrect bundle identifier in receipt");
        return YES;
    }
    
    if (![receipt.appVersion isEqualToString:appVersion])
    {
        DTLogDebug(@"Incorrect bundle version in receipt");
        return YES;
    }
    
    /*
     In iOS, use the value returned by the identifierForVendor property of UIDevice as the computer’s GUID.
     
     To compute the hash, first concatenate the GUID value with the opaque value (the attribute of type 4) and the bundle identifier. Use the raw bytes from the receipt without performing any UTF-8 string interpretation or normalization. Then compute the SHA-1 hash of this concatenated series of bytes.
     */
    uuid_t uuid;
    [vendorIdentifier getUUIDBytes:uuid];
    NSData *vendorData = [NSData dataWithBytes:uuid length:16];
    
    // concacentate data for vendor identifier, opaque value and bundle identifier
    NSMutableData *hashData = [NSMutableData new];
    [hashData appendData:vendorData];
    [hashData appendData:receipt.opaqueValue];
    [hashData appendData:receipt.bundleIdentifierData];
    
    // calculate SHA1
    NSData *hash = [hashData dataWithSHA1Hash];
    
    if (![hash isEqualToData:receipt.SHA1Hash])
    {
        DTLogDebug(@"Incorrect SHA1 hash in receipt");
        
        return YES;
    }
    
    return NO;
}

@end
