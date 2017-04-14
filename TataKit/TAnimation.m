//
//  TAnimation.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TAnimation.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TSequence.h"
#import "TAction.h"

@implementation TAnimation {
    NSMutableArray* sequences;
}

- (id)initWithLayer:(TLayer*)layer {
    if (self = [super init]) {
        self.event = DEFAULT_EVENT_UNDEFINED;
        self.state = DEFAULT_STATE_DEFAULT;
        self.layer = layer;
        
        sequences = [[NSMutableArray alloc] init];
        
        // for launch
        self.run_executing = NO;
    }
    
    return self;
}

#pragma mark - TAnimation Methods

- (TAnimation*)clone {
    TAnimation* animation = [[TAnimation alloc] initWithLayer:self.layer];
    animation.event = self.event;
    animation.state = self.state;
    for (TSequence* sequence in sequences) {
        TSequence* newSequence = [sequence clone];
        [animation addSequence:newSequence];
    }
    
    return animation;
}

+ (TAnimation*)newAnimation:(TLayer*)layer action:(TAction*)action {
    TAnimation *animation = [[TAnimation alloc] initWithLayer:layer];

    TSequence *sequence = [[TSequence alloc] init];
    [animation addSequence:sequence];
    
    action.sequence = sequence;
    [sequence addAction:action];
    
    return animation;
}

- (void)fixRelationship {
    for (TSequence* sequence in sequences) {
        sequence.animation = self;
        [sequence fixRelationship];
    }
}

- (BOOL)parseXml:(SMXMLElement*)xml {
    if (xml == nil || ![xml.name isEqualToString:@"Animation"])
        return NO;
    
    @try {
        self.event = [TUtil parseStringXElement:[xml childNamed:@"Event"] default:@""];
        self.state = [TUtil parseStringXElement:[xml childNamed:@"State"] default:@""];
        
        // action list
        SMXMLElement* xmlSequences = [xml childNamed:@"Sequences"];
        if (xmlSequences == nil)
            return NO;
        for (SMXMLElement* xmlSequence in [xmlSequences children]) {
            TSequence* sequence = [[TSequence alloc] init];
            sequence.animation = self;
            if (![sequence parseXml:xmlSequence])
                return NO;
            [sequences addObject:sequence];
        }
        
        return YES;
    } @catch (NSException *e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (int)numberOfSequences {
    return (int)sequences.count;
}

- (TSequence*)sequenceAtIndex:(int)index {
    if (index >= 0 && index < sequences.count)
        return [sequences objectAtIndex:index];
    return nil;
}

- (TSequence*)addSequence {
    TSequence* sequence = [[TSequence alloc] init];
    sequence.animation = self;
    [sequences addObject:sequence];

    return sequence;
}

- (void)addSequence:(TSequence*)sequence {
    sequence.animation = self;
    [sequences addObject:sequence];
}

- (void)removeSequence:(int)index {
    if (index >= 0 && index < sequences.count)
        [sequences removeObjectAtIndex:index];
}

- (int)numberOfActionsInSequence:(int)sequenceIndex {
    if (index >= 0 && sequenceIndex < sequences.count)
        return [[sequences objectAtIndex:sequenceIndex] numberOfActions];
    
    return 0;
}

- (TAction*)actionAtIndex:(int)sequenceIndex action:(int)actionIndex {
    if (sequenceIndex >= 0 && sequenceIndex < sequences.count)
        return [[sequences objectAtIndex:sequenceIndex] actionAtIndex:actionIndex];
    
    return nil;
}

- (void)insertAction:(TAction*)action sequence:(int)sequenceIndex action:(int)actionIndex {
    if (sequenceIndex >= 0 && sequenceIndex < sequences.count)
        [[sequences objectAtIndex:sequenceIndex] insertAction:action index:actionIndex];
}

- (void)deleteAction:(int)actionIndex sequence:(int)sequenceIndex {
    if (sequenceIndex >= 0 && sequenceIndex < sequences.count)
        [[sequences objectAtIndex:sequenceIndex] deleteAction:actionIndex];
}

- (BOOL)isUsingImage:(NSString*)image {
    for (TSequence* sequence in sequences) {
        if ([sequence isUsingImage:image])
            return YES;
    }
    
    return NO;
}

- (BOOL)isUsingSound:(NSString*)sound {
    for (TSequence* sequence in sequences) {
        if ([sequence isUsingSound:sound])
            return YES;
    }
    
    return NO;
}

#pragma mark - Launch Methods

- (void)start {
    self.run_executing = YES;
    for (TSequence* sequence in sequences) {
        [sequence start];
    }
}

- (void)stop {
    self.run_executing = NO;
}

- (void)step:(id<TTataDelegate>)delegate time:(long long)time {
    BOOL progressing = NO;
    for (TSequence* sequence in sequences)
        progressing |= [sequence step:delegate time:time];
    
    if (!progressing)
        [self stop];
}

#pragma ITimeLineDataSource Interface Methods

- (int)numberOfRows {
    return [self numberOfSequences];
}

- (float)totalDuration {
    float ret = 0;
    for (TSequence* sequence in sequences) {
        float duration = [sequence totalDuration];
        if (duration > ret)
            ret = duration;
    }
    
    return ret;
}

- (int)numberOfItemsInRow:(int)rowIndex {
    return [self numberOfActionsInSequence:rowIndex];
}

- (BOOL)isInstantItem:(int)itemIndex row:(int)rowIndex {
    if (rowIndex >= 0 && rowIndex < sequences.count) {
        TSequence *sequence = [sequences objectAtIndex:rowIndex];
        return [sequence isInstantAction:itemIndex];
    }
    
    return NO;
}

- (float)durationOfItem:(int)itemIndex row:(int)rowIndex {
    if (rowIndex >= 0 && rowIndex < sequences.count) {
        TSequence *sequence = [sequences objectAtIndex:rowIndex];
        return (float)[sequence durationOfAction:itemIndex] / 1000;
    }
    
    return 0;
}

- (UIColor*)startingColorOfItem:(int)itemIndex row:(int)rowIndex {
    if (rowIndex >= 0 && rowIndex < sequences.count) {
        TSequence *sequence = [sequences objectAtIndex:rowIndex];
        return [sequence startingColorOfAction:itemIndex];
    }
    
    return [UIColor whiteColor];
}

- (UIColor*)endingColorOfItem:(int)itemIndex row:(int)rowIndex {
    if (rowIndex >= 0 && rowIndex < sequences.count) {
        TSequence *sequence = [sequences objectAtIndex:rowIndex];
        return [sequence endingColorOfAction:itemIndex];
    }
    
    return [UIColor lightGrayColor];
}

- (UIImage*)iconOfItem:(int)itemIndex row:(int)rowIndex {
    if (rowIndex >= 0 && rowIndex < sequences.count) {
        TSequence *sequence = [sequences objectAtIndex:rowIndex];
        return [sequence iconOfAction:itemIndex];
    }
    
    return nil;
}

- (UIImage*)draggingIconOfItem:(int)itemIndex row:(int)rowIndex {
    if (rowIndex >= 0 && rowIndex < sequences.count) {
        TSequence *sequence = [sequences objectAtIndex:rowIndex];
        return [sequence draggingIconOfAction:itemIndex];
    }
    
    return nil;
}

@end
