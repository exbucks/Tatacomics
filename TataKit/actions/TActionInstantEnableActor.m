//
//  TActionInstantEnableActor.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantEnableActor.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TScene.h"
#import "TActor.h"

@implementation TActionInstantEnableActor

- (id)init {
    if (self = [super init]) {
        self.name = @"Ena./Dis. Actor";
        self.icon = [UIImage imageNamed:@"icon_action_enableactor"];
        
        self.actor = @"";
        self.enabled = NO;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantEnableActor* targetAction = (TActionInstantEnableActor*)target;
    targetAction.actor = self.actor;
    targetAction.enabled = self.enabled;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantEnableActor"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.actor = [TUtil parseStringXElement:[xml childNamed:@"Actor"] default:@""];
        self.enabled = [TUtil parseBoolXElement:[xml childNamed:@"Enabled"] default:NO];
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
        targetActor.run_enabled = self.enabled;
    
    return [super step:delegate time:time];
}

@end
