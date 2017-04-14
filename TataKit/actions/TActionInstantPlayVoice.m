//
//  TActionInstantPlayVoice.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantPlayVoice.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionInstantPlayVoice

- (id)init {
    if (self = [super init]) {
        self.name = @"Play Voice";
        self.icon = [UIImage imageNamed:@"icon_action_playvoice"];
        
        self.sound = @"";
        self.volume = 100;
        self.loop = NO;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantPlayVoice* targetAction = (TActionInstantPlayVoice*)target;
    targetAction.sound = self.sound;
    targetAction.volume = self.volume;
    targetAction.loop = self.loop;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantPlayVoice"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.sound = [TUtil parseStringXElement:[xml childNamed:@"Sound"] default:@""];
        self.volume = [TUtil parseIntXElement:[xml childNamed:@"Volume"] default:100];
        self.loop = [TUtil parseBoolXElement:[xml childNamed:@"Loop"] default:NO];
        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (BOOL)isUsingSound:(NSString *)sound {
    return [self.sound isEqualToString:sound];
}

#pragma mark - Launch Methods

- (void)reset:(long long)time {
    [super reset:time];
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    
    [delegate playVoice:self.sound volume:self.volume loop:self.loop];
    
    return [super step:delegate time:time];
}

@end
