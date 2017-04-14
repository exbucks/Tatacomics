//
//  TDocument.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "TDocument.h"
#import "SMXMLDocument.h"
#import "TUtil.h"
#import "TSceneManager.h"
#import "TLibraryManager.h"
#import "TScene.h"

@implementation TDocument

- (id)init {
    if (self = [super init]) {
        // create managers
        self.sceneManager = [[TSceneManager alloc] initWithDocument:self];
        self.libraryManager = [[TLibraryManager alloc] initWithDocument:self];
        
        // setting
        self.identifier = @"";
        
        self.backgroundMusic = @"";
        self.backgroundMusicVolume = 100;
        
        self.navigationButtonDelayTime = 5;
        self.navigationLeftButtonRender = true;
        self.navigationRightButtonRender = true;
        
        self.prevSceneButton = @"";
        self.nextSceneButton = @"";
        self.avatarDefault = @"";
        self.avatarFrame = @"";
        self.avatarMask = @"";
        
        // properties
        self.modified = NO;
        self.filePath = nil;
        self.fileName = @"Untitled";
        self.directory = nil;
        
        self.currentTool = TOOL_SELECT;
        self.currentTempTool = TOOL_NONE;
        self.zoom = DEFAULT_ZOOM;
        self.offset = CGPointMake(0, 0);
        
        self.selectedItems = [[NSMutableArray alloc] init];
        self.workspaceMatrix = CGAffineTransformIdentity;
        
        self.run_avatar = nil;
    }
    
    return self;
}

- (BOOL)parseXml:(SMXMLElement*)xml {
    if (xml == nil || ![xml.name isEqualToString:@"Document"])
        return false;
    
    self.identifier             = [TUtil parseStringXElement:[xml childNamed:@"Identifier"] default:@""];
    self.backgroundMusic        = [TUtil parseStringXElement:[xml childNamed:@"BackgroundMusic"] default:@""];
    self.backgroundMusicVolume  = [TUtil parseIntXElement:[xml childNamed:@"BackgroundMusicVolume"] default:100];
    self.navigationButtonDelayTime = [TUtil parseIntXElement:[xml childNamed:@"NavigationButtonDelayTime"] default:5];
    self.navigationLeftButtonRender = [TUtil parseBoolXElement:[xml childNamed:@"NavigationLeftButtonRender"] default:true];
    self.navigationRightButtonRender = [TUtil parseBoolXElement:[xml childNamed:@"NavigationRightButtonRender"] default:true];
    self.prevSceneButton        = [TUtil parseStringXElement:[xml childNamed:@"PrevSceneButton"] default:@""];
    self.nextSceneButton        = [TUtil parseStringXElement:[xml childNamed:@"NextSceneButton"] default:@""];
    self.avatarDefault          = [TUtil parseStringXElement:[xml childNamed:@"AvatarDefault"] default:@""];
    self.avatarFrame            = [TUtil parseStringXElement:[xml childNamed:@"AvatarFrame"] default:@""];
    self.avatarMask             = [TUtil parseStringXElement:[xml childNamed:@"AvatarMask"] default:@""];
    
    return
        [self.libraryManager parseXml:[xml childNamed:@"Libraries"]] &&
        [self.sceneManager parseXml:[xml childNamed:@"Scenes"]];
}

- (SMXMLElement*)toXml {
    NOT_IMPLEMENTED_METHOD
}

- (NSString*)getImagesDirectoryPath {
    return [self.directory stringByAppendingPathComponent:@"images"];
}

- (NSString*)getSoundsDirectoryPath {
    return [self.directory stringByAppendingPathComponent:@"sounds"];
}

- (void)checkProjectDirectories {

#if !TARGET_OS_IPHONE
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // project folder
    if (![fileManager fileExistsAtPath:self.directory])
        [fileManager createDirectoryAtPath:self.directory withIntermediateDirectories:NO attributes:nil error:&error];
    
    if (![fileManager fileExistsAtPath:[self getImagesDirectoryPath]])
        [fileManager createDirectoryAtPath:[self getImagesDirectoryPath] withIntermediateDirectories:NO attributes:nil error:&error];
    
    if (![fileManager fileExistsAtPath:[self getSoundsDirectoryPath]])
        [fileManager createDirectoryAtPath:[self getSoundsDirectoryPath] withIntermediateDirectories:NO attributes:nil error:&error];
    
#endif

}

- (BOOL)open:(NSString*)path {
    @try {
        self.filePath = path;
        self.fileName = [path lastPathComponent];
        self.directory = [path stringByDeletingLastPathComponent];
        
        // check project directories
        [self checkProjectDirectories];
        
        NSError *error;
        SMXMLDocument *xDoc = [SMXMLDocument documentWithData:[NSData dataWithContentsOfFile:path] error:&error];

        if (error) {
            NSLog(@"Error while parsing the document: %@", error);
            return NO;
        }
        
        return [self parseXml:xDoc];
        
    } @catch (NSException* exception) {
        NSLog(@"Document loading was failed: %@", [exception description]);
    }
    
    return NO;
}

