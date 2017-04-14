//
//  TAvatarActor.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TActor.h"

@interface TAvatarActor : TActor

@property (assign) CGSize       boxSize;

- (id)initWithDocument:(TDocument*)document position:(CGPoint)position box:(CGSize)box parent:(TLayer*)parent name:(NSString*)name;

@end
