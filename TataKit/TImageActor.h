//
//  TImageActor.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TActor.h"

@interface TImageActor : TActor

@property (copy) NSString* image;

- (id)initWithDocument:(TDocument*)document imageWithName:(NSString*)image x:(float)x y:(float)y parent:(TLayer*)parent name:(NSString*)name;
- (id)initWithDocument:(TDocument*)document image:(UIImage*)image x:(float)x y:(float)y parent:(TLayer*)parent name:(NSString*)name;

- (void)loadImage:(UIImage*)image;
- (void)loadImage;

@end
