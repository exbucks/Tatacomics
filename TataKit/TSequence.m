//
//  TSequence.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TSequence.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TAction.h"

@implementation TSequence {
    NSMutableArray* actions;
}

- (id)init {
    if (self = [super init]) {
        self.repeat = 1;
        self.animation = nil;
        
        actions = [[NSMutableArray alloc] init];
        
        self.run_repeated = 0;
        self.run_currentAction = -1;
    }
    
    return self;
}

- (TSequence*)clone {
    TSequence* sequence = [[TSequence alloc] init];
    sequence.animation = self.animation;
    sequence.repeat = self.repeat;
    for (TAction* action in actions) {
        TAction* newAction = [action clone];
        [sequence addAction:newAction];
    }
    
    return sequence;
}

- (void)fixRelationship {
    for (TAction* action in actions) {
        action.sequence = self;
    }
}

- (BOOL)parseXml:(SMXMLElement*)xml {
    if (xml == nil || ![xml.name isEqualToString:@"Sequence"])
        return NO;
    
    @try {
        // repeat property
        self.repeat = [TUtil parseIntXElement:[xml childNamed:@"Repeat"] default:1];
        
        // action list
        SMXMLElement* xmlActions = [xml childNamed:@"Actions"];
        if (xmlActions == nil)
            return NO;
        for (SMXMLElement* xmlAction in [xmlActions children]) {
            // action class from action tag name
            NSString* actionClassName = [NSString stringWithFormat:@"T%@", xmlAction.name];
            
            // create action instance with this as sequence of new action
            TAction* action = [[NSClassFromString(actionClassName) alloc] init];
            action.sequence = self;
            if (![action parseXml:xmlAction])
                return NO;
            [actions addObject:action];
        }
        
        return YES;
    } @catch (NSException* ex) {
        NSLog(@"Error: %@", ex);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}


- (int)numberOfActions {
    return (int)actions.count;
}

- (void)addAction:(TAction*)action {
    action.sequence = self;
    [actions addObject:action];
}

- (void)insertAction:(TAction*)action index:(int)index {
    action.sequence = self;
    [actions insertObject:action atIndex:index];
}

- (void)deleteAction:(int)index {
    if (index >= 0 && index < actions.count)
        [actions removeObjectAtIndex:index];
}

- (float)totalDuration {
    float duration = 0;
    for (TAction* action in actions) {
        duration += action.duration;
    }
    
    return duration;
}

- (BOOL)isInstantAction:(int)index {
    if (index >= 0 && index < actions.count)
        return ((TAction*)[actions objectAtIndex:index]).isInstant;
    
    return NO;
}

- (long long)durationOfAction:(int)index {
    if (index >= 0 && index < actions.count)
        return ((TAction*)[actions objectAtIndex:index]).duration;
    
    return 0;
}

- (TAction*)actionAtIndex:(int)index {
    if (index >= 0 && index < actions.count)
        return [actions objectAtIndex:index];
    
    return nil;
}

- (UIColor*)startingColorOfAction:(int)index {
    if (index >= 0 && index < actions.count)
        return ((TAction*)[actions objectAtIndex:index]).startingColor;
    
    return [UIColor whiteColor];
}

- (UIColor*)endingColorOfAction:(int)index {
    if (index >= 0 && index < actions.count)
        return ((TAction*)[actions objectAtIndex:index]).endingColor;
    
    return [UIColor lightGrayColor];
}

- (UIImage*)iconOfAction:(int)index {
    if (index >= 0 && index < actions.count)
        return ((TAction*)[actions objectAtIndex:index]).icon;
    
    return nil;
}

- (UIImage*)draggingIconOfAction:(int)index {
    if (index >= 0 && index < actions.count)
        return [((TAction*)[actions objectAtIndex:index]) iconWithFrame];
    
    return nil;
}

- (BOOL)isUsingImage:(NSString*)image {
    for (TAction* action in actions) {
        if ([action isUsingImage:image])
            return YES;
    }
    
    return NO;
}

- (BOOL)isUsingSound:(NSString*)sound {
    for (TAction* action in actions) {
        if ([action isUsingSound:sound])
            return YES;
    }
    
    return NO;
}

#pragma mark - Launch Methods

- (void)start {
    self.run_repeated = 0;
    self.run_currentAction = -1;
}


// Execute sequence for every frame
// if sequence is progressing then return true
// if sequence is donen and finished then return false
- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    if ((self.repeat == -1 || self.run_repeated < self.repeat) && actions.count > 0) {
        if (self.run_currentAction == -1)
            [self changeCurrentAction:0 time:time];
        
        BOOL actionFinished = NO;
        int startingAction = self.run_currentAction;
        while (true) {
            // execute action
            actionFinished = [[actions objectAtIndex:self.run_currentAction] step:delegate time:time];
            
            // if action finished, next action
            if (actionFinished) {
                int nextAction = self.run_currentAction + 1;
                BOOL needNext = NO;
                
                if (nextAction < actions.count) {
                    needNext = YES;
                } else {
                    if (self.repeat == -1) {
                        nextAction = 0;
                        needNext = YES;
                    } else if (self.run_repeated + 1 < self.repeat) {
                        self.run_repeated++;
                        nextAction = 0;
                        needNext = YES;
                    } else {
                        self.run_repeated++;
                        needNext = NO;
                    }
                }
                
                // go next action
                if (needNext) {
                    [self changeCurrentAction:nextAction time:time];
                    
                    // check endless loop
                    if (startingAction == nextAction)
                        return YES;
                } else {
                    return NO;
                }
            } else {
                return YES;
            }
        }
    }
    
    return NO;
}


- (void)changeCurrentAction:(int)index time:(long long)time {
    [[actions objectAtIndex:index] reset:time];
    self.run_currentAction = index;
}


@end
