//
//  TImageActor.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TImageActor.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TDocument.h"
#import "TLibraryManager.h"

@implementation TImageActor {
    UIImage* imgTexture;
}

- (id)initWithDocument:(TDocument*)document {
    if (self = [super initWithDocument:document]) {
        self.image = @"";
        imgTexture = nil;
    }
    
    return self;
}

- (id)initWithDocument:(TDocument*)document imageWithName:(NSString*)image x:(float)x y:(float)y parent:(TLayer*)parent name:(NSString*)name {
    if (self = [super initWithDocument:document x:x y:y parent:parent name:name]) {
        // save file path
        self.image = image;
        
        // load image
        [self loadImage];
    }
    
    return self;
}

- (id)initWithDocument:(TDocument*)document image:(UIImage*)image x:(float)x y:(float)y parent:(TLayer*)parent name:(NSString*)name {
    if (self = [super initWithDocument:document x:x y:y parent:parent name:name]) {
        // save file path
        self.image = @"";
        
        // load image
        [self loadImage:image];
    }
    
    return self;
}

- (void)clone:(TLayer*)target {
    [super clone:target];
    
    TImageActor* targetLayer = (TImageActor*)target;
    targetLayer.image = self.image;
    [targetLayer loadImage];
}

- (BOOL)parseXml:(SMXMLElement*)xml parent:(TLayer*)parent {
    if (xml == nil || ![xml.name isEqualToString:@"ImageActor"])
        return NO;
    
    if (![super parseXml:xml parent:parent])
        return NO;
    
    @try {
        self.image = [TUtil parseStringXElement:[xml childNamed:@"Image"] default:@""];
        [self loadImage];
        
        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (void)updateContents {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

    self.contents = (id)imgTexture.CGImage;
    self.bounds = CGRectMake(0, 0, imgTexture.size.width, imgTexture.size.height);
    
    [CATransaction flush];
    [CATransaction commit];
}

- (void)loadImage:(UIImage*)image {
    imgTexture = image;
    [self updateContents];
}

- (void)loadImage {
    @try {
        imgTexture = [self.document.libraryManager imageObject:[self.document.libraryManager imageIndex:self.image]];
        [self updateContents];
    } @catch (NSException* e) {
        NSLog(@"Error %@", e);
    }
}

- (CGRect)bound {
    if (imgTexture != nil)
        return CGRectMake(0, 0, imgTexture.size.width, imgTexture.size.height);
    else
        return CGRectZero;
}

- (BOOL)isUsingImage:(NSString *)image {
    if ([self.image isEqualToString:image])
        return YES;
    
    return [super isUsingImage:image];
}

@end