- (BOOL)save {
    NOT_IMPLEMENTED_METHOD
}

- (BOOL)save:(NSString*)filePathName {
    NOT_IMPLEMENTED_METHOD
}

- (void)export:(NSString*)filePathName {
    NOT_IMPLEMENTED_METHOD
}

- (void)drawWorkspace:(CGContextRef)context width:(float)width height:(float)height {
    // clear workspace
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    TScene* scene = [self currentScene];
    if (scene != nil) {
        // calc matrix
        CGAffineTransform m = CGAffineTransformIdentity;
        m = CGAffineTransformTranslate(m, width / 2 + self.offset.x, height / 2 + self.offset.y);
        m = CGAffineTransformScale(m, self.zoom, self.zoom);
        m = CGAffineTransformTranslate(m, -0.5 * BOOK_WIDTH, -0.5 * BOOK_HEIGHT);
        self.workspaceMatrix = m;
        
        // border of work area
        CGRect border = CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);
        border = CGRectApplyAffineTransform(border, self.workspaceMatrix);
        border = CGRectInset(border, -1, -1);
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:198/255.0 green:198/255.0 blue:198/255.0 alpha:1].CGColor);
        CGContextStrokeRect(context, border);
        
        // save graphics state
        CGContextSaveGState(context);

        // apply matrix
        CGContextConcatCTM(context, self.workspaceMatrix);
        
        // draw scene
        [scene drawInContext:context];
        
        // restore graphics
        CGContextRestoreGState(context);
        
        // draw selected bound
        [self drawSelectedBound:context];
    }
}

- (void)drawSelectedBound:(CGContextRef)context {
    NOT_IMPLEMENTED_METHOD
}

- (TScene*)currentScene {
    return [self.sceneManager scene:self.sceneManager.currentSceneIndex];
}

- (TScene*)prevScene:(TScene*)scene {
    int sceneIndex = [self.sceneManager indexOfScene:scene.name];
    if (sceneIndex > 0)
        return [self.sceneManager scene:sceneIndex - 1];
    else
        return [self.sceneManager scene:[self.sceneManager sceneCount] - 1];
}

- (TScene*)nextScene:(TScene*)scene {
    int sceneIndex = [self.sceneManager indexOfScene:scene.name];
    if (sceneIndex + 1 < [self.sceneManager sceneCount])
        return [self.sceneManager scene:sceneIndex + 1];
    else
        return [self.sceneManager scene:0];
}

- (TScene*)findScene:(NSString*)sceneName {
    return [self.sceneManager scene:[self.sceneManager indexOfScene:sceneName]];
}

- (BOOL)haveSelection {
    return self.selectedItems.count > 0;
}

- (TActor*)selectedActor {
    if (self.selectedItems.count == 1)
        return [self.selectedItems objectAtIndex:0];
    
    return nil;
}

- (TLayer*)selectedLayer {
    if (self.selectedItems.count == 0)
        return [self currentScene];
    else if (self.selectedItems.count == 1)
        return [self.selectedItems objectAtIndex:0];
    return nil;
}

// get the bound that contain the selected items based on real drawing canvas coordinates
- (NSArray*)selectedBound {
    if (self.selectedItems.count == 0)
        return nil;
    if (self.selectedItems.count == 1)
        return [[self.selectedItems objectAtIndex:0] boundOnScreen];
    
    CGRect b = [[self.selectedItems objectAtIndex:0] boundStraightOnScreen];
    for (TLayer* layer in self.selectedItems) {
        b = CGRectUnion(b, [layer boundStraightOnScreen]);
    }
    
    CGPoint p1 = CGPointMake(b.origin.x, b.origin.y);
    CGPoint p2 = CGPointMake(b.origin.x + b.size.width, b.origin.y);
    CGPoint p3 = CGPointMake(b.origin.x + b.size.width, b.origin.y + b.size.height);
    CGPoint p4 = CGPointMake(b.origin.x, b.origin.y + b.size.height);
    return @[[NSValue valueWithCGPoint:p1], [NSValue valueWithCGPoint:p2], [NSValue valueWithCGPoint:p3], [NSValue valueWithCGPoint:p4]];
}

- (UIImage*)getAvatarImage {
    if (self.run_avatar != nil)
        return self.run_avatar;
    
    int avatarIndex = [self.libraryManager imageIndex:self.avatarDefault];
    if (avatarIndex == -1)
        return [UIImage imageNamed:@"avatar_default"];
    else
        return [UIImage imageWithContentsOfFile:[self.libraryManager imageFilePath:avatarIndex]];
}

- (UIImage*)getAvatarFrameImage {
    int index = [self.libraryManager imageIndex:self.avatarFrame];
    if (index == -1)
        return [UIImage imageNamed:@"avatar_frame"];
    else
        return [UIImage imageWithContentsOfFile:[self.libraryManager imageFilePath:index]];
}

