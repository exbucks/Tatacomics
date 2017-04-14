//
//  TActionInstantStopAllSounds.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantStopAllSounds.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionInstantStopAllSounds

- (id)init {
    if (self = [super init]) {
        self.name = @"Stop All Sounds";
        self.icon = [UIImage imageNamed:@"icon_action_stopallsounds"];
        
        self.bgm = YES;
        self.effect = YES;
        self.voice = YES;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantStopAllSounds* targetAction = (TActionInstantStopAllSounds*)target;
    targetAction.bgm = self.bgm;
    targetAction.effect = self.effect;
    targetAction.voice = self.voice;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantStopAllSounds"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.bgm = [TUtil parseBoolXElement:[xml childNamed:@"BGM"] default:YES];
        self.effect = [TUtil parseBoolXElement:[xml childNamed:@"Effect"] default:YES];
        self.voice = [TUtil parseBoolXElement:[xml childNamed:@"Voice"] default:YES];
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
    
    [delegate stopAllSoundsOfBGM:self.bgm effect:self.effect voice:self.voice];
    
    return [super step:delegate time:time];
}

@end
