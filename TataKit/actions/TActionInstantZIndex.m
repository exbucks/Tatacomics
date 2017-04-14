//
//  TActionInstantZIndex.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantZIndex.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TScene.h"
#import "TActor.h"

@implementation TActionInstantZIndex

- (id)init {
    if (self = [super init]) {
        self.name = @"Z-Index Change";
        self.icon = [UIImage imageNamed:@"icon_action_zindex"];
        
        self.actor = @"";
        self.zIndex = 0;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantZIndex* targetAction = (TActionInstantZIndex*)target;
    targetAction.actor = self.actor;
    targetAction.zIndex = self.zIndex;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantZIndex"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.actor = [TUtil parseStringXElement:[xml childNamed:@"Actor"] default:@""];
        self.zIndex = [TUtil parseIntXElement:[xml childNamed:@"ZIndex"] default:0];
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
        targetActor.zPosition = self.zIndex;
    
    return [super step:delegate time:time];
}

@end
