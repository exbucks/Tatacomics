//
//  TScene.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLayer.h"

@class TImageActor;
@class TTextActor;
@class TAvatarActor;

@interface TScene : TLayer

@property (strong) UIColor*             backgroundColor;
@property (assign) BOOL                 touchIndication;
@property (assign) BOOL                 prevButtonVisible;
@property (assign) BOOL                 nextButtonVisible;
@property (copy) NSString*              backgroundMusic;
@property (assign) int                  backgroundMusicVolume;

@property (weak) id<TTataDelegate>      run_delegate;
@property (assign) BOOL                 run_running;
@property (assign) CGAffineTransform    run_matrix;
@property (strong) NSArray*             run_extraActors;

- (id)initWithDocument:(TDocument*)document name:(NSString*)name;
- (void)prepareResources;

- (UIImage*)thumbnailImage;
- (TImageActor*)pushImage:(NSString*)image position:(CGPoint)position;
- (TTextActor*)pushText:(NSString*)text rect:(CGRect)rect;
- (TAvatarActor*)pushAvatar:(CGRect)rect;

@end
