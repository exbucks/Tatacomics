//
//  TActor.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TLayer.h"

@interface TActor : TLayer

@property (assign) CGPoint              location;
@property (assign) CGSize               scale;
@property (assign) CGSize               skew;
@property (assign) float                rotation;

@property (assign) BOOL                 draggable;
@property (assign) BOOL                 acceleratorSensibility;
@property (assign) BOOL                 autoInteractionBound;
@property (assign) CGRect               interactionBound;

@property (assign) BOOL                 puzzle;
@property (assign) CGRect               puzzleArea;

//@property (assign) CGAffineTransform    matrix;
@property (strong) TActor*              backupActor;

@property (assign) float                run_xVelocity;
@property (assign) float                run_yVelocity;

- (id)initWithDocument:(TDocument*)document x:(float)x y:(float)y parent:(TLayer*)parent name:(NSString*)name;

- (void)createBackup;
- (void)deleteBackup;

- (float)rotationOnScreen;
- (NSArray*)interactionBoundOnScreen;
- (NSArray*)puzzleAreaOnScreen;

- (BOOL)isMoving;

@end
