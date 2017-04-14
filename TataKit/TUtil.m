//
//  TUtil.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TUtil.h"
#import "SMXMLDocument.h"

@implementation TUtil

+ (float)dotProductWithPos1:(CGPoint)pt1 pos2:(CGPoint)pt2 {
    return pt1.x * pt2.x + pt1.y * pt2.y;
}

+ (float)dotProductWithX1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 {
    return x1 * x2 + y1 * y2;
}

+ (CGPoint)rotatePosition:(CGPoint)pos center:(CGPoint)center angle:(float)angle {
    float x = (float)(center.x + (pos.x - center.x) * cos(angle) - (pos.y - center.y) * sin(angle));
    float y = (float)(center.y + (pos.x - center.x) * sin(angle) + (pos.y - center.y) * cos(angle));
    return CGPointMake(x, y);
}

+ (float)angleBetweenVector:(CGPoint)u andVector:(CGPoint)v {
    return atan2f(v.y, v.x) - atan2f(u.y, u.x);
}

+ (BOOL)isInPolygon:(NSArray*)poly point:(CGPoint)point {
    int i, j;
    BOOL c = NO;
    int nvert = (int)poly.count;
    for (i = 0, j = nvert-1; i < nvert; j = i++) {
        CGPoint vert1 = [[poly objectAtIndex:i] CGPointValue];
        CGPoint vert2 = [[poly objectAtIndex:j] CGPointValue];
        
        if (((vert1.y > point.y) != (vert2.y > point.y)) &&
            (point.x < (vert2.x - vert1.x) * (point.y - vert1.y) / (vert2.y - vert1.y) + vert1.x) )
            c = !c;
    }
    
    return c;
}


// Returns true if the lines intersect, otherwise false. In addition, if the lines
// intersect the intersection point may be stored in the floats i_x and i_y.
+ (BOOL)isLinesIntersectWithPoint1:(CGPoint)pt1 point2:(CGPoint)pt2 point3:(CGPoint)pt3 point4:(CGPoint)pt4 {
    float s1_x, s1_y, s2_x, s2_y;
    s1_x = pt2.x - pt1.x; s1_y = pt2.y - pt1.y;
    s2_x = pt4.x - pt3.x; s2_y = pt4.y - pt3.y;
    
    float s, t;
    s = (-s1_y * (pt1.x - pt3.x) + s1_x * (pt1.y - pt3.y)) / (-s2_x * s1_y + s1_x * s2_y);
    t = (s2_x * (pt1.y - pt3.y) - s2_y * (pt1.x - pt3.x)) / (-s2_x * s1_y + s1_x * s2_y);
    
    if (s >= 0 && s <= 1 && t >= 0 && t <= 1) {
        // Collision detected
        // float i_x = pt1.x + (t * s1_x);
        // float i_y = pt1.y + (t * s1_y);
        return YES;
    }
    
    return NO; // No collision
}

+ (BOOL)isPolygonsIntersectWithFirst:(NSArray*)poly1 second:(NSArray*)poly2 {
    for (NSValue* vert1 in poly1) {
        if ([self isInPolygon:poly2 point:[vert1 CGPointValue]])
            return YES;
    }

    for (NSValue* vert2 in poly2) {
        if ([self isInPolygon:poly1 point:[vert2 CGPointValue]])
            return YES;
    }

    for (int i = 0; i < poly1.count; i++) {
        // line of first polygon
        CGPoint pt1 = [[poly1 objectAtIndex:i] CGPointValue];
        CGPoint pt2 = [[poly1 objectAtIndex:((i + 1) % poly1.count)] CGPointValue];
        
        // line of second polygon
        for (int j = 0; j < poly2.count; j++) {
            CGPoint pt3 = [[poly2 objectAtIndex:j] CGPointValue];
            CGPoint pt4 = [[poly2 objectAtIndex:((j + 1) % poly2.count)] CGPointValue];
            
            if ([self isLinesIntersectWithPoint1:pt1 point2:pt2 point3:pt3 point4:pt4])
                return YES;
        }
    }
    
    return NO;
}

+ (float)distanceBetweenPoint:(CGPoint)pt linePoint1:(CGPoint)linePt1 linePoint2:(CGPoint)linePt2 {
    //   | (x2 - x1) (y1 - y0) - (x1 - x0) (y2 - y1) |
    // -------------------------------------------------
    //        ,--------------------------------
    //      \/  (x2 - x1) ^ 2 + (y2 - y1) ^ 2
    float x0 = pt.x, y0 = pt.y;
    float x1 = linePt1.x, y1 = linePt1.y;
    float x2 = linePt2.x, y2 = linePt2.y;
    return (float)(fabs((x2 - x1) * (y1 - y0) - (x1 - x0) * (y2 - y1)) / sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2)));
}

+ (float)distanceBetweenPoint:(CGPoint)pt1 andPoint:(CGPoint)pt2 {
    return (float)sqrt(pow(pt2.x - pt1.x, 2) + pow(pt2.y - pt1.y, 2));
}

+ (BOOL)isPointProjectionInLineSegmentWithPoint:(CGPoint)pt linePoint1:(CGPoint)linePt1 linePoint2:(CGPoint)linePt2 {
    float a = [self dotProductWithX1:(pt.x - linePt1.x) y1:(pt.y - linePt1.y) x2:(linePt2.x - linePt1.x) y2:(linePt2.y - linePt1.y)];
    float b = [self dotProductWithX1:(pt.x - linePt2.x) y1:(pt.y - linePt2.y) x2:(linePt1.x - linePt2.x) y2:(linePt1.y - linePt2.y)];
    return a >= 0 && b >= 0;
}

