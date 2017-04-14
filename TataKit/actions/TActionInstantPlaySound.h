//
//  TActionInstantPlaySound.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstant.h"

@interface TActionInstantPlaySound : TActionInstant

@property (copy) NSString* sound;
@property (assign) int volume;
@property (assign) BOOL loop;

@end
