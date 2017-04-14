//
//  TActionInstantDispatchEvent.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantDispatchEvent.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TScene.h"
#import "TActor.h"

@implementation TActionInstantDispatchEvent

- (id)init {
    if (self = [super init]) {
        self.name = @"Dispatch Event";
        self.icon = [UIImage imageNamed:@"icon_action_dispatch"];
        
        self.actor = @"";
        self.event = @"";
        self.recursive = YES;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantDispatchEvent* targetAction = (TActionInstantDispatchEvent*)target;
    targetAction.actor = self.actor;
    targetAction.event = self.event;
    targetAction.recursive = self.recursive;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantDispatchEvent"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.actor = [TUtil parseStringXElement:[xml childNamed:@"Actor"] default:@""];
        self.event = [TUtil parseStringXElement:[xml childNamed:@"Event"] default:@""];
        self.recursive = [TUtil parseBoolXElement:[xml childNamed:@"Recursive"] default:YES];
        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

#pragma mark - Launch Methods

- (void)reset:(long long)time {
    [super reset:time];
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    
    TActor* targetActor = (TActor*)[[delegate currentScene] findLayer:self.actor];
    if (targetActor != nil)
        [targetActor fireEvent:self.event recursive:self.recursive];
    
    return [super step:delegate time:time];
}

@end
