//
//  TActor.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActor.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TAction.h"
#import "TActionIntervalMove.h"
#import "TScene.h"
#import "TTataDelegate.h"

@implementation TActor

@synthesize interactionBound = _interactionBound;
@synthesize puzzleArea = _puzzleArea;

#pragma mark - Property Methods

- (void)setLocation:(CGPoint)value {
    [CATransaction setDisableActions:YES];
    [self setValue:[NSValue valueWithCGPoint:value] forKeyPath:@"position"];
}

- (CGPoint)location {
    return [[self valueForKeyPath:@"position"] CGPointValue];
}

- (void)setScale:(CGSize)value {
    [CATransaction setDisableActions:YES];
    [self setValue:@(value.width) forKeyPath:@"transform.scale.x"];
    [self setValue:@(value.height) forKeyPath:@"transform.scale.y"];
}

- (CGSize)scale {
    float w, h;
    w = [[self valueForKeyPath:@"transform.scale.x"] floatValue];
    h = [[self valueForKeyPath:@"transform.scale.y"] floatValue];
    
    return CGSizeMake(w, h);
}

- (void)setSkew:(CGSize)value {
//    CGAffineTransform shearTransform = CGAffineTransformMake(1, value.height, 0, value.width, 0, 0);
//    self.affineTransform = CGAffineTransformConcat(shearTransform, self.affineTransform);
}

- (CGSize)skew {
    return CGSizeMake(0, 0);
}

- (void)setRotation:(float)value {
    [CATransaction setDisableActions:YES];
    [self setValue:@(value * M_PI / 180) forKeyPath:@"transform.rotation.z"];
}

- (float)rotation {
    float a = [[self valueForKeyPath:@"transform.rotation.z"] floatValue];
    
    a = a * 180 / M_PI;
    a = roundf(a * 1000000) / 1000000;
    return a;
}

- (void)setInteractionBound:(CGRect)value {
    self.autoInteractionBound = NO;
    _interactionBound = value;
}

- (CGRect)interactionBound {
    if (self.autoInteractionBound)
        return [self bound];
    else
        return _interactionBound;
}

- (void)setPuzzleArea:(CGRect)value {
    self.puzzle = YES;
    _puzzleArea = value;
}

- (CGRect)puzzleArea {
    return _puzzleArea;
}

#pragma mark - TActor Methods

- (id)initWithDocument:(TDocument*)document {
    if (self = [super initWithDocument:document]) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.location = CGPointZero;
        self.scale = CGSizeMake(1, 1);
        self.skew = CGSizeMake(0, 0);
        self.rotation = 0;
        self.zPosition = 0;
        _draggable = NO;
        _acceleratorSensibility = NO;
        _autoInteractionBound = YES;
        _interactionBound = CGRectZero;
        _puzzle = NO;
        _puzzleArea = CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);

//        self.matrix = CGAffineTransformIdentity;
        
        _backupActor = nil;
        
        self.run_xVelocity = 0;
        self.run_yVelocity = 0;
    }
    
    return self;
}

- (id)initWithDocument:(TDocument*)document x:(float)x y:(float)y parent:(TLayer*)parent name:(NSString*)name {
    if (self = [super initWithDocument:document parent:parent name:name]) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.location = CGPointMake(x, y);
        self.scale = CGSizeMake(1, 1);
        self.skew = CGSizeMake(0, 0);
        self.rotation = 0;
        self.zPosition = 0;
        _draggable = NO;
        _acceleratorSensibility = NO;
        _autoInteractionBound = YES;
        _interactionBound = CGRectZero;
        _puzzle = NO;
        _puzzleArea = CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);
        
//        self.matrix = CGAffineTransformIdentity;
        
        _backupActor = nil;
        
        self.run_xVelocity = 0;
        self.run_yVelocity = 0;
    }
    
    return self;
}

- (void)clone:(TLayer*)target {
    [super clone:target];
    
    TActor* targetLayer = (TActor*)target;
    targetLayer.anchorPoint             = self.anchorPoint;
    targetLayer.location                = self.location;
    targetLayer.scale                   = self.scale;
    targetLayer.skew                    = self.skew;
    targetLayer.rotation                = self.rotation;
    targetLayer.zPosition               = self.zPosition;
    targetLayer.draggable               = self.draggable;
    targetLayer.acceleratorSensibility  = self.acceleratorSensibility;
    targetLayer.interactionBound        = self.interactionBound;
    targetLayer.autoInteractionBound    = self.autoInteractionBound;
//    targetLayer.matrix                  = self.matrix;
    
    targetLayer.puzzleArea              = self.puzzleArea;
    targetLayer.puzzle                  = self.puzzle;
}

