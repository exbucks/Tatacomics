//
//  TScene.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TScene.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TDocument.h"
#import "TImageActor.h"
#import "TTextActor.h"
#import "TAvatarActor.h"
#import "TLibraryManager.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TAction.h"
#import "TActionIntervalAnimate.h"

@implementation TScene {
    UIImage* imgTemp;
}

- (id)initWithDocument:(TDocument*)document {
    if (self = [super initWithDocument:document parent:nil name:@""]) {
        // default background color of new scene
        self.backgroundColor = [UIColor whiteColor];
        
        // default values
        self.touchIndication = YES;
        self.prevButtonVisible = YES;
        self.nextButtonVisible = YES;
        
        // bgm
        self.backgroundMusic = @"";
        self.backgroundMusicVolume = 100;
        
        // initialize runtime variables
        self.run_running = NO;
        self.run_matrix = CGAffineTransformIdentity;
        self.run_extraActors = nil;
        
        self.masksToBounds = YES;
        self.frame = CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);
    }
    
    return self;
}

- (id)initWithDocument:(TDocument*)document name:(NSString*)name {
    if (self = [super initWithDocument:document parent:nil name:name]) {
        // default background color of new scene
        self.backgroundColor = [UIColor whiteColor];
        
        // default values
        self.touchIndication = YES;
        self.prevButtonVisible = YES;
        self.nextButtonVisible = YES;
        
        // bgm
        self.backgroundMusic = @"";
        self.backgroundMusicVolume = 100;
        
        // initialize runtime variables
        self.run_running = NO;
        self.run_matrix = CGAffineTransformIdentity;
        self.run_extraActors = nil;
        
        self.masksToBounds = YES;
        self.frame = CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);
    }
    
    return self;
}

- (void)clone:(TLayer*)target {
    [super clone:target];
    
    TScene* targetLayer = (TScene*)target;
    targetLayer.backgroundColor = self.backgroundColor;
    targetLayer.touchIndication = self.touchIndication;
    targetLayer.prevButtonVisible = self.prevButtonVisible;
    targetLayer.nextButtonVisible = self.nextButtonVisible;
    targetLayer.backgroundMusic = self.backgroundMusic;
    targetLayer.backgroundMusicVolume = self.backgroundMusicVolume;
    
    targetLayer.run_delegate = self.run_delegate;
    targetLayer.run_matrix = self.run_matrix;
}

- (BOOL)parseXml:(SMXMLElement*)xml parent:(TLayer*)parent {
    if (xml == nil || ![xml.name isEqualToString:@"Scene"])
        return NO;
    
    if (![super parseXml:xml parent:parent])
        return NO;
    
    @try {
        self.backgroundColor = [TUtil parseColorXElement:[xml childNamed:@"BackgroundColor"] default:[UIColor blackColor]];
        self.touchIndication = [TUtil parseBoolXElement:[xml childNamed:@"TouchIndication"] default:YES];
        self.prevButtonVisible = [TUtil parseBoolXElement:[xml childNamed:@"PrevButtonVisible"] default:YES];
        self.nextButtonVisible = [TUtil parseBoolXElement:[xml childNamed:@"NextButtonVisible"] default:YES];
        self.backgroundMusic = [TUtil parseStringXElement:[xml childNamed:@"BackgroundMusic"] default:@""];
        self.backgroundMusicVolume = [TUtil parseIntXElement:[xml childNamed:@"BackgroundMusicVolume"] default:100];
        
        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (void)prepareResources {
//    // preload for image actors
//    for (TActor* actor in [self getAllChilds]) {
//        if ([actor isKindOfClass:TImageActor.class]) {
//            TImageActor* imageActor = (TImageActor*)actor;
//            TLibraryManager* libraryManager = self.document.libraryManager;
//            [libraryManager preloadImage:[libraryManager imageIndex:imageActor.image] async:YES];
//        }
//    }
    
    // preload for animate actors
    for (TActor* actor in [self getAllChilds]) {
        for (TAnimation* animation in actor.animations) {
            for (int i = 0; i < [animation numberOfSequences]; i++) {
                TSequence* sequence = [animation sequenceAtIndex:i];
                for (int j = 0; j < [sequence numberOfActions]; j++) {
                    TAction* action = [sequence actionAtIndex:j];
                    if ([action isKindOfClass:TActionIntervalAnimate.class]) {
                        TActionIntervalAnimate* animateAction = (TActionIntervalAnimate*)action;
                        [animateAction prepareResources];
                    }
                }
            }
        }
    }
}

- (UIImage*)thumbnailImage {
    
    CGRect rect = CGRectMake(0, 0, SCENE_THUMBNAIL_WIDTH, SCENE_THUMBNAIL_HEIGHT);
    
    // create context
    UIGraphicsBeginImageContext( rect.size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw background
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);

    // calc matrix
    CGContextScaleCTM(context, (float)SCENE_THUMBNAIL_WIDTH / BOOK_WIDTH, (float)SCENE_THUMBNAIL_HEIGHT / BOOK_HEIGHT);
    
    // draw scene
    [self drawInContext:context];
    
    // complete
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *thumbnailImageData = UIImagePNGRepresentation(picture1);
    UIImage *imgThumbnail = [UIImage imageWithData:thumbnailImageData];
    return imgThumbnail;
}

- (TImageActor*)pushImage:(NSString*)image position:(CGPoint)position {
    TImageActor *actor = nil;
    
    // new name
    NSString* actorName = [self newLayerNameWithPrefix:@"Actor_"];
    
    // selected layer
    if ([self.document haveSelection]) {
        TLayer* selectedLayer = [self.document selectedLayer];
        CGPoint pt = [selectedLayer.parent screenToLogical:position];
        actor = [[TImageActor alloc] initWithDocument:self.document imageWithName:image x:pt.x y:pt.y parent:selectedLayer.parent name:actorName];
    } else {
        // create image actor
        CGPoint pt = [self screenToLogical:position];
        actor = [[TImageActor alloc] initWithDocument:self.document imageWithName:image x:pt.x y:pt.y parent:self name:actorName];
    }
    
    return actor;
}

- (TTextActor*)pushText:(NSString*)text rect:(CGRect)rect {
    TTextActor *actor = nil;
    
    // new name
    NSString* actorName = [self newLayerNameWithPrefix:@"Actor_"];
    
    // selected layer
    if ([self.document haveSelection]) {
        TLayer* selectedLayer = [self.document selectedLayer];
        CGPoint pt = [selectedLayer.parent screenToLogical:CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2)];
        CGPoint sz = [selectedLayer.parent screenVectorToLogical:CGPointMake(rect.size.width, rect.size.height)];
        actor = [[TTextActor alloc] initWithDocument:self.document text:text position:pt box:CGSizeMake(sz.x, sz.y) parent:selectedLayer.parent name:actorName];

    } else {
        // text box should have the size at least 100x30 initially
        CGPoint minSz = [self logicalVectorToScreen:CGPointMake(100, 30)];
        if (rect.size.width < minSz.x)
            rect.size.width = minSz.y;
        if (rect.size.height < minSz.y)
            rect.size.height = minSz.y;
        
        // create text actor
        CGPoint pt = [self screenToLogical:CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2)];
        CGPoint sz = [self screenVectorToLogical:CGPointMake(rect.size.width, rect.size.height)];
        actor = [[TTextActor alloc] initWithDocument:self.document text:text position:pt box:CGSizeMake(sz.x, sz.y) parent:self name:actorName];
    }
    
    return actor;
}

