//
//  TUtil.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SCENE_THUMBNAIL_WIDTH               131
#define SCENE_THUMBNAIL_HEIGHT              98

#define DEFAULT_ZOOM                        0.75
#define BOOK_WIDTH                          1024
#define BOOK_HEIGHT                         768

#define NAVBUTTON_STRETH                    true
#define NAVBUTTON_WIDTH                     100
#define NAVBUTTON_HEIGHT                    80

// Default Events
#define DEFAULT_EVENT_UNDEFINED             @"Undefined"
#define DEFAULT_EVENT_ENTER                 @"Enter"
#define DEFAULT_EVENT_AUTOPLAY              @"AutoPlay"
#define DEFAULT_EVENT_TOUCH                 @"Touch"
#define DEFAULT_EVENT_DRAGGING              @"Dragging"
#define DEFAULT_EVENT_DROP                  @"Drop"
#define DEFAULT_EVENT_PUZZLE_SUCCESS        @"PuzzleSuccess"
#define DEFAULT_EVENT_PUZZLE_FAIL           @"PuzzleFail"

// Default States
#define DEFAULT_STATE_DEFAULT               @"Default"

#define ABSTRACT_METHOD             @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil];
#define NOT_IMPLEMENTED_METHOD      @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must implement %@", NSStringFromSelector(_cmd)] userInfo:nil];

// iOS Version Checking
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@class SMXMLElement;

@interface TUtil : NSObject

+ (float)dotProductWithPos1:(CGPoint)pt1 pos2:(CGPoint)pt2;
+ (float)dotProductWithX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2;
+ (CGPoint)rotatePosition:(CGPoint)pos center:(CGPoint)center angle:(float)angle;
+ (float)angleBetweenVector:(CGPoint)u andVector:(CGPoint)v;

+ (BOOL)isInPolygon:(NSArray*)poly point:(CGPoint)point;
+ (BOOL)isLinesIntersectWithPoint1:(CGPoint)pt1 point2:(CGPoint)pt2 point3:(CGPoint)pt3 point4:(CGPoint)pt4;
+ (BOOL)isPolygonsIntersectWithFirst:(NSArray*)poly1 second:(NSArray*)poly2;
+ (float)distanceBetweenPoint:(CGPoint)pt linePoint1:(CGPoint)linePt1 linePoint2:(CGPoint)linePt2;
+ (float)distanceBetweenPoint:(CGPoint)pt1 andPoint:(CGPoint)pt2;
+ (BOOL)isPointProjectionInLineSegmentWithPoint:(CGPoint)pt linePoint1:(CGPoint)linePt1 linePoint2:(CGPoint)linePt2;

+ (float)normalizeRadianAngle:(float)angle;
+ (float)normalizeDegreeAngle:(float)angle;
+ (CGRect)positiveRectangle:(CGRect)rect;
+ (NSArray*)vertexesOfRectangle:(CGRect)rect;
+ (UIColor*)percentColor:(UIColor*)color percent:(float)percent;

+ (BOOL)isSerializable:(NSObject*)obj;

+ (UIImage*)resizedImage:(UIImage*)image size:(CGSize)size stretch:(BOOL)stretch;
+ (UIImage*)preloadedImage:(UIImage *)image;

+ (NSString*)getTemporaryDirectory ;

+ (NSString*)parseStringXElement:(SMXMLElement*)e default:(NSString*)def;
+ (int)parseIntXElement:(SMXMLElement*)e default:(int)def;
+ (long long)parseLongXElement:(SMXMLElement*)e default:(long long)def;
+ (float)parseFloatXElement:(SMXMLElement*)e default:(float)def;
+ (BOOL)parseBoolXElement:(SMXMLElement*)e default:(BOOL)def;
+ (UIColor*)parseColorXElement:(SMXMLElement*)e default:(UIColor*)def;

@end

@interface UIResponder (Hierarchy)

- (BOOL)isChildOf:(UIResponder*)parent;
- (UIViewController*)ownerForm;
- (UIResponder*)findAncestorControl:(Class)type;

@end