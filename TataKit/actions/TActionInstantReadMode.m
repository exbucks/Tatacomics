//
//  TActionInstantReadMode.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstantReadMode.h"
#import "SMXMLDocument.h"
#import "TUtil.h"

@implementation TActionInstantReadMode

- (id)init {
    if (self = [super init]) {
        self.name = @"Read Mode";
        self.icon = [UIImage imageNamed:@"icon_action_readmode"];
        
        self.type = ReadModeTypeReadToMe;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionInstantReadMode* targetAction = (TActionInstantReadMode*)target;
    targetAction.type = self.type;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionInstantReadMode"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        self.type = [TUtil parseIntXElement:[xml childNamed:@"Type"] default:ReadModeTypeReadToMe];
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
    
    return [super step:delegate time:time];
}

@end
