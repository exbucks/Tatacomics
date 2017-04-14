//
//  TLayer.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TLayer.h"

#import "TAnimation.h"
#import "TActor.h"
#import "TScene.h"

#import "TUtil.h"
#import "SMXMLDocument.h"

@implementation TLayer

#pragma mark - Property Methods

- (void)setAlpha:(float)value {
    [CATransaction setDisableActions:YES];
    self.opacity = value;
}

- (float)alpha {
    return self.opacity;
}

#pragma mark - TLayer Methods

- (id)initWithDocument:(TDocument*)document {
    if (self = [super init]) {
        self.document = document;
        self.name = @"";
        self.parent = nil;
        
        self.locked = NO;
        
        self.alpha = 1;
        
        self.childs = [[NSMutableArray alloc] init];
        self.animations = [[NSMutableArray alloc] init];
        
        self.events = [[NSMutableArray alloc] init];
        self.states = [[NSMutableArray alloc] init];
        
        self.run_state = DEFAULT_STATE_DEFAULT;
        self.run_enabled = YES;
    }
    
    return self;
}

- (id)initWithDocument:(TDocument*)document parent:(TLayer*)parentLayer name:(NSString*)layerName {
    if (self = [super init]) {
        self.document = document;
        self.name = layerName;
        self.parent = parentLayer;
        
        self.locked = NO;
        
        self.alpha = 1;
        
        self.childs = [[NSMutableArray alloc] init];
        self.animations = [[NSMutableArray alloc] init];
        
        self.events = [[NSMutableArray alloc] init];
        self.states = [[NSMutableArray alloc] init];
        
        self.run_state = DEFAULT_STATE_DEFAULT;
        self.run_enabled = YES;
    }
    
    return self;
}

- (TLayer*)clone {
    TLayer* layer = [[self.class alloc] initWithDocument:self.document];
    [self clone:layer];
    return layer;
}

- (void)clone:(TLayer*)target {
    target.document = self.document;
    target.parent   = self.parent;
    target.name     = self.name;
    target.locked   = self.locked;
    target.alpha    = self.alpha;
    
    for (TLayer* item in self.childs) {
        TLayer* newItem = [item clone];
        newItem.parent = target;

        [target addChild:newItem];
    }
    
    for (TAnimation* animation in self.animations) {
        TAnimation* newAnimation = [animation clone];
        newAnimation.layer = target;
        [target.animations addObject:newAnimation];
    }

    for (NSString* event in self.events) {
        [target.events addObject:event];
    }
    
    for (NSString* state in self.states) {
        [target.states addObject:state];
    }
}

