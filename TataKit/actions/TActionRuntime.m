//
//  TActionRuntime.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionRuntime.h"

@implementation TActionRuntime {
    void (^runtimeCode)(float);
}

- (id)init {
    if (self = [super init]) {
        self.isInstant = NO;
        self.duration = 0;
        
        runtimeCode = nil;
    }
    
    return self;
}

- (id)initWithDuration:(int)duration runtimeCode:(void (^)(float))code {
    if (self = [super init]) {
        self.isInstant = NO;
        self.duration = duration;
        
        runtimeCode = code;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionRuntime* targetAction = (TActionRuntime*)target;
    targetAction.isInstant = self.isInstant;
    targetAction.duration = self.duration;
    [targetAction setRuntimeCode:runtimeCode];
    
}

- (void)setRuntimeCode:(void (^)(float))code {
    runtimeCode = code;
}

- (void)reset:(long long)time {
    [super reset:time];
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    float elapsed = time - self.run_startTime;
    if (elapsed > self.duration)
        elapsed = self.duration;
    
    float percent = self.duration > 0 ? elapsed / self.duration : 1;
    if (runtimeCode != nil)
        runtimeCode(percent);
    
    return [super step:delegate time:time];
}

@end
