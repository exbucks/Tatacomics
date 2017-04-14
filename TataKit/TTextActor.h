//
//  TTextActor.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TActor.h"

@interface TTextActor : TActor

@property (copy) NSString*      text;
@property (strong) UIFont*      font;
@property (strong) UIColor*     color;
@property (assign) CGSize       boxSize;

- (id)initWithDocument:(TDocument*)document text:(NSString*)text position:(CGPoint)position box:(CGSize)box parent:(TLayer*)parent name:(NSString*)name;

@end
