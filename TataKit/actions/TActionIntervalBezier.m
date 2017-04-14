//
//  TActionIntervalBezier.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TActionIntervalBezier.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TAnimation.h"
#import "TSequence.h"
#import "TActor.h"
#import "TLayer.h"

@implementation TActionIntervalBezier {
    CGPoint run_point0;
    CGPoint run_point1;
    CGPoint run_point2;
    CGPoint run_point3;
    TEasingFunction* run_easingFunction;
}

- (id)init {
    if (self = [super init]) {
        self.name = @"Bezier";
        self.startingColor = [UIColor colorWithRed:255/255.0 green:230/255.0 blue:205/255.0 alpha:1];
        self.endingColor = [UIColor colorWithRed:255/255.0 green:222/255.0 blue:189/255.0 alpha:1];
        self.icon = [UIImage imageNamed:@"icon_action_bezier"];
        
        self.type = BezierActionTypeTo;
        self.point1 = CGPointZero;
        self.point2 = CGPointZero;
        self.point3 = CGPointZero;
        self.easingType = EasingTypeNone;
        self.easingMode = EasingModeIn;
    }
    
    return self;
}

- (void)clone:(TAction *)target {
    [super clone:target];
    
    TActionIntervalBezier* targetAction = (TActionIntervalBezier*)target;
    targetAction.type = self.type;
    targetAction.point1 = self.point1;
    targetAction.point2 = self.point2;
    targetAction.point3 = self.point3;
    targetAction.easingType = self.easingType;
    targetAction.easingMode = self.easingMode;
}

- (BOOL)parseXml:(SMXMLElement *)xml {
    if (xml == nil || ![xml.name isEqualToString:@"ActionIntervalBezier"])
        return NO;
    
    if (![super parseXml:xml])
        return NO;
    
    @try {
        _type       = [TUtil parseIntXElement:[xml childNamed:@"Type"] default:BezierActionTypeTo];
        _point1.x   = [TUtil parseFloatXElement:[xml childNamed:@"Point1X"] default:0];
        _point1.y   = [TUtil parseFloatXElement:[xml childNamed:@"Point1Y"] default:0];
        _point2.x   = [TUtil parseFloatXElement:[xml childNamed:@"Point2X"] default:0];
        _point2.y   = [TUtil parseFloatXElement:[xml childNamed:@"Point2Y"] default:0];
        _point3.x   = [TUtil parseFloatXElement:[xml childNamed:@"Point3X"] default:0];
        _point3.y   = [TUtil parseFloatXElement:[xml childNamed:@"Point3Y"] default:0];
        _easingType = [TUtil parseIntXElement:[xml childNamed:@"EasingType"] default:EasingTypeNone];
        _easingMode = [TUtil parseIntXElement:[xml childNamed:@"EasingMode"] default:EasingModeIn];

        return YES;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

#pragma mark - Launch Methods

- (void)reset:(long long)time {
    [super reset:time];
    
    TLayer* layer = self.sequence.animation.layer;
    if ([layer isKindOfClass:TActor.class]) {
        TActor* target = (TActor*)layer;
        if (self.type == BezierActionTypeTo) {
            run_point0 = target.location;
            run_point1 = self.point1;
            run_point2 = self.point2;
            run_point3 = self.point3;
        } else if (self.type == BezierActionTypeBy) {
            run_point0 = target.location;
            run_point1 = CGPointMake(target.location.x + self.point1.x, target.location.y + self.point1.y);
            run_point2 = CGPointMake(target.location.x + self.point2.x, target.location.y + self.point2.y);
            run_point3 = CGPointMake(target.location.x + self.point3.x, target.location.y + self.point3.y);
        }
        
        run_easingFunction = [[TEasingFunction alloc] init];
    }
}

- (BOOL)step:(id<TTataDelegate>)delegate time:(long long)time {
    
    float elapsed = time - self.run_startTime;
    if (elapsed > self.duration)
        elapsed = self.duration;
    
    TLayer* layer = self.sequence.animation.layer;
    if ([layer isKindOfClass:TActor.class]) {
        TActor* target = (TActor*)layer;
        float t = [run_easingFunction easeByType:self.easingType mode:self.easingMode duration:self.duration time:elapsed start:0 end:1];
        target.location = [self bezier:t];
    }
    
    return [super step:delegate time:time];
}

- (CGPoint)bezier:(float)t {
    float x = pow(1 - t, 3) * run_point0.x + 3 * pow(1 - t, 2) * t * run_point1.x + 3 * (1 - t) * pow(t, 2) * run_point2.x + pow(t, 3) * run_point3.x;
    float y = pow(1 - t, 3) * run_point0.y + 3 * pow(1 - t, 2) * t * run_point1.y + 3 * (1 - t) * pow(t, 2) * run_point2.y + pow(t, 3) * run_point3.y;
    return CGPointMake(x, y);
}

@end
