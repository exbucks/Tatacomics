//
//  TAvatarActor.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TAvatarActor.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TDocument.h"

@implementation TAvatarActor {
    UIImage* imgContents;
}

#pragma mark - Property Methods

- (void)setBoxSize:(CGSize)value {
    self.bounds = CGRectMake(0, 0, value.width, value.height);
}

- (CGSize)boxSize {
    return self.bounds.size;
}

#pragma mark - TAvatarActor Methods

- (id)initWithDocument:(TDocument*)document {
    if (self = [super initWithDocument:document]) {
        self.boxSize = CGSizeZero;
        
        [self updateContents];
    }
    
    return self;
}

- (id)initWithDocument:(TDocument*)document position:(CGPoint)position box:(CGSize)box parent:(TLayer*)parent name:(NSString*)name {
    if (self = [super initWithDocument:document x:position.x y:position.y parent:parent name:name]) {
        self.boxSize = box;
        
        [self updateContents];
    }
    
    return self;
}

- (void)clone:(TLayer*)target {
    [super clone:target];
    
    TAvatarActor* targetLayer = (TAvatarActor*)target;
    targetLayer.boxSize = self.boxSize;
    
    [targetLayer updateContents];
}

- (BOOL)parseXml:(SMXMLElement*)xml parent:(TLayer*)parent {
    if (xml == nil || ![xml.name isEqualToString:@"AvatarActor"])
        return NO;
    
    if (![super parseXml:xml parent:parent])
        return NO;
    
    @try {
        float w = [TUtil parseFloatXElement:[xml childNamed:@"SizeWidth"] default:0];
        float h = [TUtil parseFloatXElement:[xml childNamed:@"SizeHeight"] default:0];
        self.boxSize = CGSizeMake(w, h);
        
        [self updateContents];
        
        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (void)updateContents {
    if (self.boxSize.width > 0 && self.boxSize.height > 0) {
        // create context
        UIGraphicsBeginImageContext( self.boxSize );
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // draw scene
        [self draw:context];
        
        // complete
        UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *data = UIImagePNGRepresentation(picture);
        imgContents = [UIImage imageWithData:data];
        
        self.contents = (id)imgContents.CGImage;
    } else {
        self.contents = nil;
    }
}

- (void)draw:(CGContextRef)context {
    UIImage* avatar = [self.document getAvatarImage];
    if (avatar != nil) {
        // save graphics state
        CGContextSaveGState(context);
        
        // draw image
        CGContextTranslateCTM(context, 0, self.boxSize.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextDrawImage(context, [self bound], avatar.CGImage);
        
        // draw childs
//        NSArray* items = [self sortedChilds];
//        for (TActor* item in items) {
//            [item draw:context];
//        }
        
        // restore graphics state
        CGContextRestoreGState(context);
    }
}

- (CGRect)bound {
    return CGRectMake(0, 0, self.boxSize.width, self.boxSize.height);
}


@end
