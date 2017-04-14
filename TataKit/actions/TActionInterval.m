//
//  TActionInterval.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInterval.h"

@implementation TActionInterval

- (id)init {
    if (self = [super init]) {
        self.isInstant = NO;
        self.duration = 1000;
    }
    
    return self;
}

@end
