//
//  TActionIntervalAnimate.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionIntervalAnimate.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TDocument.h"
#import "TLibraryManager.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TImageActor.h"
#import "TLayer.h"

@implementation TActionIntervalAnimate {
    int run_currentFrame;
}

@synthesize duration = _duration;

#pragma mark - Property Methods

- (void)setDuration:(long long)duration {
    if (self.frames != nil && self.frames.count > 0) {
        long long t = 0;
        for (TAnimateFrame* frame in self.frames)
            t += frame.duration;
        
        if (t > 0) {
            float r = (float)duration / t;
            t = 0;
            for (int i = 0; i < self.frames.count - 1; i++) {
                TAnimateFrame* frame = [self.frames objectAtIndex:i];
                frame.duration = frame.duration * r;
                t += frame.duration;
            }
            
            TAnimateFrame* frame = [self.frames objectAtIndex:self.frames.count - 1];
            frame.duration = duration - t;
        } else {
            t = 0;
            long long dt = duration / self.frames.count;
            
            for (int i = 0; i < self.frames.count - 1; i++) {
                TAnimateFrame* frame = [self.frames objectAtIndex:i];
                frame.duration = dt;
                t += dt;
            }
            
            TAnimateFrame* frame = [self.frames objectAtIndex:self.frames.count - 1];
            frame.duration = duration - t;
        }
    }
}

- (long long)duration {
    if (self.frames == nil)
        return 0;
    
    long long t = 0;
    for (TAnimateFrame* frame in self.frames)
        t += frame.duration;
    
    return t;
}

#pragma mark - TActionIntervalAnimate Methods

- (id)init {
    if (self = [super init]) {
        self.name = @"Animate";
        self.startingColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:234/255.0 green:234/255.0 blue:234/255.0 alpha:1];
        self.icon = [UIImage imageNamed:@"icon_action_animate"];
        
        self.frames = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionIntervalAnimate* targetAction = (TActionIntervalAnimate*)target;
    [targetAction.frames addObjectsFromArray:self.frames];
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionIntervalAnimate"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        SMXMLElement* xmlFrames = [xml childNamed:@"Frames"];
        for (SMXMLElement* xmlFrame in [xmlFrames children]) {
            NSString* image = [TUtil parseStringXElement:[xmlFrame childNamed:@"Image"] default:@""];
            long long duration = [TUtil parseIntXElement:[xmlFrame childNamed:@"Duration"] default:-1];
            if (image.length == 0 || duration == -1)
                return NO;
            
            TAnimateFrame* frame = [[TAnimateFrame alloc] init];
            frame.image = image;
            frame.duration = duration;
            [self.frames addObject:frame];
        }

        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (BOOL)isUsingImage:(NSString *)image {
    for (TAnimateFrame* frame in self.frames) {
        if ([frame.image isEqualToString:image])
            return YES;
    }
    
    return NO;
}

#pragma mark - Launch Methods

- (void)prepareResources {
    TLibraryManager* libraryManager = self.sequence.animation.layer.document.libraryManager;
    for (TAnimateFrame* frame in self.frames)
        [libraryManager preloadImage:[libraryManager imageIndex:frame.image] async:YES];
}

- (void)reset:(long long)time {
    [super reset:time];
    
    run_currentFrame = -1;
    
    [self prepareResources];
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {

    TLayer* layer = self.sequence.animation.layer;
    if (self.frames.count > 0 && [layer isKindOfClass:TImageActor.class]) {
        float elapsed = time - self.run_startTime;
        if (elapsed > self.duration)
            elapsed = self.duration;
        
        long long t = 0;
        int index = 0;
        while (t < elapsed && index < self.frames.count) {
            TAnimateFrame* frame = [self.frames objectAtIndex:index++];
            t += frame.duration;
        }
        
        if (index > 0)
            index--;
        
        if (index != run_currentFrame) {
            run_currentFrame = index;

            TAnimateFrame* frame = [self.frames objectAtIndex:index];
            
            TImageActor* target = (TImageActor*)layer;
            TLibraryManager* libraryManager = target.document.libraryManager;
            int libImageIndex = [libraryManager imageIndex:frame.image];
            if (libImageIndex != -1) {
                UIImage* image = [libraryManager imageObject:libImageIndex];
                [target loadImage:image];
            }
        }
    }
    
    return [super step:delegate time:time];
}

@end

@implementation TAnimateFrame

@end
