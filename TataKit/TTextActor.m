//
//  TTextActor.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TTextActor.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TScene.h"
#import <CoreText/CoreText.h>

@implementation TTextActor {
    UIImage* imgContents;
}

#pragma mark - Property Methods

- (void)setBoxSize:(CGSize)value {
    self.bounds = CGRectMake(0, 0, value.width, value.height);
}

- (CGSize)boxSize {
    return self.bounds.size;
}

#pragma mark - TTextActor Methods

- (id)initWithDocument:(TDocument*)document {
    if (self = [super initWithDocument:document]) {
        self.text = @"";
        self.font = [UIFont systemFontOfSize:12];
        self.color = [UIColor blackColor];
        self.boxSize = CGSizeZero;
        [self updateContents];
    }
    
    return self;
}

- (id)initWithDocument:(TDocument*)document text:(NSString*)text position:(CGPoint)position box:(CGSize)box parent:(TLayer*)parent name:(NSString*)name {
    if (self = [super initWithDocument:document x:position.x y:position.y parent:parent name:name]) {
        self.text = text;
        self.font = [UIFont systemFontOfSize:12];
        self.color = [UIColor blackColor];
        self.boxSize = box;
        [self updateContents];
    }
    
    return self;
}

- (void)clone:(TLayer*)target {
    [super clone:target];
    
    TTextActor* targetLayer = (TTextActor*)target;
    targetLayer.text = self.text;
    targetLayer.font = self.font;
    targetLayer.color = self.color;
    targetLayer.boxSize = self.boxSize;

    [targetLayer updateContents];
}

- (BOOL)parseXml:(SMXMLElement*)xml parent:(TLayer*)parent {
    if (xml == nil || ![xml.name isEqualToString:@"TextActor"])
        return NO;
    
    if (![super parseXml:xml parent:parent])
        return NO;
    
    @try {
        self.text = [TUtil parseStringXElement:[xml childNamed:@"Text"] default:@""];
        
        NSString* fontName = [TUtil parseStringXElement:[xml childNamed:@"FontFamilyName"] default:@""];
        float fontSize = [TUtil parseFloatXElement:[xml childNamed:@"FontSize"] default:12];
        self.font = [UIFont fontWithName:fontName size:fontSize];
        if (self.font == nil)
            self.font = [UIFont systemFontOfSize:fontSize];
        
        self.color = [TUtil parseColorXElement:[xml childNamed:@"Color"] default:[UIColor blackColor]];
        
        float w = [TUtil parseFloatXElement:[xml childNamed:@"SizeWidth"] default:0];
        float h= [TUtil parseFloatXElement:[xml childNamed:@"SizeHeight"] default:0];
        self.boxSize = CGSizeMake(w, h);

        [self updateContents];
        
        return YES;
    } @catch (NSException* e) {
        return NO;
    }
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (void)updateContents {
    if (self.boxSize.width > 0 && self.boxSize.height > 0) {
        // create context
        UIGraphicsBeginImageContext( self.boxSize );
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // draw scene
        [self draw:context];
        
        // complete
        UIImage *picture = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *data = UIImagePNGRepresentation(picture);
        imgContents = [UIImage imageWithData:data];
        
        self.contents = (id)imgContents.CGImage;
//        self.borderWidth = 1;
//        self.borderColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1].CGColor;
    } else {
        self.contents = nil;
    }
}

- (void)draw:(CGContextRef)context {
    // save graphics state
    CGContextSaveGState(context);
    
    TScene* scene = [self ownerScene];
    if (scene == nil || scene.run_delegate == nil || scene.run_delegate.textOn) {
        
        CGRect r = CGRectMake(0, 0, self.boxSize.width, self.boxSize.height + self.font.pointSize * 1.5); // fontSize * 1.5 is for avoiding not draw when height is smaller than text line
        
        //====================================== begin to draw text =================================================//
        // Flip the context coordinates, in iOS only.
        CGContextTranslateCTM(context, 0, r.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // Initializing a graphic context in OS X is different:
        // CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        
        // Set the text matrix.
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        // Create a path which bounds the area where you will be drawing text.
        // The path need not be rectangular.
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, r);
        
        // Create a mutable attributed string with a max length of 0.
        // The max length is a hint as to how much internal storage to reserve.
        // 0 means no hint.
        CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
        
        // Copy the textString into the newly created attrString
        CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (__bridge CFStringRef)self.text);
        
        // Set the color
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, self.text.length), kCTForegroundColorAttributeName, self.color.CGColor);

        // Set Font
        CTFontRef font = CTFontCreateWithName( (CFStringRef)self.font.fontName, self.font.pointSize * 1.5, NULL);
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, self.text.length), kCTFontAttributeName, font);
        
        // Paragraph Style
//        CGFloat minLineHeight = 60.0;
//        CGFloat maxLineHeight = 60.0;
        
        CTTextAlignment paragraphAlignment = kCTLeftTextAlignment;
//        CTLineBreakMode lineBrkMode = kCTLineBreakByWordWrapping;
        
        CTParagraphStyleSetting paragraphSetting[1] = {
            {kCTParagraphStyleSpecifierAlignment, sizeof(CTTextAlignment), &paragraphAlignment},
//            {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minLineHeight},
//            {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &maxLineHeight},
//            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBrkMode}
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphSetting, 1);
        CFAttributedStringSetAttribute(attrString, CFRangeMake(0, self.text.length), kCTParagraphStyleAttributeName, paragraphStyle);
        
        // Create the framesetter with the attributed string.
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
        CFRelease(attrString);
        
        // Create a frame.
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        
        // Draw the specified frame in the given context.
        CTFrameDraw(frame, context);
        
        // Release the objects we used.
        CFRelease(paragraphStyle);
        CFRelease(font);
        CFRelease(frame);
        CFRelease(path);
        CFRelease(framesetter);
        //====================================== end drawing text ====================================================//
    }
    
//    // draw childs
//    NSArray* items = [self sortedChilds];
//    for (TActor* item in items) {
//        [item draw:context];
//    }

    // restore graphics state
    CGContextRestoreGState(context);
}

- (CGRect)bound {
    return CGRectMake(0, 0, self.boxSize.width, self.boxSize.height);
}

@end
