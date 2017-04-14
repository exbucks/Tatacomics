//
//  TAction.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TAction.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TAction

- (id)init {
    if (self = [super init]) {
        self.sequence = nil;
        self.name = @"";
        self.isInstant = NO;
        self.duration = 0;
        self.startingColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1];
        self.icon = nil;
        self.iconFrame = CGSizeMake(37, 37);
        
        self.run_startTime = 0;
    }
    
    return self;
}

- (TAction*)clone {
    TAction* action = [[self.class alloc] init];
    [self clone:action];

    return action;
}

- (void)clone:(TAction*)target {
    target.sequence         = self.sequence;
    target.name             = self.name;
    target.isInstant        = self.isInstant;
    target.duration         = self.duration;
    target.startingColor    = self.startingColor;
    target.endingColor      = self.endingColor;
    target.icon             = self.icon;
    target.iconFrame        = self.iconFrame;
}

- (BOOL)parseXml:(SMXMLElement*)xml {
    if (xml == nil)
        return NO;
    
    @try {
        self.duration = [TUtil parseLongXElement:[xml childNamed:@"Duration"] default:0];
        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (UIImage*)iconWithFrame {
    NOT_IMPLEMENTED_METHOD
}

- (void)drawRoundedRectangle:(CGRect)rect corner:(int)cornerRadius context:(CGContextRef)context border:(UIColor*)border top:(UIColor*)top bottom:(UIColor*)bottom {

    // calc gradient color
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0, 1};
    NSArray *colors = @[(__bridge id)top.CGColor, (__bridge id)bottom.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    
    CGPoint topPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint bottomPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));

    // set current context
    UIGraphicsPushContext(context);

    // create rounded path
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextClip(context);
    
    // fill path
    CGContextDrawLinearGradient(context, gradient, topPoint, bottomPoint, 0);
    
    // draw border
    CGContextSetStrokeColorWithColor(context, border.CGColor);
    CGContextStrokePath(context);
    
    // restore current context
    UIGraphicsPopContext();

    // free resources
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (BOOL)isUsingImage:(NSString*)image {
    return NO;
}

- (BOOL)isUsingSound:(NSString*)sound {
    return NO;
}

#pragma mark - Launch Methods

- (void)reset:(long long)time {
    self.run_startTime = time;
}

- (void)complete {
    ABSTRACT_METHOD
}

// execute action for every frame
// if action is finished, return true
- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    if (self.isInstant || self.run_startTime + self.duration <= time)
        return YES;
    return NO;
}

@end
