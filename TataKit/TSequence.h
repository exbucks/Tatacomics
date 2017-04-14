//
//  TSequence.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTataDelegate.h"

@class SMXMLElement;
@class TAnimation;
@class TAction;

@interface TSequence : NSObject

@property (weak) TAnimation*    animation;
@property (assign) int          repeat;

@property (assign) int          run_repeated;
@property (assign) int          run_currentAction;

- (TSequence*)clone;
- (void)fixRelationship;

- (BOOL)parseXml:(SMXMLElement*)xml;
- (SMXMLElement*)toXml;

- (int)numberOfActions;
- (void)addAction:(TAction*)action;
- (void)insertAction:(TAction*)action index:(int)index;
- (void)deleteAction:(int)index;

- (float)totalDuration;
- (BOOL)isInstantAction:(int)index;
- (long long)durationOfAction:(int)index;
- (TAction*)actionAtIndex:(int)index;
- (UIColor*)startingColorOfAction:(int)index;
- (UIColor*)endingColorOfAction:(int)index;
- (UIImage*)iconOfAction:(int)index;
- (UIImage*)draggingIconOfAction:(int)index;

- (BOOL)isUsingImage:(NSString*)image;
- (BOOL)isUsingSound:(NSString*)sound;

#pragma mark - Launch Methods

- (void)start;

// Execute sequence for every frame
// if sequence is progressing then return true
// if sequence is donen and finished then return false
- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time;

- (void)changeCurrentAction:(int)index time:(long long)time;

@end