- (TAvatarActor*)pushAvatar:(CGRect)rect {
    TAvatarActor *actor = nil;
    
    // new name
    NSString* actorName = [self newLayerNameWithPrefix:@"Actor_"];
    
    // selected layer
    if ([self.document haveSelection]) {
        TLayer* selectedLayer = [self.document selectedLayer];
        CGPoint pt = [selectedLayer.parent screenToLogical:CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2)];
        CGPoint sz = [selectedLayer.parent screenVectorToLogical:CGPointMake(rect.size.width, rect.size.height)];
        actor = [[TAvatarActor alloc] initWithDocument:self.document position:pt box:CGSizeMake(sz.x, sz.y) parent:selectedLayer.parent name:actorName];
    } else {
        // create avatar actor
        CGPoint pt = [self screenToLogical:CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2)];
        CGPoint sz = [self screenVectorToLogical:CGPointMake(rect.size.width, rect.size.height)];
        actor = [[TAvatarActor alloc] initWithDocument:self.document position:pt box:CGSizeMake(sz.x, sz.y) parent:self name:actorName];
    }
    
    return actor;
}

- (TLayer*)findLayer:(NSString *)name {
    if (self.run_extraActors != nil) {
        for (TActor* actor in self.run_extraActors) {
            TLayer* ret = [actor findLayer:name];
            if (ret != nil)
                return ret;
        }
    }
    
    return [super findLayer:name];
}

- (TActor*)actorAtScreenPosition:(CGPoint)pos withinInteraction:(BOOL)withinInteraction {
    if (self.run_extraActors != nil) {
        for (int i = (int)self.run_extraActors.count - 1; i >= 0; i--) {
            TActor* ret = [[self.run_extraActors objectAtIndex:i] actorAtScreenPosition:pos withinInteraction:withinInteraction];
            if (ret != nil)
                return ret;
        }
    }
    
    NSArray* items = [self sortedChilds];
    for (int i = (int)items.count - 1; i >= 0; i--) {
        TActor* ret = [[items objectAtIndex:i] actorAtScreenPosition:pos withinInteraction:withinInteraction];
        if (ret != nil)
            return ret;
    }
    
    return nil;
}

- (CGRect)bound {
    return CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);
}

- (BOOL)isUsingSound:(NSString *)sound {
    // check document properties
    if ([self.backgroundMusic isEqualToString:sound])
        return YES;
    
    return [super isUsingSound:sound];
}

- (NSArray*)getDefaultEvents {
    return @[DEFAULT_EVENT_ENTER, DEFAULT_EVENT_AUTOPLAY];
}

- (NSArray*)getDefaultStates {
    return @[DEFAULT_STATE_DEFAULT];
}

- (void)step:(id<TTataDelegate>)delegate time:(long long)time {
    [super step:delegate time:time];
    
    // step of extra actors
    if (self.run_extraActors != nil) {
        for (TActor* actor in self.run_extraActors) {
            [actor step:delegate time:time];
        }
    }
}

@end
