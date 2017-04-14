//
//  TSceneManager.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TSceneManager.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TDocument.h"
#import "TScene.h"

@implementation TSceneManager {
    NSMutableArray* scenes;
    NSMutableArray* thumbnails;
}

- (id)initWithDocument:(TDocument*) document {
    if (self = [super init]) {
        self.document = document;
        self.currentSceneIndex = -1;
        
        scenes = [[NSMutableArray alloc] init];
        thumbnails = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (BOOL)parseXml:(SMXMLElement*)xml {
    if (xml == nil || ![xml.name isEqualToString:@"Scenes"])
        return NO;
    
    for (SMXMLElement* xmlScene in [xml children]) {
        TScene* scene = [[TScene alloc] initWithDocument:self.document];
        if (![scene parseXml:xmlScene parent:nil])
            return NO;
        
        [self addScene:scene];
    }
    
    return YES;
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (UIImage*)thumbnailImage:(int)index {
    if (index >= 0 && index < scenes.count)
        return [[scenes objectAtIndex:index] thumbnailImage];
    return nil;
}

- (NSArray*)thumbnailImageList {
    return thumbnails;
}

- (void)updateThumbnailByIndex:(int)index {
    if (index >= 0 && index < scenes.count)
        return [thumbnails replaceObjectAtIndex:index withObject:[[scenes objectAtIndex:index] thumbnailImage]];
}

- (void)updateThumbnail:(TScene*)scene {
    for (int i = 0; i < scenes.count; i++) {
        if ([scenes objectAtIndex:i] == scene) {
            [self updateThumbnailByIndex:i];
            return;
        }
    }
}

- (NSString*)newSceneName {
    int k = 0;
    
    NSString *pattern = @"^Scene_(\\d+)$";
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    for (TScene* scene in scenes) {
        NSArray* matches = [regex matchesInString:scene.name options:0 range:NSMakeRange(0, scene.name.length)];
        if (matches.count > 0) {
            NSTextCheckingResult *match = matches[0];
            int no = [[scene.name substringWithRange:[match rangeAtIndex:1]] intValue];
            if (k < no)
                k = no;
        }
    }
    
    return [NSString stringWithFormat:@"Scene_%d", k + 1];
}

- (void)addScene:(TScene*)scene {
    [scenes addObject:scene];
    [thumbnails addObject:[scene thumbnailImage]];
    
    if (scenes.count == 1)
        self.currentSceneIndex = 0;
}

- (void)insertScene:(TScene*)scene atIndex:(int)index {
    [scenes insertObject:scene atIndex:index];
    [thumbnails insertObject:[scene thumbnailImage] atIndex:index];
}

- (void)deleteScene:(int)index {
    if (index >= 0 && index < scenes.count) {
        [scenes removeObjectAtIndex:index];
        [thumbnails removeObjectAtIndex:index];
    }
    
}

- (TScene*)scene:(int)index {
    if (index >= 0 && index < scenes.count)
        return [scenes objectAtIndex:index];
    
    return nil;
}

- (int)indexOfScene:(NSString*)sceneName {
    for (int i = 0; i < scenes.count; i++) {
        TScene* scene = [scenes objectAtIndex:i];
        if ([scene.name isEqualToString:sceneName])
            return i;
    }
    
    return -1;
}

- (int)sceneCount {
    return (int)scenes.count;
}

@end
