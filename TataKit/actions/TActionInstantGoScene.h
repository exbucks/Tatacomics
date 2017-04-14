//
//  TActionInstantGoScene.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionInstant.h"

typedef NS_ENUM(NSInteger, GoSceneType) {
    GoSceneTypePrevious,
    GoSceneTypeNext,
    GoSceneTypeCover,
    GoSceneTypeSpecific
};

@interface TActionInstantGoScene : TActionInstant

@property (assign) GoSceneType type;
@property (copy) NSString* scene;

@end
