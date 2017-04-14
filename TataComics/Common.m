//
//  Common.m
//  TataComics
//
//  Created by Albert on 12/2/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "Common.h"
#import <CommonCrypto/CommonDigest.h>
#import <Social/Social.h>
#import "AppSettings.h"

@implementation Common

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if (isPhone)
        return;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

+ (void)makeInformationView:(UIView*)container info:(NSArray*)info fontSize:(int)fontSize
{
    UIView* prevRow = nil;
    for (id one in info) {
        NSString* key = [one objectAtIndex:0];
        NSString* value = [one objectAtIndex:1];

        UILabel* caption = [[UILabel alloc] init];
        caption.text = NSLocalizedString(key, @"");;
        caption.numberOfLines = 0;
        caption.textAlignment = NSTextAlignmentRight;
        caption.textColor = [UIColor lightGrayColor];
        caption.font = [UIFont systemFontOfSize:fontSize];
        caption.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel* data = [[UILabel alloc] init];
        data.text = value;
        data.numberOfLines = 0;
        data.textColor = [UIColor darkGrayColor];
        data.font = [UIFont systemFontOfSize:fontSize];
        data.translatesAutoresizingMaskIntoConstraints = NO;
        
        UIView* row = [[UIView alloc] init];
        row.translatesAutoresizingMaskIntoConstraints = NO;

        [row addSubview:caption];
        [row addSubview:data];
        [container addSubview:row];

        [row addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[caption(120)]-[data]|"
                                                                    options:NSLayoutFormatDirectionLeftToRight
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(caption, data)]];
        [row addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[caption(>=21)]-(>=0)-|"
                                                                    options:NSLayoutFormatDirectionLeftToRight
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(caption)]];
        [row addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[data(>=21)]-(>=0)-|"
                                                                    options:NSLayoutFormatDirectionLeftToRight
                                                                    metrics:nil
                                                                      views:NSDictionaryOfVariableBindings(data)]];
        
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[row]|"
                                                                          options:NSLayoutFormatDirectionLeftToRight
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(row)]];
        if (prevRow == nil) {
            [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[row]"
                                                                              options:NSLayoutFormatDirectionLeftToRight
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(row)]];
        } else {
            [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prevRow][row]"
                                                                              options:NSLayoutFormatDirectionLeftToRight
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(prevRow, row)]];
        }
        
        prevRow = row;
    }

    if (prevRow != nil) {
        [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[prevRow]|"
                                                                          options:NSLayoutFormatDirectionLeftToRight
                                                                          metrics:nil
                                                                            views:NSDictionaryOfVariableBindings(prevRow)]];
    }
}

#pragma mark - Waiting View

+ (void)showWaitingViewWithMessage:(NSString*)message container:(UIView*)container
{
    
    UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    [progressInd startAnimating];
    progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    
    UILabel *waitingLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 140, 20)];
    waitingLable.text = message;
    waitingLable.textColor = [UIColor whiteColor];
    waitingLable.font = [UIFont systemFontOfSize:16];
    waitingLable.backgroundColor = [UIColor clearColor];
    
//    CGRect frame = [container frame];
//    frame = CGRectMake((frame.size.width - 200) / 2, (frame.size.height - 40) / 2, 200, 40);
//    UIView *theView = [[UIView alloc] initWithFrame:frame];
    UIView *theView = [[UIView alloc] init];
    theView.layer.cornerRadius = 7;
    theView.backgroundColor = [UIColor blackColor];
    theView.alpha = 0.6;
    [theView addSubview:progressInd];
    [theView addSubview:waitingLable];
    
//    UIView *pageView = [[UIView alloc] initWithFrame:container.frame];
    UIView *pageView = [[UIView alloc] init];
    pageView.backgroundColor = [UIColor clearColor];
    pageView.tag = WAINTING_VIEW_TAG;
    [pageView addSubview:theView];

    theView.translatesAutoresizingMaskIntoConstraints = NO;
    [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[theView(200)]"
                                                                     options:NSLayoutFormatDirectionLeftToRight
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(theView)]];
    [pageView addConstraint:[NSLayoutConstraint constraintWithItem:theView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:pageView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.f constant:0.f]];
    [pageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[theView(40)]"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(theView)]];
    [pageView addConstraint:[NSLayoutConstraint constraintWithItem:theView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:pageView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.f constant:0.f]];
    
    [container addSubview:pageView];
    [container bringSubviewToFront:pageView];

    pageView.translatesAutoresizingMaskIntoConstraints = NO;
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageView]|"
                                                                     options:NSLayoutFormatDirectionLeftToRight
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(pageView)]];
    [container addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageView]|"
                                                                     options:NSLayoutFormatDirectionLeftToRight
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(pageView)]];
}

+ (void)removeWaitingViewFromContainer:(UIView*)container
{
    UIView *v = [container viewWithTag:WAINTING_VIEW_TAG];
    if(v) [v removeFromSuperview];
}

+ (BOOL)isShowingWaitingViewInContainer:(UIView*)container
{
    return [container viewWithTag:WAINTING_VIEW_TAG] != nil;
}

#pragma mark - Crypto

+ (NSString*)sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, data.length, digest);

    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];

    return output;
}

+ (NSString*)md5:(NSString*)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

#pragma mark - Share Social Network Service

+ (void)shareOnFacebook:(UIViewController*)viewController
{
    if (NSClassFromString(@"SLComposeViewController") != nil)
    {
        SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        if (fbSheet != nil) {
            // initial message contents
            NSString* message = NSLocalizedString(@"ShareMessage", @"");
            message = [message stringByReplacingOccurrencesOfString:@"{APPSTORE_URL}" withString:APPSTORE_URL];
            message = [message stringByReplacingOccurrencesOfString:@"{GOOGLEPLAY_URL}" withString:GOOGLEPLAY_URL];

            [fbSheet setInitialText:message];
            [viewController presentViewController:fbSheet animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Facebook Accounts"
                                                                message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't use Facebook Sharing with your device and OS version."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

+ (void)shareOnTwitter:(UIViewController*)viewController
{
    if (NSClassFromString(@"SLComposeViewController") != nil)
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        if (tweetSheet != nil) {
            // initial message contents
            NSString* message = NSLocalizedString(@"ShareMessage", @"");
            message = [message stringByReplacingOccurrencesOfString:@"{APPSTORE_URL}" withString:APPSTORE_URL];
            message = [message stringByReplacingOccurrencesOfString:@"{GOOGLEPLAY_URL}" withString:GOOGLEPLAY_URL];
            
            [tweetSheet setInitialText:message];
            [viewController presentViewController:tweetSheet animated:YES completion:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts"
                                                                message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                            message:@"You can't use Twitter Sharing with your device and OS version."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
    
}

+ (void)shareOnWhatsapp:(UIViewController*)viewController
{
    NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@", NSLocalizedString(@"WhatsappMessage", @"TataComics")]];
    if ([[UIApplication sharedApplication] canOpenURL:whatsappURL]){
        
        // open whatsapp
        [[UIApplication sharedApplication] openURL: whatsappURL];
        
    } else {
        UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                         message:NSLocalizedString(@"NoWhatsApp", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                               otherButtonTitles: nil];
        [alert show];
    }
}

@end