- (BOOL)parseXml:(SMXMLElement*)xml parent:(TLayer*)parent {
    if (xml == nil)
        return NO;
    
    if (![super parseXml:xml parent:parent])
        return NO;
    
    float f1, f2;
    
    @try {
        f1 = [TUtil parseFloatXElement:[xml childNamed:@"AnchorX"] default:0.5];
        f2 = [TUtil parseFloatXElement:[xml childNamed:@"AnchorY"] default:0.5];
        self.anchorPoint = CGPointMake(f1, f2);
        
        f1 = [TUtil parseFloatXElement:[xml childNamed:@"PositionX"] default:0];
        f2 = [TUtil parseFloatXElement:[xml childNamed:@"PositionY"] default:0];
        self.location = CGPointMake(f1, f2);
        
        f1 = [TUtil parseFloatXElement:[xml childNamed:@"ScaleWidth"] default:1];
        f2 = [TUtil parseFloatXElement:[xml childNamed:@"ScaleHeight"] default:1];
        self.scale = CGSizeMake(f1, f2);
        
        f1 = [TUtil parseFloatXElement:[xml childNamed:@"SkewWidth"] default:0];
        f2 = [TUtil parseFloatXElement:[xml childNamed:@"SkewHeight"] default:0];
        self.skew = CGSizeMake(f1, f2);
        
        self.rotation = [TUtil parseFloatXElement:[xml childNamed:@"Rotation"] default:0];
        
        self.zPosition = [TUtil parseIntXElement:[xml childNamed:@"ZIndex"] default:0];
        
        _draggable                      = [TUtil parseBoolXElement:[xml childNamed:@"Draggable"] default:NO];
        _acceleratorSensibility         = [TUtil parseBoolXElement:[xml childNamed:@"AcceleratorSensibility"] default:NO];
        
        _autoInteractionBound           = [TUtil parseBoolXElement:[xml childNamed:@"AutoInteractionBound"] default:YES];
        _interactionBound.origin.x      = [TUtil parseFloatXElement:[xml childNamed:@"InteractionBoundX"] default:0];
        _interactionBound.origin.y      = [TUtil parseFloatXElement:[xml childNamed:@"InteractionBoundY"] default:0];
        _interactionBound.size.width    = [TUtil parseFloatXElement:[xml childNamed:@"InteractionBoundWidth"] default:0];
        _interactionBound.size.height   = [TUtil parseFloatXElement:[xml childNamed:@"InteractionBoundHeight"] default:0];

        _puzzle                         = [TUtil parseBoolXElement:[xml childNamed:@"Puzzle"] default:NO];
        _puzzleArea.origin.x            = [TUtil parseFloatXElement:[xml childNamed:@"PuzzleAreaX"] default:0];
        _puzzleArea.origin.y            = [TUtil parseFloatXElement:[xml childNamed:@"PuzzleAreaY"] default:0];
        _puzzleArea.size.width          = [TUtil parseFloatXElement:[xml childNamed:@"PuzzleAreaWidth"] default:BOOK_WIDTH];
        _puzzleArea.size.height         = [TUtil parseFloatXElement:[xml childNamed:@"PuzzleAreaHeight"] default:BOOK_HEIGHT];
        
//        [self refreshMatrix];
        return YES;
        
    } @catch (NSException* ex) {
        NSLog(@"error in parseXml: %@", ex);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (void)createBackup {
    _backupActor = (TActor*)[self clone];
}

- (void)deleteBackup {
    _backupActor = nil;
}

- (TActor*)actorAtScreenPosition:(CGPoint)pos withinInteraction:(BOOL)withinInteraction {
    
    if (self.alpha <= 0.001)
        return nil;
    
    // recursive find
    NSArray* items = [self sortedChilds];
    for (TLayer* item in items) {
        TActor* ret = [item actorAtScreenPosition:pos withinInteraction:withinInteraction];
        if (ret != nil)
            return ret;
    }
    
    // local coordinates
    CGPoint p = [self convertPoint:pos fromLayer:[self ownerScene]];
    CGRect b = withinInteraction ? self.interactionBound : [self bound];
    if (CGRectContainsPoint(b, p))
        return self;
    else
        return nil;
}

- (float)rotationOnScreen {
    if (self.parent != nil && [self.parent isKindOfClass:TActor.class])
        return [(TActor*)self.parent rotationOnScreen] + self.rotation;
    else
        return self.rotation;
}

- (NSArray*)interactionBoundOnScreen {
    TScene* scene = [self ownerScene];
    CGRect b = self.interactionBound;
    CGPoint p1 = [self convertPoint:CGPointMake(b.origin.x, b.origin.y) toLayer:scene];
    CGPoint p2 = [self convertPoint:CGPointMake(b.origin.x + b.size.width, b.origin.y) toLayer:scene];
    CGPoint p3 = [self convertPoint:CGPointMake(b.origin.x + b.size.width, b.origin.y + b.size.height) toLayer:scene];
    CGPoint p4 = [self convertPoint:CGPointMake(b.origin.x, b.origin.y + b.size.height) toLayer:scene];
    
    return @[[NSValue valueWithCGPoint:p1], [NSValue valueWithCGPoint:p2], [NSValue valueWithCGPoint:p3], [NSValue valueWithCGPoint:p4]];
}

- (NSArray*)puzzleAreaOnScreen {
    CGRect b = self.puzzleArea;
    CGPoint p1 = b.origin;
    CGPoint p2 = CGPointMake(b.origin.x + b.size.width, b.origin.y);
    CGPoint p3 = CGPointMake(b.origin.x + b.size.width, b.origin.y + b.size.height);
    CGPoint p4 = CGPointMake(b.origin.x, b.origin.y + b.size.height);
    
    return @[[NSValue valueWithCGPoint:p1], [NSValue valueWithCGPoint:p2], [NSValue valueWithCGPoint:p3], [NSValue valueWithCGPoint:p4]];
}

- (NSArray*)getDefaultEvents {
    return @[DEFAULT_EVENT_TOUCH, DEFAULT_EVENT_ENTER, DEFAULT_EVENT_DRAGGING, DEFAULT_EVENT_DROP, DEFAULT_EVENT_PUZZLE_SUCCESS, DEFAULT_EVENT_PUZZLE_FAIL];
}

- (NSArray*)getDefaultStates {
    return @[DEFAULT_STATE_DEFAULT];
}

- (BOOL)isMoving {
    for (TAnimation* animation in self.animations) {
        int sequenceCount = [animation numberOfSequences];
        if (animation.run_executing) {
            for (int i = 0; i < sequenceCount; i++) {
                TSequence* sequence = [animation sequenceAtIndex:i];
                int actionCount = [sequence numberOfActions];
                for (int j = 0; j < actionCount; j++) {
                    TAction* action = [sequence actionAtIndex:j];
                    if ([action isKindOfClass:TActionIntervalMove.class])
                        return YES;
                }
            }
        }
    }
    
    return NO;
}

- (void)step:(id<TTataDelegate>)delegate time:(long long)time {

    // process for accelerator sensibility actor
    if (self.acceleratorSensibility && ![self isMoving]) {
        
        // elapsed time
        float elapsed = [delegate.accelerationWatch elapsedMilliseconds] / 1000.0f;
        self.run_xVelocity += delegate.acceleration.x * elapsed;
        self.run_yVelocity += delegate.acceleration.y * elapsed;

        CGFloat xDelta = elapsed * self.run_xVelocity * 500;
        CGFloat yDelta = elapsed * self.run_yVelocity * 500;

        CGPoint point = [self.parent logicalToScreen:self.location];
        point = CGPointMake(point.x + xDelta, point.y + yDelta);

        // try assign location with new position
        self.location = [self.parent screenToLogical:point];
        
        // check collision of new bound with boundaries
        CGPoint d = [self collisionWithBoundaries:[self boundStraightOnScreen]];
        
        // correct based on collision
        point = CGPointMake(point.x + d.x, point.y + d.y);
        
        self.location = [self.parent screenToLogical:point];
    }
    
    [super step:delegate time:time];
}

- (CGPoint)collisionWithBoundaries:(CGRect)frame {
    
    float dx = 0, dy = 0;
    
    if (frame.origin.x < 0) {
        dx = -frame.origin.x;
        self.run_xVelocity = -(self.run_xVelocity / 2.0);
    }
    
    if (frame.origin.y < 0) {
        dy = -frame.origin.y;
        self.run_yVelocity = -(self.run_yVelocity / 2.0);
    }
    
    if (frame.origin.x > BOOK_WIDTH - frame.size.width) {
        dx = BOOK_WIDTH - frame.size.width - frame.origin.x;
        self.run_xVelocity = -(self.run_xVelocity / 2.0);
    }
    
    if (frame.origin.y > BOOK_HEIGHT - frame.size.height) {
        dy = BOOK_HEIGHT - frame.size.height - frame.origin.y;
        self.run_yVelocity = -(self.run_yVelocity / 2.0);
    }
    
    return CGPointMake(dx, dy);
}

@end
