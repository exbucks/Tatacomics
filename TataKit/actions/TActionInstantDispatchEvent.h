//
//  TActionInstantDispatchEvent.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstant.h"

@interface TActionInstantDispatchEvent : TActionInstant

@property (copy) NSString* actor;
@property (copy) NSString* event;
@property (assign) BOOL recursive;

@end
