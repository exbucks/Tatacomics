//
//  TActionInstantMakeAvatar.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantMakeAvatar.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionInstantMakeAvatar

- (id)init {
    if (self = [super init]) {
        self.name = @"Make Avatar";
        self.icon = [UIImage imageNamed:@"icon_action_makeavatar"];
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantMakeAvatar"])
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
    
    [delegate makeAvatar];
    
    return [super step:delegate time:time];
}

@end
