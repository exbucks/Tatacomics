//
//  TLibraryManager.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TLibraryManager.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TDocument.h"

@implementation TLibraryManager {

    NSMutableArray*     imageFiles;
    NSCache*            imageObjects;
    
#if !TARGET_OS_IPHONE
    NSMutableArray*     imageListThumbnails;
    NSMutableArray*     imageToolbarThumbnails;
#endif
    
    NSMutableArray*     soundFiles;
    
}

- (id)initWithDocument:(TDocument*) document {
    if (self = [super init]) {
        self.document = document;
        
        imageFiles = [[NSMutableArray alloc] init];
        imageObjects = [[NSCache alloc] init];
        
#if !TARGET_OS_IPHONE
        imageListThumbnails = [[NSMutableArray alloc] init];
        imageToolbarThumbnails = [[NSMutableArray alloc] init];
#endif
        soundFiles = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)parseXml:(SMXMLElement*)xml {
    if (xml == nil || ![xml.name isEqualToString:@"Libraries"])
        return NO;
    
    SMXMLElement* xmlImages = [xml childNamed:@"Images"];
    if (xmlImages == nil)
        return NO;
    for (SMXMLElement* xmlImage in [xmlImages childrenNamed:@"Image"])
        [self addImage:[TUtil parseStringXElement:xmlImage default:@""]];
    
    SMXMLElement* xmlSounds = [xml childNamed:@"Sounds"];
    if (xmlSounds == nil)
        return NO;
    for (SMXMLElement* xmlSound in [xmlSounds childrenNamed:@"Sound"])
        [self addSound:[TUtil parseStringXElement:xmlSound default:@""]];
    
    return YES;
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (NSArray*)imageListThumbnails {
#if !TARGET_OS_IPHONE
    return imageListThumbnails;
#else
    NOT_IMPLEMENTED_METHOD
#endif
}

- (BOOL)addImage:(NSString*)fileName {
    if ([self imageIndex:fileName] == -1) {
        @try {
            
#if !TARGET_OS_IPHONE
            //================================== prepare to recreate image ========================================//
            float w, h;
            UIImage* loadedImage = [UIImage imageWithContentsOfFile:[[self.document getImagesDiretoryPath] stringByAppendingPathComponent:fileName]];
            
            if (loadedImage == nil)
                return NO;

            //==================================== image list thumbnail ===========================================//
            float s = fmin(IMAGE_LIST_THUMBNAIL_WIDTH / loadedImage.size.width, IMAGE_LIST_THUMBNAIL_HEIGHT / loadedImage.size.height);
            w = (int)(loadedImage.size.width * s * 0.9);
            h = (int)(loadedImage.size.height * s * 0.9);

            CGRect rect = CGRectMake(0, 0, w, h);
            
            // create context
            UIGraphicsBeginImageContext( rect.size );
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            // draw border
            CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:171/255.0 green:171/255.0 blue:171/255.0 alpha:1].CGColor);
            CGContextSetLineWidth(context, 1.0);
            CGContextStrokeRect(context, rect);
            
            // draw image
            [loadedImage drawInRect:CGRectMake((IMAGE_LIST_THUMBNAIL_WIDTH - w) / 2, (IMAGE_LIST_THUMBNAIL_HEIGHT - h) / 2, w, h)];
            
            // complete
            UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *thumbnailImageData = UIImagePNGRepresentation(picture1);
            UIImage *imgThumbnail = [UIImage imageWithData:thumbnailImageData];
            [imageListThumbnails addObject:imgThumbnail];
            
            //===================================== image toolbar thumbnaill =========================================//
            s = fmin(IMAGE_TOOLBAR_THUMBNAIL_WIDTH / loadedImage.size.width, IMAGE_TOOLBAR_THUMBNAIL_HEIGHT / loadedImage.size.height);
            w = (int)(loadedImage.size.width * s);
            h = (int)(loadedImage.size.height * s);
            
            rect = CGRectMake(0, 0, w, h);
            UIGraphicsBeginImageContext( rect.size );
            [loadedImage drawInRect:CGRectMake((IMAGE_TOOLBAR_THUMBNAIL_WIDTH - w) / 2, (IMAGE_TOOLBAR_THUMBNAIL_HEIGHT - h) / 2, w, h)];
            UIImage *picture2 = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *toolbarImageData = UIImagePNGRepresentation(picture2);
            UIImage *imgToolbar = [UIImage imageWithData:toolbarImageData];
            [imageToolbarThumbnails addObject:imgToolbar];
#endif
            
            //===================================== register image file name ============================================//
            [imageFiles addObject:fileName];
            return YES;
        } @catch (NSException* e) {
            NSLog(@"Error: %@", e);
            return NO;
        }
    }
    
    return NO;
}

