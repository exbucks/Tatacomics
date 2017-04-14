//
//  TActionInstantChangeBGM.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantChangeBGM.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionInstantChangeBGM

- (id)init {
    if (self = [super init]) {
        self.name = @"Change BG Music";
        self.icon = [UIImage imageNamed:@"icon_action_changebgm"];
        
        self.sound = @"";
        self.volume = 100;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantChangeBGM* targetAction = (TActionInstantChangeBGM*)target;
    targetAction.sound = self.sound;
    targetAction.volume = self.volume;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantChangeBGM"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.sound = [TUtil parseStringXElement:[xml childNamed:@"Sound"] default:@""];
        self.volume = [TUtil parseIntXElement:[xml childNamed:@"Volume"] default:100];
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

    [delegate playBGM:self.sound volume:self.volume];
    
    return [super step:delegate time:time];
}

@end
