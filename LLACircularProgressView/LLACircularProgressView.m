//
//  LLACircularProgressView.m
//  LLACircularProgressView
//
//  Created by Lukas Lipka on 26/10/13.
//  Copyright (c) 2013 Lukas Lipka. All rights reserved.
//

#import "LLACircularProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import <Availability.h>

@interface LLACircularProgressView ()

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@end

@implementation LLACircularProgressView

@synthesize progressTintColor = _progressTintColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.contentMode = UIViewContentModeRedraw;
//    self.backgroundColor = [UIColor whiteColor];

    _pieStyle = NO;
    _reversePie = NO;
    
    
    self.progressTintColor = [UIColor greenColor];
    
    _progressTintColor = [UIColor blackColor];
    
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.backgroundColor = [UIColor clearColor].CGColor;
    _progressLayer.strokeColor = self.progressTintColor.CGColor;
    _progressLayer.strokeEnd = 0;
    
    _progressLayer.fillColor = _pieStyle ? self.progressTintColor.CGColor : nil;
    
    _progressLayer.fillColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BookInfoProgressBar"]].CGColor;
    
    _progressLayer.lineWidth = 3;
    
    
    [self.layer addSublayer:_progressLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.progressLayer.frame = self.bounds;

    [self updatePath];
}

- (void)drawRect:(CGRect)rect {
    if (!self.pieStyle) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(ctx, self.progressTintColor.CGColor);
        CGContextSetStrokeColorWithColor(ctx, self.progressTintColor.CGColor);
        CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, 1, 1));
        
        CGRect stopRect;
        stopRect.origin.x = CGRectGetMidX(self.bounds) - self.bounds.size.width / 8;
        stopRect.origin.y = CGRectGetMidY(self.bounds) - self.bounds.size.height / 8;
        stopRect.size.width = self.bounds.size.width / 4;
        stopRect.size.height = self.bounds.size.height / 4;
        CGContextFillRect(ctx, CGRectIntegral(stopRect));
    }
}

#pragma mark - Accessors

- (void)setPieStyle:(BOOL)pieStyle {
    _pieStyle = pieStyle;
    self.progressLayer.fillColor = _pieStyle ? self.progressTintColor.CGColor : nil;
    
//    UIImage* image = [UIImage imageNamed:@"BookInfoProgressBar"];
//    CGSize size = self.progressLayer.frame.size;
//    NSLog(@"----%f-----%f", size.width, size.height);
//    self.progressLayer.fillColor = [UIColor colorWithPatternImage:image].CGColor;
    
    self.progressLayer.contents = (id)[UIImage imageNamed:@"BookInfoProgressBar"].CGImage;
    
    [self setNeedsDisplay];
}

- (void)setReversePie:(BOOL)reversePie {
    _reversePie = reversePie;
    [self setNeedsDisplay];
}

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    _progress = progress;
    
    if (self.pieStyle) {
        [self updatePath];
    } else {
        if (progress > 0) {
            if (animated) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
                animation.fromValue = self.progress == 0 ? @0 : nil;
                animation.toValue = [NSNumber numberWithFloat:progress];
                animation.duration = 0.5;
                self.progressLayer.strokeEnd = progress;
                [self.progressLayer addAnimation:animation forKey:@"animation"];
            } else {
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                self.progressLayer.strokeEnd = progress;
                [CATransaction commit];
            }
        } else {
            self.progressLayer.strokeEnd = 0.0f;
            [self.progressLayer removeAnimationForKey:@"animation"];
        }
    }
}

- (UIColor *)progressTintColor {
#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(tintColor)]) {
        return self.tintColor;
    }
#endif
    return _progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
#ifdef __IPHONE_7_0
    if ([self respondsToSelector:@selector(setTintColor:)]) {
        self.tintColor = progressTintColor;
        self.progressLayer.fillColor = _pieStyle ? progressTintColor.CGColor : nil;
        
        return;
    }
#endif
    _progressTintColor = progressTintColor;
    self.progressLayer.strokeColor = progressTintColor.CGColor;
    self.progressLayer.fillColor = _pieStyle ? progressTintColor.CGColor : nil;
    
    [self setNeedsDisplay];
}

#pragma mark - Other

#ifdef __IPHONE_7_0
- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
    self.progressLayer.fillColor = _pieStyle ? self.tintColor.CGColor : nil;
    
    [self setNeedsDisplay];
}
#endif

#pragma mark - Private

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    if (self.pieStyle) {

        UIBezierPath* path = [UIBezierPath bezierPath];
//        [path moveToPoint:center];
//        [path addLineToPoint:CGPointMake(center.x, center.y - self.bounds.size.width / 2)];
//
//        if (!_reversePie)
//            [path addArcWithCenter:center radius:self.bounds.size.width / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI * _progress clockwise:YES];
//        else
//            [path addArcWithCenter:center radius:self.bounds.size.width / 2 startAngle:-M_PI_2 endAngle:-M_PI_2 - 2 * M_PI * (1 - _progress) clockwise:NO];
//        
//        [path closePath];
        
        
//        path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(0.0, self.progressLayer.frame.size.height*0.15)];
//        
//        [path addLineToPoint:CGPointMake(self.progressLayer.frame.size.width*_progress, self.progressLayer.frame.size.height*0.15)];
//        [path addLineToPoint:CGPointMake(self.progressLayer.frame.size.width*_progress, self.progressLayer.frame.size.height*0.85)];
//        [path addLineToPoint:CGPointMake(0.0, self.progressLayer.frame.size.height*0.85)];
//        [path addLineToPoint:CGPointMake(0.0, self.progressLayer.frame.size.height*0.15)];
        UIImage *image = [UIImage imageNamed:@"BookInfoProgressProcessBar"];
        
        path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.progressLayer.frame.size.width*0.02, self.progressLayer.frame.size.height*0.15, (self.progressLayer.frame.size.width-self.progressLayer.frame.size.width*0.04)*_progress, self.progressLayer.frame.size.height*0.7) cornerRadius:self.progressLayer.frame.size.height*0.35];
        
        [path addClip];
        [image drawAtPoint:CGPointZero];
        
        self.progressLayer.path = path.CGPath;
        

    } else {
        self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:self.bounds.size.width / 2 - 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
    }
}

@end
