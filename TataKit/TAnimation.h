//
//  TAnimation.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTataDelegate.h"

@class SMXMLElement;
@class TSequence;
@class TAction;
@class TLayer;

@interface TAnimation : NSObject

@property (copy) NSString* event;
@property (copy) NSString* state;

@property (weak) TLayer* layer;

@property (assign) BOOL run_executing;

- (id)initWithLayer:(TLayer*)layer;

#pragma mark - TAnimation Methods

- (TAnimation*)clone;
+ (TAnimation*)newAnimation:(TLayer*)layer action:(TAction*)action;

- (void)fixRelationship;

- (BOOL)parseXml:(SMXMLElement*)xml;
- (SMXMLElement*)toXml;

- (int)numberOfSequences;
- (TSequence*)sequenceAtIndex:(int)index;
- (TSequence*)addSequence;
- (void)addSequence:(TSequence*)sequence;
- (void)removeSequence:(int)index;
- (int)numberOfActionsInSequence:(int)sequenceIndex;
- (TAction*)actionAtIndex:(int)sequenceIndex action:(int)actionIndex;
- (void)insertAction:(TAction*)action sequence:(int)sequenceIndex action:(int)actionIndex;
- (void)deleteAction:(int)actionIndex sequence:(int)sequenceIndex;

- (BOOL)isUsingImage:(NSString*)image;
- (BOOL)isUsingSound:(NSString*)sound;

#pragma mark - Launch Methods

- (void)start;
- (void)stop;
- (void)step:(id<TTataDelegate>)delegate time:(long long)time;

#pragma ITimeLineDataSource Interface Methods

- (int)numberOfRows;
- (float)totalDuration;
- (int)numberOfItemsInRow:(int)rowIndex;
- (BOOL)isInstantItem:(int)itemIndex row:(int)rowIndex;
- (float)durationOfItem:(int)itemIndex row:(int)rowIndex;
- (UIColor*)startingColorOfItem:(int)itemIndex row:(int)rowIndex;
- (UIColor*)endingColorOfItem:(int)itemIndex row:(int)rowIndex;
- (UIImage*)iconOfItem:(int)itemIndex row:(int)rowIndex;
- (UIImage*)draggingIconOfItem:(int)itemIndex row:(int)rowIndex;

@end
