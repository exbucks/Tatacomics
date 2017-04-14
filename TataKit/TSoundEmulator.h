//
//  TSoundEmulator.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class TLibraryManager;

@interface TSoundEmulator : NSObject

- (id)initWithLibraryManager:(TLibraryManager*)libManager;

- (void)playEffect:(NSString*)fileName volume:(int)volume loop:(BOOL)loop;
- (void)stopEffect:(NSString*)fileName;
- (void)stopAllEffects;

- (void)playVoice:(NSString*)fileName volume:(int)volume loop:(BOOL)loop;
- (void)stopVoice:(NSString*)fileName;
- (void)stopAllVoices;

- (void)playBGM:(NSString*)fileName volume:(int)volume;
- (void)playBGM;
- (void)stopBGM;

- (void)stopAllSounds;
- (void)stopAllSoundsOfBGM:(BOOL)bgm effect:(BOOL)effect voice:(BOOL)voice;

@end

@interface TSoundTask : NSObject <AVAudioPlayerDelegate>

@property (copy) NSString* filePath;
@property (assign) int volume;

- (id)initWithFilePath:(NSString*)filePath volume:(int)volume loop:(BOOL)loop stoppedHandler:(void (^)(TSoundTask*))stoppedHandler;

- (void)play;
- (void)pause;
- (void)stop;
- (void)changeVolume:(int)volume;

@end
