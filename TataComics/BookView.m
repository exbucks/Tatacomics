//
//  BookView.m
//  TataViewer
//
//  Created by Albert Li on 10/18/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "BookView.h"
#import "BookViewController.h"
#import "TUtil.h"
#import "TScene.h"

@implementation BookView

- (UIViewController*)viewController
{
    for (UIView* next = self; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
        {
            return (UIViewController*)nextResponder;
        }
    }
    
    return nil;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    if ( [self.delegate respondsToSelector:@selector(drawRectOnBook:context:rect:)] ) {
        [self.delegate drawRectOnBook:self context:context rect:rect];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( [self.delegate respondsToSelector:@selector(touchesBeganOnBook:touches:withEvent:)] ) {
        [self.delegate touchesBeganOnBook:self touches:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( [self.delegate respondsToSelector:@selector(touchesMovedOnBook:touches:withEvent:)] ) {
        [self.delegate touchesMovedOnBook:self touches:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( [self.delegate respondsToSelector:@selector(touchesEndedOnBook:touches:withEvent:)] ) {
        [self.delegate touchesEndedOnBook:self touches:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( [self.delegate respondsToSelector:@selector(touchesCancelledOnBook:touches:withEvent:)] ) {
        [self.delegate touchesCancelledOnBook:self touches:touches withEvent:event];
    }
}

@end
