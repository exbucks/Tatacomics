//
//  TActionInstant.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstant.h"

@implementation TActionInstant

- (id)init {
    if (self = [super init]) {
        self.isInstant = YES;
        self.duration = 0;
    }
    
    return self;
}

@end
