//
//  TActionInstantClearAvatar.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantClearAvatar.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionInstantClearAvatar

- (id)init {
    if (self = [super init]) {
        self.name = @"Clear Avatar";
        self.icon = [UIImage imageNamed:@"icon_action_clearavatar"];
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantClearAvatar"])
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
    
    [delegate clearAvatar];
    
    return [super step:delegate time:time];
}

@end