- (BOOL)parseXml:(SMXMLElement*)xml parent:(TLayer*)parent {
    if (xml == nil)
        return NO;

    self.parent                 = parent;
    
    self.name                   = [TUtil parseStringXElement:[xml childNamed:@"Name"] default:@""];
    self.locked                 = [TUtil parseBoolXElement:[xml childNamed:@"Locked"] default:NO];
    self.alpha                  = [TUtil parseFloatXElement:[xml childNamed:@"Alpha"] default:1];

    SMXMLElement* xmlEvents = [xml childNamed:@"Events"];
    if (xmlEvents == nil)
        return NO;
    for (SMXMLElement* xmlEvent in [xmlEvents childrenNamed:@"Event"])
        [self.events addObject:[TUtil parseStringXElement:xmlEvent default:@""]];
    
    SMXMLElement* xmlStates = [xml childNamed:@"States"];
    if (xmlStates == nil)
        return NO;
    for (SMXMLElement* xmlState in [xmlStates childrenNamed:@"State"])
        [self.states addObject:[TUtil parseStringXElement:xmlState default:@""]];
    
    SMXMLElement* xmlAnimations = [xml childNamed:@"Animations"];
    if (xmlAnimations == nil)
        return NO;
    for (SMXMLElement* xmlAnimation in [xmlAnimations childrenNamed:@"Animation"]) {
        TAnimation* animation = [[TAnimation alloc] initWithLayer:self];
        if (![animation parseXml:xmlAnimation])
            return NO;
        [self.animations addObject:animation];
    }
    
    SMXMLElement* xmlChilds = [xml childNamed:@"Childs"];
    if (xmlChilds == nil)
        return NO;
    for (SMXMLElement* xmlChild in [xmlChilds children]) {
        TLayer* layer = [[NSClassFromString([NSString stringWithFormat:@"T%@", xmlChild.name]) alloc] initWithDocument:self.document];
        if (![layer parseXml:xmlChild parent:self])
            return NO;

        [self addChild:layer];
    }
    
    return YES;
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (void)fixRelationship {
    for (TLayer* item in self.childs) {
        item.parent = self;
        [item fixRelationship];
    }
    
    for (TAnimation* animation in self.animations) {
        animation.layer = self;
        [animation fixRelationship];
    }
}

- (void)refresh {
    [self updateContents];
    
    for (TLayer* item in self.childs) {
        [item refresh];
    }
}

- (void)updateContents {
}

// get new layer name suffix
- (int)newLayerNameSuffixWithPrefix:(NSString*)prefix {
    int k = 1;
    
    NSString *pattern = [NSString stringWithFormat:@"^%@(\\d+)$", prefix];
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSArray* matches = [regex matchesInString:self.name options:0 range:NSMakeRange(0, self.name.length)];
    if (matches.count > 0) {
        NSTextCheckingResult *match = matches[0];
        int no = [[self.name substringWithRange:[match rangeAtIndex:1]] intValue];
        if (no >= k)
            k = no + 1;
    }
    
    for (TLayer* layer in self.childs) {
        int no = [layer newLayerNameSuffixWithPrefix:prefix];
        if (no > k)
            k = no;
    }
    
    return k;
}

// get new layer name
- (NSString*)newLayerNameWithPrefix:(NSString*)prefix {
    int suffix = [self newLayerNameSuffixWithPrefix:prefix];
    return [NSString stringWithFormat:@"%@%d", prefix, suffix];
}

- (void)addChild:(TLayer*)child {
    [self.childs addObject:child];
    [self addSublayer:child];
}

// get child list by zindex
- (NSArray*)sortedChilds {
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (TLayer* layer in self.childs) {
        if ([layer isKindOfClass:TActor.class])
            [list addObject:layer];
    }
    
    // sort by zindex
    [list sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if (obj2 == nil)
            return NSOrderedDescending;

        TActor* actor1 = (TActor*)obj1;
        TActor* actor2 = (TActor*)obj2;
        
        if (actor1.zPosition > actor2.zPosition)
            return NSOrderedDescending;
        else if (actor1.zPosition < actor2.zPosition)
            return NSOrderedAscending;
        else
            return NSOrderedSame;
    }];
    
    return list;
}

// get all childs recursivly
- (NSArray*)getAllChilds {
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (TLayer* layer in self.childs) {
        [list addObject:layer];
        [list addObjectsFromArray:[layer getAllChilds]];
    }
    
    return list;
}

- (TLayer*)findLayer:(NSString*)name {
    if ([self.name isEqualToString:name])
        return self;
    
    for (TLayer* layer in self.childs) {
        TLayer* ret = [layer findLayer:name];
        if (ret != nil)
            return ret;
    }
    
    return nil;
}

- (TScene*)ownerScene {
    if ([self isKindOfClass:TScene.class])
        return (TScene*)self;
    else if (self.parent != nil)
        return [self.parent ownerScene];
    else
        return nil;
}

// convert screen coordinate to logical coordinate of layer
- (CGPoint)screenToLogical:(CGPoint)point {
    return [self convertPoint:point fromLayer:self.ownerScene];
}

// convert screen vector to logical vector of layer
- (CGPoint)screenVectorToLogical:(CGPoint)vector {
    TLayer* p;
    CGAffineTransform mat = self.affineTransform;
    while ((p = self.parent) != nil)
        mat = CGAffineTransformConcat(mat, p.affineTransform);

    mat = CGAffineTransformInvert(mat);
    mat.tx = 0; mat.ty = 0;
    return CGPointApplyAffineTransform(vector, mat);
}

- (CGPoint)logicalToScreen:(CGPoint)point {
    return [self convertPoint:point toLayer:self.ownerScene];
}

- (CGPoint)logicalVectorToScreen:(CGPoint)vector {
    TLayer* p;
    CGAffineTransform mat = self.affineTransform;
    while ((p = self.parent) != nil)
        mat = CGAffineTransformConcat(mat, p.affineTransform);

    mat.tx = 0; mat.ty = 0;
    return CGPointApplyAffineTransform(vector, mat);
}

- (CGRect)bound {
    ABSTRACT_METHOD
}

- (NSArray*)boundOnScreen {
    TScene* scene = [self ownerScene];
    CGRect b = [self bound];
    CGPoint p1 = [self convertPoint:CGPointMake(b.origin.x, b.origin.y) toLayer:scene];
    CGPoint p2 = [self convertPoint:CGPointMake(b.origin.x + b.size.width, b.origin.y) toLayer:scene];
    CGPoint p3 = [self convertPoint:CGPointMake(b.origin.x + b.size.width, b.origin.y + b.size.height) toLayer:scene];
    CGPoint p4 = [self convertPoint:CGPointMake(b.origin.x, b.origin.y + b.size.height) toLayer:scene];
    return @[[NSValue valueWithCGPoint:p1], [NSValue valueWithCGPoint:p2], [NSValue valueWithCGPoint:p3], [NSValue valueWithCGPoint:p4]];
}

