//
//  TStopwatch.m
//  TataViewer
//
//  Created by Lucas Opel on 18/10/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TStopwatch.h"
#import <QuartzCore/QuartzCore.h>

@implementation TStopwatch {
}

- (id)init {
    if (self = [super init]) {
        self.isRunning = NO;
        self.startedTime = 0;
    }
    
    return self;
}

- (void)start {
    self.isRunning = YES;
    self.startedTime = CACurrentMediaTime();
}

- (void)stop {
    self.isRunning = NO;
}

- (void)restart {
    self.startedTime = CACurrentMediaTime();
}

- (long long)elapsedMilliseconds {
    CFTimeInterval s = CACurrentMediaTime() - self.startedTime;
    return s * 1000;
}

@end
