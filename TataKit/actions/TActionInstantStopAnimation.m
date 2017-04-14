//
//  TActionInstantStopAnimation.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantStopAnimation.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TScene.h"
#import "TActor.h"

@implementation TActionInstantStopAnimation

- (id)init {
    if (self = [super init]) {
        self.name = @"Stop Animation";
        self.icon = [UIImage imageNamed:@"icon_action_stop"];
        
        self.actor = @"";
        self.event = @"";
        self.state = @"";
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantStopAnimation* targetAction = (TActionInstantStopAnimation*)target;
    targetAction.actor = self.actor;
    targetAction.event = self.event;
    targetAction.state = self.state;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantStopAnimation"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.actor = [TUtil parseStringXElement:[xml childNamed:@"Actor"] default:@""];
        self.event = [TUtil parseStringXElement:[xml childNamed:@"Event"] default:@""];
        self.state = [TUtil parseStringXElement:[xml childNamed:@"State"] default:@""];
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
        [targetActor stopAnimation:self.event state:self.state];
    
    return [super step:delegate time:time];
}

@end
