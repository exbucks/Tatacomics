//
//  TSoundEmulator.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TSoundEmulator.h"
#import "TLibraryManager.h"

@implementation TSoundEmulator {
    __weak TLibraryManager* libraryManager;

    NSString*           bgmFilePath;
    int                 bgmVolume;
    TSoundTask*         bgmTask;
    
    NSMutableArray*     effectTasks;
    NSMutableArray*     voiceTasks;
}

- (id)initWithLibraryManager:(TLibraryManager*)libManager {
    if (self = [super init]) {
        libraryManager = libManager;
        
        bgmFilePath = @"";
        bgmVolume = 100;
        bgmTask = nil;
        
        effectTasks = [[NSMutableArray alloc] init];
        voiceTasks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)playEffect:(NSString*)fileName volume:(int)volume loop:(BOOL)loop {
    @synchronized (effectTasks) {
        NSString* filePath = [libraryManager soundFilePath:[libraryManager soundIndex:fileName]];
        if (![filePath isEqualToString:@""]) {
            @try {
                TSoundTask* task = [[TSoundTask alloc] initWithFilePath:filePath volume:volume loop:loop stoppedHandler:^(TSoundTask* task) {
                    @synchronized (effectTasks) {
                        [effectTasks removeObject:task];
                    }
                }];
                [effectTasks addObject:task];
                [task play];
            } @catch (NSException* e) {
                NSLog(@"Error: %@", e);
            }
        }
    }
}

- (void)stopEffect:(NSString*)fileName {
    @synchronized (effectTasks) {
        for (TSoundTask* task in effectTasks) {
            if ([[task.filePath lastPathComponent] isEqualToString:fileName]) {
                [task stop];
                [effectTasks removeObject:task];
            }
        }
    }
}

- (void)stopAllEffects {
    @synchronized (effectTasks) {
        for (TSoundTask* task in effectTasks) {
            [task stop];
        }
        
        [effectTasks removeAllObjects];
    }
}

- (void)playVoice:(NSString*)fileName volume:(int)volume loop:(BOOL)loop {
    @synchronized (voiceTasks) {
        NSString* filePath = [libraryManager soundFilePath:[libraryManager soundIndex:fileName]];
        if (![filePath isEqualToString:@""]) {
            @try {
                TSoundTask* task = [[TSoundTask alloc] initWithFilePath:filePath volume:volume loop:loop stoppedHandler:^(TSoundTask* task) {
                    @synchronized (voiceTasks) {
                        [voiceTasks removeObject:task];
                    }
                }];
                [voiceTasks addObject:task];
                [task play];
            } @catch (NSException* e) {
                NSLog(@"Error: %@", e);
            }
        }
    }
}

- (void)stopVoice:(NSString*)fileName {
    @synchronized (voiceTasks) {
        for (TSoundTask* task in voiceTasks) {
            if ([[task.filePath lastPathComponent] isEqualToString:fileName]) {
                [voiceTasks removeObject:task];
                [task stop];
            }
        }
    }
}

- (void)stopAllVoices {
    @synchronized (voiceTasks) {
        for (TSoundTask* task in voiceTasks)
            [task stop];
        
        [voiceTasks removeAllObjects];
    }
}

- (void)playBGM:(NSString*)fileName volume:(int)volume {
    if (bgmTask != nil) {
        if ([[bgmTask.filePath lastPathComponent] isEqualToString:fileName]) {
            // case when only volume was changed
            if (bgmTask.volume != volume) {
                bgmVolume = volume;
                [bgmTask changeVolume:volume];
            }
            
            return;
        }
        
        [bgmTask stop];
        bgmTask = nil;
    }

    bgmFilePath = [libraryManager soundFilePath:[libraryManager soundIndex:fileName]];
    bgmVolume = volume;
    if (![bgmFilePath isEqualToString:@""]) {
        @try {
            bgmTask = [[TSoundTask alloc] initWithFilePath:bgmFilePath volume:volume loop:YES stoppedHandler:^(TSoundTask* task) {
                bgmTask = nil;
            }];
            [bgmTask play];
        } @catch (NSException* e) {
            NSLog(@"Error: %@", e);
            bgmTask = nil;
        }
    }
}

- (void)playBGM {
    if (bgmTask != nil)
        return;
    
    if (![bgmFilePath isEqualToString:@""]) {
        @try {
            bgmTask = [[TSoundTask alloc] initWithFilePath:bgmFilePath volume:bgmVolume loop:YES stoppedHandler:^(TSoundTask* task) {
                bgmTask = nil;
            }];
            [bgmTask play];
        } @catch (NSException* e) {
            NSLog(@"Error: %@", e);
            bgmTask = nil;
        }
    }
}

- (void)stopBGM {
    if (bgmTask != nil) {
        [bgmTask stop];
        bgmTask = nil;
    }
}

- (void)stopAllSounds {
    [self stopAllSoundsOfBGM:YES effect:YES voice:YES];
}

- (void)stopAllSoundsOfBGM:(BOOL)bgm effect:(BOOL)effect voice:(BOOL)voice {
    if (bgm)
        [self stopBGM];
    if (effect)
        [self stopAllEffects];
    if (voice)
        [self stopAllVoices];
}

@end

@implementation TSoundTask {
    AVAudioPlayer* audioPlayer;
    void (^playbackStoppedHandler)(TSoundTask*);
}

- (id)initWithFilePath:(NSString*)filePath volume:(int)volume loop:(BOOL)loop stoppedHandler:(void (^)(TSoundTask*))stoppedHandler {
    if (self = [super init]) {
        self.filePath = filePath;
        self.volume = volume;

        playbackStoppedHandler = stoppedHandler;
        
        NSError *error = nil;
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        if (audioPlayer != nil) {
            audioPlayer.delegate = self;
            audioPlayer.volume = volume / 100.0;
            if (loop)
                audioPlayer.numberOfLoops = -1;
            [audioPlayer prepareToPlay];
        } else {
            NSLog(@"AudioPlayer did not load properly: %@", [error description]);
        }
    }
    
    return self;
}

- (void)play {
    if (audioPlayer != nil && !audioPlayer.isPlaying) {
        [audioPlayer play];

        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
    }
}

- (void)pause {
    if (audioPlayer != nil && audioPlayer.isPlaying)
        [audioPlayer pause];
}

- (void)stop {
    if (audioPlayer != nil) {
        audioPlayer.delegate = nil;
        [audioPlayer stop];
        audioPlayer = nil;
    }
}

- (void)changeVolume:(int)volume {
    self.volume = volume;
    audioPlayer.volume = volume / 100.0;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (audioPlayer != nil) {
        if (audioPlayer.isPlaying)
            [audioPlayer stop];
        audioPlayer = nil;
    }
    
    if (playbackStoppedHandler != nil) {
        playbackStoppedHandler(self);
    }
}

@end