- (CGRect)boundStraightOnScreen {
    TScene* scene = [self ownerScene];
    return [self convertRect:[self bound] toLayer:scene];
}


- (TActor*)actorAtScreenPosition:(CGPoint)pos withinInteraction:(BOOL)withinInteraction {
    ABSTRACT_METHOD
}


- (BOOL)isUsingImage:(NSString*)image {
    // check self animation
    for (TAnimation* animation in self.animations) {
        if ([animation isUsingImage:image])
            return YES;
    }
    
    // check children
    for (TLayer* child in self.childs) {
        if ([child isUsingImage:image])
            return YES;
    }
    
    return NO;
}

- (BOOL)isUsingSound:(NSString*)sound {
    // check self animation
    for (TAnimation* animation in self.animations) {
        if ([animation isUsingSound:sound])
            return YES;
    }
    
    // check children
    for (TLayer* child in self.childs) {
        if ([child isUsingSound:sound])
            return YES;
    }
    
    return NO;
}


- (NSArray*)getDefaultEvents {
    ABSTRACT_METHOD
}

- (NSArray*)getEvents {
    return [[self getDefaultEvents] arrayByAddingObjectsFromArray:self.events];
}

- (BOOL)addEvent:(NSString*)event {
    NSArray *allEvents = [self getEvents];
    if ([allEvents containsObject:event])
        return NO;
    
    [self.events addObject:event];
    return YES;
}

- (BOOL)isDefaultEvent:(NSString*)event {
    return [[self getDefaultEvents] containsObject:event];
}

- (void)renameEvent:(NSString*)event newEvent:(NSString*)newEvent {
    NSUInteger i = [self.events indexOfObject:event];
    if (i != NSNotFound)
        [self.events replaceObjectAtIndex:i withObject:newEvent];
}

- (BOOL)deleteEvent:(NSString*)event {
    if ([self isDefaultEvent:event])
        return NO;
    if (![self.events containsObject:event])
        return NO;
    
    [self.events removeObject:event];
    return YES;
}


- (NSArray*)getDefaultStates {
    ABSTRACT_METHOD
}

- (NSArray*)getStates {
    return [[self getDefaultStates] arrayByAddingObjectsFromArray:self.states];
}

- (BOOL)addState:(NSString*)state {
    NSArray *allStates = [self getStates];
    if ([allStates containsObject:state])
        return NO;
    
    [self.states addObject:state];
    return YES;
}

- (BOOL)isDefaultState:(NSString*)state {
    return [[self getDefaultStates] containsObject:state];
}

- (void)renameState:(NSString*)state newState:(NSString*)newState {
    NSUInteger i = [self.states indexOfObject:state];
    if (i != NSNotFound)
        [self.states replaceObjectAtIndex:i withObject:newState];
}

- (BOOL)deleteState:(NSString*)state {
    if ([self isDefaultState:state])
        return NO;
    if (![self.states containsObject:state])
        return NO;
    
    [self.states removeObject:state];
    return YES;
}


- (void)fireEvent:(NSString*)event recursive:(BOOL)recursive {
    if (self.run_enabled) {
        // animation of self
        for (TAnimation *animation in self.animations) {
            if ([animation.event isEqualToString:event] && [animation.state isEqualToString:self.run_state] && animation.run_executing == NO)
                [animation start];
        }
        
        // animation of child
        if (recursive) {
            for (TLayer* child in self.childs) {
                [child fireEvent:event recursive:recursive];
            }
        }
    }
}

- (void)startAnimation:(NSString*)event {
    if (self.run_enabled) {
        for (TAnimation *animation in self.animations) {
            if ([animation.event isEqualToString:event] && [animation.state isEqualToString:self.run_state] && animation.run_executing == YES)
                [animation start];
        }
    }
}

- (void)stopAnimation:(NSString*)event state:(NSString*)state {
    if (self.run_enabled) {
        for (TAnimation *animation in self.animations) {
            if ([animation.event isEqualToString:event] && [animation.state isEqualToString:state] && animation.run_executing == YES)
                [animation stop];
        }
    }
}

- (void)step:(id<TTataDelegate>)delegate time:(long long)time {
    // step of self
    for (TAnimation *animation in self.animations) {
        if (animation.run_executing) {
            [animation step:delegate time:time];
        }
    }
    
    // step of child
    for (TLayer *child in self.childs) {
        [child step:delegate time:time];
    }
}

@end
