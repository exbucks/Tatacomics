//
//  TSceneManager.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMXMLElement;
@class TDocument;
@class TScene;

@interface TSceneManager : NSObject

@property (nonatomic, weak) TDocument*  document;
@property (nonatomic, assign) int currentSceneIndex;

- (id)initWithDocument:(TDocument*)document;

- (BOOL)parseXml:(SMXMLElement*)xml;
- (SMXMLElement*)toXml;

- (UIImage*)thumbnailImage:(int)index;
- (NSArray*)thumbnailImageList;
- (void)updateThumbnailByIndex:(int)index;
- (void)updateThumbnail:(TScene*)scene;

- (NSString*)newSceneName;
- (void)addScene:(TScene*)scene;
- (void)insertScene:(TScene*)scene atIndex:(int)index;
- (void)deleteScene:(int)index;
- (TScene*)scene:(int)index;
- (int)indexOfScene:(NSString*)sceneName;
- (int)sceneCount;

@end