- (UIImage*)getAvatarMaskImage {
    int index = [self.libraryManager imageIndex:self.avatarMask];
    if (index == -1)
        return [UIImage imageNamed:@"avatar_mask"];
    else
        return [UIImage imageWithContentsOfFile:[self.libraryManager imageFilePath:index]];
}

- (BOOL)containsInSelection:(CGPoint)pos {
    return [TUtil isInPolygon:[self selectedBound] point:pos];
}

//============== return value ===============//
//
//                    -1
//      9                           9
//        ┌───────────────────────┐
//        │ 1         8         4 │
//        │                       │
//  -1    │ 5         0         7 │    -1
//        │                       │
//        │ 2         6         3 │
//        └───────────────────────┘
//      9                           9
//                    -1
//
//
// Anchor Point : 10
//============================================//
- (int)partOfSelection:(CGPoint)pos cursor:(int*)cursor {
    NOT_IMPLEMENTED_METHOD
}

- (void)clearSelectedItems {
    [self.selectedItems removeAllObjects];
}

- (void)toggleSelectedItem:(TActor*)item {
    if ([self.selectedItems containsObject:item])
        [self.selectedItems removeObject:item];
    else
        [self.selectedItems addObject:item];
}

// move the selected items the specified delta, parameters are based on real drawing canvas coordinates
- (void)moveSelectedItems:(CGPoint)distance fixedMove:(BOOL)fixedMove {
    NOT_IMPLEMENTED_METHOD
}

// move the anchor point of selected item the specified delta, parameters are based on real drawing canvas coordinates
- (void)moveAnchorOfSelectedItem:(CGPoint)distance fixedMove:(BOOL)fixedMove {
    NOT_IMPLEMENTED_METHOD
}

// scale the selected items the specified delta, parameters are based on real drawing canvas coordinates
- (void)scaleSelectedItems:(CGPoint)distance part:(int)part fixedRatio:(BOOL)fixedRatio {
    NOT_IMPLEMENTED_METHOD
}

// rotate the selected item the specified angle, the angle is degree
- (void)rotateSelectedItems:(float)angle fixedAngle:(BOOL)fixedAngle {
    NOT_IMPLEMENTED_METHOD
}

// rotate the selected item to the specified angle, the angle is degree
- (void)rotateSelectedItemsTo:(float)angle {
    NOT_IMPLEMENTED_METHOD
}

// scale the selected text actor the specified delta, parameters are based on real drawing canvas coordinates
- (BOOL)resizeSelectedTextActor:(CGPoint)distance part:(int)part {
    NOT_IMPLEMENTED_METHOD
}

// move the selected items the specified delta, parameters are based on real drawing canvas coordinates
- (void)moveInteractionBound:(CGPoint)distance fixedMove:(BOOL)fixedMove {
    NOT_IMPLEMENTED_METHOD
}

// scale the selected items the specified delta, parameters are based on real drawing canvas coordinates
- (void)scaleInteractionBound:(CGPoint)distance part:(int)part fixedRatio:(BOOL)fixedRatio {
    NOT_IMPLEMENTED_METHOD
}

// move the puzzle area of selected items the specified delta, parameters are based on real drawing canvas coordinates
- (void)movePuzzleArea:(CGPoint)distance fixedMove:(BOOL)fixedMove {
    NOT_IMPLEMENTED_METHOD
}

// scale the puzzle area of selected items the specified delta, parameters are based on real drawing canvas coordinates
- (void)scalePuzzleArea:(CGPoint)distance part:(int)part fixedRatio:(BOOL)fixedRatio {
    NOT_IMPLEMENTED_METHOD
}

// find top layer at specified position, parameters are based on real drawing canvas coordinates
- (TActor*)actorAtScreenPosition:(CGPoint)pos withinInteraction:(BOOL)withinInteraction {
    NOT_IMPLEMENTED_METHOD
}

- (int)activeTool {
    if (self.currentTempTool != TOOL_NONE)
        return self.currentTempTool;
    return self.currentTool;
}

- (void)transferLayer:(TActor*)item target:(TLayer*)target {
    NOT_IMPLEMENTED_METHOD
}

- (BOOL)isUsingImage:(NSString*)image {
    // check document properties
    if ([self.prevSceneButton isEqualToString:image] || [self.nextSceneButton isEqualToString:image])
        return YES;
    if ([self.avatarDefault isEqualToString:image] || [self.avatarFrame isEqualToString:image] || [self.avatarMask isEqualToString:image])
        return YES;
    
    // check scenes
    for (int i = 0; i < [self.sceneManager sceneCount]; i++) {
        TScene* scene = [self.sceneManager scene:i];
        if ([scene isUsingImage:image])
            return YES;
    }
    
    return NO;
}

- (BOOL)isUsingSound:(NSString*)sound {
    // check document properties
    if ([self.backgroundMusic isEqualToString:sound])
        return YES;
    
    // check scenes
    for (int i = 0; i < [self.sceneManager sceneCount]; i++) {
        TScene* scene = [self.sceneManager scene:i];
        if ([scene isUsingSound:sound])
            return YES;
    }
    
    return NO;
}


@end
