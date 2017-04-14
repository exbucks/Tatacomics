//
//  BookView.h
//  TataViewer
//
//  Created by Albert Li on 10/18/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BookViewDelegate;

#pragma mark - BookView

@interface BookView : UIView

@property (nonatomic, assign) id<BookViewDelegate> delegate;

@end

#pragma mark - BookViewDelegate

@protocol BookViewDelegate <NSObject>

@optional

- (void)drawRectOnBook:(BookView *)view context:(CGContextRef)context rect:(CGRect)rect;
- (void)touchesBeganOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMovedOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEndedOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelledOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event;

@end
