//
//  TAction.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTataDelegate.h"

@class TSequence;
@class SMXMLElement;

@interface TAction : NSObject

@property (weak) TSequence*     sequence;
@property (copy) NSString*      name;
@property (assign) BOOL         isInstant;
@property (assign) long long    duration;           // milliseconds
@property (strong) UIColor*     startingColor;
@property (strong) UIColor*     endingColor;
@property (strong) UIImage*     icon;
@property (assign) CGSize       iconFrame;

@property (assign) long long    run_startTime;

- (TAction*)clone;
- (void)clone:(TAction*)target;

- (BOOL)parseXml:(SMXMLElement*)xml;
- (SMXMLElement*)toXml;

- (UIImage*)iconWithFrame;
- (void)drawRoundedRectangle:(CGRect)rect corner:(int)cornerRadius context:(CGContextRef)context border:(UIColor*)border top:(UIColor*)top bottom:(UIColor*)bottom;

- (BOOL)isUsingImage:(NSString*)image;
- (BOOL)isUsingSound:(NSString*)sound;

#pragma mark - Launch Methods

- (void)reset:(long long)time;

- (void)complete;

// execute action for every frame
// if action is finished, return true
- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time;

@end
