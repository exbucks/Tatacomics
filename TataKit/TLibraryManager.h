//
//  TLibraryManager.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKIt.h>

@class TDocument;
@class SMXMLElement;

#define IMAGE_LIST_THUMBNAIL_WIDTH          85
#define IMAGE_LIST_THUMBNAIL_HEIGHT         65

#define IMAGE_TOOLBAR_THUMBNAIL_WIDTH       32
#define IMAGE_TOOLBAR_THUMBNAIL_HEIGHT      32

@interface TLibraryManager : NSObject

@property (weak) TDocument*     document;

- (id)initWithDocument:(TDocument*) document;

- (BOOL)parseXml:(SMXMLElement*)xml;
- (SMXMLElement*)toXml;

- (NSArray*)imageListThumbnails;

- (BOOL)addImage:(NSString*)fileName;
- (void)removeImage:(int)index;

- (void)preloadImage:(int)index async:(BOOL)async;
- (void)clearImageCaches;

- (int)imageCount;
- (NSString*)imageFileName:(int)index;
- (NSString*)imageFilePath:(int)index;
- (UIImage*)imageObject:(int)index;
- (UIImage*)imageForToolbarAtIndex:(int)index;
- (int)imageIndex:(NSString*)fileName;

- (BOOL)addSound:(NSString*)fileName;
- (void)removeSound:(NSString*)fileName;

- (int)soundCount;
- (NSString*)soundFileName:(int)index;
- (NSString*)soundFilePath:(int)index;
- (int)soundIndex:(NSString*)fileName;

@end
