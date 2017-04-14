//
//  TActionInstantStopAnimation.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstant.h"

@interface TActionInstantStopAnimation : TActionInstant

@property (copy) NSString* actor;
@property (copy) NSString* event;
@property (copy) NSString* state;

@end
