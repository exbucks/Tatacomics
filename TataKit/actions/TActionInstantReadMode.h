//
//  TActionInstantReadMode.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstant.h"

typedef NS_ENUM(NSInteger, ReadModeType) {
    ReadModeTypeReadToMe,
    ReadModeTypeReadByMyself,
    ReadModeTypeAutoPlay
};

@interface TActionInstantReadMode : TActionInstant

@property (assign) ReadModeType type;

@end
