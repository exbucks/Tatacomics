//
//  TTataDelegate.h
//  TataViewer
//
//  Created by Albert Li on 10/22/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "TStopwatch.h"

@class TScene;

@protocol TTataDelegate <NSObject>

@required

@property (nonatomic, assign)   BOOL                textOn;
@property (nonatomic, assign)   CMAcceleration      acceleration;
@property (nonatomic, strong)   TStopwatch*         accelerationWatch;

- (TScene*)currentScene;

- (void)gotoPrevScene;
- (void)gotoNextScene;
- (void)gotoCoverScene;
- (void)gotoSpecificScene:(NSString*)sceneName;

- (void)makeAvatar;
- (void)clearAvatar;

- (void)playEffect:(NSString*)fileName volume:(int)volume loop:(BOOL)loop;
- (void)stopEffect:(NSString*)fileName;
- (void)toggleEffectByAuto:(BOOL)autoToggle on:(BOOL)on;
- (void)stopAllEffects;

- (void)playVoice:(NSString*)fileName volume:(int)volume loop:(BOOL)loop;
- (void)stopVoice:(NSString*)fileName;
- (void)toggleVoiceByAuto:(BOOL)autoToggle on:(BOOL)on;
- (void)stopAllVoices;

- (void)playBGM;
- (void)playBGM:(NSString*)fileName volume:(int)volume;
- (void)toggleBGMByAuto:(BOOL)autoToggle on:(BOOL)on;
- (void)stopBGM;

- (void)stopAllSoundsOfBGM:(BOOL)bgm effect:(BOOL)effect voice:(BOOL)voice;

- (void)toggleTextByAuto:(BOOL)autoToggle on:(BOOL)on;

@end
