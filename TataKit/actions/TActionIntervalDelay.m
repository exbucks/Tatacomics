//
//  TActionIntervalDelay.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionIntervalDelay.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionIntervalDelay

- (id)init {
    if (self = [super init]) {
        self.name = @"Delay";
        self.startingColor = [UIColor colorWithRed:255/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:255/255.0 green:212/255.0 blue:212/255.0 alpha:1];
        self.icon = [UIImage imageNamed:@"icon_action_delay"];
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionIntervalDelay"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    return YES;
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

#pragma mark - Launch Methods

- (void)reset:(long long)time {
    [super reset:time];
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    
    return [super step:delegate time:time];
}

@end