+ (float)normalizeRadianAngle:(float)angle {
    while (angle >= 2 * M_PI)
        angle -= (float)(2 * M_PI);
    while (angle < 0)
        angle += (float)(2 * M_PI);
    return angle;
}

+ (float)normalizeDegreeAngle:(float)angle {
    while (angle >= 360)
        angle -= 360;
    while (angle < 0)
        angle += 360;
    return angle;
}

+ (CGRect)positiveRectangle:(CGRect)rect {
    return CGRectStandardize(rect);
}

+ (NSArray*)vertexesOfRectangle:(CGRect)rect {
    return @[
             [NSValue valueWithCGPoint:CGPointMake(rect.origin.x, rect.origin.y)],
             [NSValue valueWithCGPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)],
             [NSValue valueWithCGPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height)],
             [NSValue valueWithCGPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)]
    ];
}

+ (UIColor*)percentColor:(UIColor*)color percent:(float)percent {
    CGFloat a, r, g, b;
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    r *= percent;
    g *= percent;
    b *= percent;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (BOOL)isSerializable:(NSObject*)obj {
    NOT_IMPLEMENTED_METHOD
}

// return the resized image of specified image with size parameter
// if stretch is true, image will be stretched, else image will keep the ratio.
+ (UIImage*)resizedImage:(UIImage*)image size:(CGSize)size stretch:(BOOL)stretch {
    int width, height;
    if (stretch) {
        width = size.width;
        height = size.height;
    } else {
        double s = fmin((double)size.width / image.size.width, (double)size.height / image.size.height);
        width = (int)(image.size.width * s);
        height = (int)(image.size.height * s);
    }
    
    CGRect rect = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext( rect.size );
    [image drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img = [UIImage imageWithData:imageData];
    
    return img;
}

+ (UIImage*)preloadedImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    
    // make a bitmap context of a suitable size to draw to, forcing decode
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext =  CGBitmapContextCreate(NULL, width, height, 8, width * 4, colourSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colourSpace);
    
    // draw the image to the context, release it
    CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), imageRef);
    
    // now get an image ref from the context
    CGImageRef outputImage = CGBitmapContextCreateImage(imageContext);
    
    UIImage *cachedImage = [UIImage imageWithCGImage:outputImage];
    
    // clean up
    CGImageRelease(outputImage);
    CGContextRelease(imageContext);
    
    return cachedImage;
}

+ (NSString*)getTemporaryDirectory {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* tempDirectory;
    
    do {
        tempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID new] UUIDString]];
    } while ([fileManager fileExistsAtPath:tempDirectory]);
    
    @try {
        NSError* error;
        if ([fileManager createDirectoryAtPath:tempDirectory withIntermediateDirectories:NO attributes:nil error:&error])
            return tempDirectory;
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        return nil;
    }
    
    return nil;
}

#pragma mark - parse xml

+ (NSString*) parseStringXElement:(SMXMLElement*)e default:(NSString*)def {
    if (e == nil || e.value == nil)
        return def;
    return e.value;
}

+ (int) parseIntXElement:(SMXMLElement*)e default:(int)def {
    if (e == nil || e.value == nil)
        return def;
    
    NSScanner* scan = [NSScanner scannerWithString:e.value];
    int temp;
    if ([scan scanInt:&temp] && [scan isAtEnd])
        return temp;
    else
        return def;
}

+ (long long) parseLongXElement:(SMXMLElement*)e default:(long long)def {
    if (e == nil || e.value == nil)
        return def;
    
    NSScanner* scan = [NSScanner scannerWithString:e.value];
    long long temp;
    if ([scan scanLongLong:&temp] && [scan isAtEnd])
        return temp;
    else
        return def;
}

+ (float) parseFloatXElement:(SMXMLElement*)e default:(float)def {
    if (e == nil || e.value == nil)
        return def;
    
    NSScanner* scan = [NSScanner scannerWithString:e.value];
    float temp;
    if ([scan scanFloat:&temp] && [scan isAtEnd])
        return temp;
    else
        return def;
}

+ (BOOL) parseBoolXElement:(SMXMLElement*)e default:(BOOL)def {
    if (e == nil || e.value == nil)
        return def;
    
    if ([e.value caseInsensitiveCompare:@"true"] == NSOrderedSame)
        return YES;
    else if ([e.value caseInsensitiveCompare:@"false"] == NSOrderedSame)
        return NO;
    
    return def;
}

+ (UIColor*)parseColorXElement:(SMXMLElement*)e default:(UIColor*)def {
    if (e == nil || e.value == nil)
        return def;
    
    int color = [TUtil parseIntXElement:e default:0xFF000000];
    int blue = color & 0xff;
    int green = color >> 8 & 0xff;
    int red = color >> 16 & 0xff;
    int alpha = color >> 24 & 0xff;
    return [UIColor colorWithRed:red/255.f green:green/255.f blue:blue/255.f alpha:alpha/255.f];
}

@end


@implementation UIResponder (Hierarchy)

- (BOOL)isChildOf:(UIResponder*)parent {
    UIResponder* next = [self nextResponder];
    return (next != nil && next == parent) || (next != nil ? [next isChildOf:parent] : NO);
}

- (UIViewController*)ownerForm {
    if ([self isKindOfClass:[UIViewController class]])
        return (UIViewController*)self;
    else if ([self nextResponder] != nil)
        return [[self nextResponder] ownerForm];
    else
        return nil;
}

- (UIResponder*)findAncestorControl:(Class)type {
    if ([self isMemberOfClass:type])
        return self;
    else if ([self nextResponder] != nil)
        return [[self nextResponder] findAncestorControl:type];
    else
        return nil;
}

@end