- (void)removeImage:(int)index {
    if (index >= 0 && index < imageFiles.count) {
#if !TARGET_OS_IPHONE
        [imageListThumbnails removeObjectAtIndex:index];
        [imageToolbarThumbnails removeObjectAtIndex:index];
#endif
        [imageFiles removeObjectAtIndex:index];
    }
}

- (void)preloadImage:(int)index async:(BOOL)async {
#if false
    // check the specified image already was loaded
    if ([imageObjects objectForKey:[NSNumber numberWithInt:index]])
        return;
    
    if (async) {
        [imageObjects setObject:@true forKey:[NSNumber numberWithInt:index]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            if (![imageObjects objectForKey:[NSNumber numberWithInt:index]])
                return;
            UIImage *image = [UIImage imageWithContentsOfFile:[self imageFilePath:index]];

            if (![imageObjects objectForKey:[NSNumber numberWithInt:index]])
                return;
            image = [TUtil preloadedImage:image];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![imageObjects objectForKey:[NSNumber numberWithInt:index]])
                    return;
                [imageObjects setObject:image forKey:[NSNumber numberWithInt:index]];
            });
            
        });
    } else {
        UIImage *image = [UIImage imageWithContentsOfFile:[self imageFilePath:index]];
        image = [TUtil preloadedImage:image];
        [imageObjects setObject:image forKey:[NSNumber numberWithInt:index]];
    }
#endif
}

- (void)clearImageCaches {
    [imageObjects removeAllObjects];
}

- (int)imageCount {
    return (int)imageFiles.count;
}

- (NSString*)imageFileName:(int)index {
    if (index >= 0 && index < imageFiles.count)
        return [imageFiles objectAtIndex:index];
    else
        return @"";
}

- (NSString*)imageFilePath:(int)index {
    if (index >= 0 && index < imageFiles.count)
        return [[self.document getImagesDirectoryPath] stringByAppendingPathComponent:[imageFiles objectAtIndex:index]];
    else
        return @"";
}

- (UIImage*)imageObject:(int)index {
    id object = [imageObjects objectForKey:[NSNumber numberWithInt:index]];
    if (object != nil && [object isKindOfClass:UIImage.class])
        return (UIImage*)object;
    
    return [UIImage imageWithContentsOfFile:[self imageFilePath:index]];
}

- (UIImage*)imageForToolbarAtIndex:(int)index {
#if !TARGET_OS_IPHONE
    if (index >= 0 && index < imageToolbarThumbnails.count)
        return [imageToolbarThumbnails objectAtIndex:index];
    else
        return nil;
#else
    NOT_IMPLEMENTED_METHOD
#endif
}

- (int)imageIndex:(NSString*)fileName {
    for (int i = 0; i < imageFiles.count; i++) {
        if ([[imageFiles objectAtIndex:i] isEqualToString:fileName])
            return i;
    }
    
    return -1;
}

- (BOOL)addSound:(NSString*)fileName {
    if ([self soundIndex:fileName] == -1) {
        [soundFiles addObject:fileName];
    }
    
    return NO;
}

- (void)removeSound:(NSString*)fileName {
    [soundFiles removeObject:fileName];
}

- (int)soundCount {
    return (int)soundFiles.count;
}

- (NSString*)soundFileName:(int)index {
    if (index >= 0 && index < soundFiles.count)
        return [soundFiles objectAtIndex:index];
    else
        return @"";
}

- (NSString*)soundFilePath:(int)index {
    if (index >= 0 && index < soundFiles.count)
        return [[self.document getSoundsDirectoryPath] stringByAppendingPathComponent:[soundFiles objectAtIndex:index]];
    else
        return @"";
}

- (int)soundIndex:(NSString*)fileName {
    for (int i = 0; i < soundFiles.count; i++) {
        if ([[soundFiles objectAtIndex:i] isEqualToString:fileName])
            return i;
    }
    
    return -1;
}

@end
