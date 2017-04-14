//
//  Common.h
//  TataComics
//
//  Created by Albert on 12/2/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *  System Versioning Preprocessor Macros
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 * Color format for 0x885533
 */
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define isPhone         ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define isPhone568      (isPhone && [UIScreen mainScreen].bounds.size.height == 568)

/*
 * Internal Settings
 */
#define WAINTING_VIEW_TAG		2270

@interface Common : NSObject

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController;

+ (void)makeInformationView:(UIView*)container info:(NSArray*)info fontSize:(int)fontSize;

+ (void)showWaitingViewWithMessage:(NSString*)message container:(UIView*)container;
+ (void)removeWaitingViewFromContainer:(UIView*)container;
+ (BOOL)isShowingWaitingViewInContainer:(UIView*)container;

+ (NSString*)sha1:(NSString*)input;
+ (NSString*)md5:(NSString*)input;

+ (void)shareOnFacebook:(UIViewController*)viewController;
+ (void)shareOnTwitter:(UIViewController*)viewController;
+ (void)shareOnWhatsapp:(UIViewController*)viewController;

@end
