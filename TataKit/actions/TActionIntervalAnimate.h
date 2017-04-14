//
//  TActionIntervalAnimate.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInterval.h"

@class TAnimateFrame;

@interface TActionIntervalAnimate : TActionInterval

@property (strong) NSMutableArray* frames;

- (void)prepareResources;

@end

@interface TAnimateFrame : NSObject

@property (copy) NSString* image;
@property (assign) long long duration;

@end