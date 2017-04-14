//
//  IAPHelper.m
//  In App Rage
//
//  Created by Ray Wenderlich on 9/5/12.
//  Copyright (c) 2012 Razeware LLC. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
NSString *const IAPHelperProductRestoredNotification = @"IAPHelperProductRestoredNotification";
NSString *const IAPHelperProductFailedNotification = @"IAPHelperProductFailedNotification";
NSString *const IAPHelperProductRestoreFinishedNotification = @"IAPHelperProductRestoreFinishedNotification";

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    
    BOOL needSKPaymentObserver;
}

+ (IAPHelper*)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static IAPHelper* _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init {
    if (self = [super init]) {
        // need to observer to SKPaymentQueue
        needSKPaymentObserver = YES;
    }
    
    return self;
}

- (SKPaymentQueue*)paymentQueue {
    if (needSKPaymentObserver) {
        // Add self as transaction observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // don't need to add observer again
        needSKPaymentObserver = NO;
    }
    
    return [SKPaymentQueue defaultQueue];
}

- (void)requestProducts:(NSSet*)productIdentifiers completionHandler:(RequestProductsCompletionHandler)completionHandler {
    // save completion handler
    _completionHandler = [completionHandler copy];
    
    // create request
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[self paymentQueue] addPayment:payment];
}

- (void)restoreCompletedTransactions {
    [[self paymentQueue] restoreCompletedTransactions];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
    
}

#pragma mark SKPaymentTransactionOBserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreFinishedNotification object:nil userInfo:nil];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoreFinishedNotification object:nil userInfo:nil];

    if (error.code != SKErrorPaymentCancelled) {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                               otherButtonTitles: nil];
        [alert show];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSString* productIdentifier = transaction.payment.productIdentifier;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if (transaction.originalTransaction == nil)
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredNotification object:productIdentifier userInfo:nil];

    [[self paymentQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSString* productIdentifier = transaction. originalTransaction.payment.productIdentifier;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductRestoredNotification object:productIdentifier userInfo:nil];

    [[self paymentQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:transaction.error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                               otherButtonTitles: nil];
        [alert show];
    }
    
    NSString* productIdentifier = transaction.payment.productIdentifier;
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductFailedNotification object:productIdentifier userInfo:nil];

    [[self paymentQueue] finishTransaction: transaction];
}

@end