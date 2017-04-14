//
//  TActionInstantGoScene.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantGoScene.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionInstantGoScene

- (id)init {
    if (self = [super init]) {
        self.name = @"Go to Scene";
        self.icon = [UIImage imageNamed:@"icon_action_gotoscene"];
        
        self.type = GoSceneTypeSpecific;
        self.scene = @"";
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantGoScene* targetAction = (TActionInstantGoScene*)target;
    targetAction.type = self.type;
    targetAction.scene = self.scene;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantGoScene"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.type = [TUtil parseIntXElement:[xml childNamed:@"Type"] default:GoSceneTypeSpecific];
        self.scene = [TUtil parseStringXElement:[xml childNamed:@"Scene"] default:@""];
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
    
    switch (self.type) {
        case GoSceneTypePrevious:
            [delegate gotoPrevScene];
            break;
        case GoSceneTypeNext:
            [delegate gotoNextScene];
            break;
        case GoSceneTypeCover:
            [delegate gotoCoverScene];
            break;
        case GoSceneTypeSpecific:
            [delegate gotoSpecificScene:self.scene];
            break;
    }
    
    return [super step:delegate time:time];
}

@end
