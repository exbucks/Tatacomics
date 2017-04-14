//
//  TActionRuntime.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TAction.h"

@interface TActionRuntime : TAction

- (id)initWithDuration:(int)duration runtimeCode:(void (^)(float))code;

- (void)setRuntimeCode:(void (^)(float))code;

@end
