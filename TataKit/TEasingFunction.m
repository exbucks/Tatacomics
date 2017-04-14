//
//  TEasingFunction.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TEasingFunction.h"

@implementation TEasingFunction

- (id)init {
    if (self = [super init]) {
        // EaseExponential
        self.exponent = 10;
        
        // EaseBounce
        self.bounces = 4;
        self.bounciness = 3;
        
        // EaseElastic
        self.oscillations = 3;
        self.springiness = 3.0;
        
        // EaseBack
        self.amplitude = 0.5;
    }
    
    return self;
}

- (float)easeByType:(EasingType)type mode:(EasingMode)mode duration:(float)duration time:(float)time start:(float)startVal end:(float)endVal {
    float normalizedTime = duration > 0 ? time / duration : 1;
    float deltaVal = endVal - startVal;
    return (float)(startVal + deltaVal * [self easeByType:type mode:mode normalizedTime:normalizedTime]);
}

// Transforms normalized time to control the pace of an animation
- (double)easeByType:(EasingType)type mode:(EasingMode)mode normalizedTime:(double)normalizedTime {
    switch (mode) {
        case EasingModeIn:
            return [self easeByType:type normalizedTime:normalizedTime];
            
        case EasingModeOut:
            // EaseOut is the same as EaseIn, except time is reversed & the result is flipped.
            return 1 - [self easeByType:type normalizedTime:(1 - normalizedTime)];
            
        case EasingModeInOut:
        default:
            // EaseInOut is a combination of EaseIn & EaseOut fit to the 0-1, 0-1 range.
            if (normalizedTime < 0.5f)
                return [self easeByType:type normalizedTime:normalizedTime * 2] * 0.5;
            else
                return (1 - [self easeByType:type normalizedTime:(1 - normalizedTime) * 2]) * 0.5 + 0.5;
    }
}

// Calculate easing function case when EasingMode.In
- (double)easeByType:(EasingType)type normalizedTime:(double)normalizedTime {
    switch (type) {
        case EasingTypeExponential:
            return [self easeExponential:normalizedTime];
        case EasingTypeSine:
            return [self easeSine:normalizedTime];
        case EasingTypeElastic:
            return [self easeElastic:normalizedTime];
        case EasingTypeBounce:
            return [self easeBounce:normalizedTime];
        case EasingTypeBack:
            return [self easeBack:normalizedTime];
        case EasingTypeNone:
        default:
            return [self easeLinear:normalizedTime];
    }
}

- (double)easeLinear:(double)t {
    return t;
}

- (double)easeExponential:(double)t {
    return (exp(self.exponent * t) - 1) / (exp(self.exponent) - 1);
}

- (double)easeSine:(double)t {
    return 1 - sin((1 - t) * M_PI_2);
}

- (double)easeElastic:(double)t {
    double expo;
    if (fabs(self.springiness) < 10 * DBL_EPSILON)
        expo = t;
    else
        expo = (exp(self.springiness * t) - 1) / (exp(self.springiness) - 1);
    
    return expo * sin((M_PI * 2.0 * self.oscillations + M_PI_2) * t);
}

- (double)easeBounce:(double)t {
    // Clamp the bounciness so we dont hit a divide by zero
    if (self.bounciness < 1.0 || fabs(self.bounciness - 1.0) < 10.0 * DBL_EPSILON) {
        // Make it just over one.  In practice, this will look like 1.0 but avoid divide by zeros.
        self.bounciness = 1.001;
    }
    
    double p = pow(self.bounciness, self.bounces);
    double oneMinusBounciness = 1.0 - self.bounciness;
    
    // 'unit' space calculations.
    // Our bounces grow in the x axis exponentially.  we define the first bounce as having a 'unit' width of 1.0 and compute
    // the total number of 'units' using a geometric series.
    // We then compute which 'unit' the current time is in.
    double sumOfUnits = (1.0 - p) / oneMinusBounciness + p * 0.5; // geometric series with only half the last sum
    double unitAtT = t * sumOfUnits;
    
    // 'bounce' space calculations.
    // Now that we know which 'unit' the current time is in, we can determine which bounce we're in by solving the geometric equation:
    // unitAtT = (1 - bounciness^bounce) / (1 - bounciness), for bounce.
    double bounceAtT =  log(-unitAtT * (1.0 - self.bounciness) + 1.0) / log(self.bounciness);
    double start = floor(bounceAtT);
    double end = start + 1.0;
    
    // 'time' space calculations.
    // We then project the start and end of the bounce into 'time' space
    double startTime = (1.0 - pow(self.bounciness, start)) / (oneMinusBounciness * sumOfUnits);
    double endTime = (1.0 - pow(self.bounciness, end)) / (oneMinusBounciness * sumOfUnits);
    
    // Curve fitting for bounce.
    double midTime = (startTime + endTime) * 0.5;
    double timeRelativeToPeak = t - midTime;
    double radius = midTime - startTime;
    double amplitude = pow(1.0 / self.bounciness, (self.bounces - start));
    
    // Evaluate a quadratic that hits (startTime,0), (endTime, 0), and peaks at amplitude.
    return (-amplitude / (radius * radius)) * (timeRelativeToPeak - radius) * (timeRelativeToPeak + radius);
}

- (double)easeBack:(double)t {
    return pow(t, 3) - t * self.amplitude * sin(t * M_PI);
}

- (double)easeCircle:(double)t {
    return 1 - sqrt(1 - t * t);
}

- (double)easeQuadratic:(double)t {
    return pow(t, 2);
}

- (double)easeCubic:(double)t {
    return pow(t, 3);
}

- (double)easeQuartic:(double)t {
    return pow(t, 4);
}

- (double)easeQuintic:(double)t {
    return pow(t, 5);
}


@end
