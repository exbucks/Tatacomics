//
//  TDocument.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TOOL_NONE           0
#define TOOL_SELECT         1
#define TOOL_HAND           2
#define TOOL_TEXT           3
#define TOOL_BOUNDING       4
#define TOOL_AVATAR         5
#define TOOL_PUZZLE         6

@class SMXMLElement;
@class TSceneManager;
@class TLibraryManager;
@class TScene;
@class TActor;
@class TLayer;

@interface TDocument : NSObject

@property (strong) TSceneManager*     sceneManager;
@property (strong) TLibraryManager*   libraryManager;

@property (copy) NSString*          identifier;

@property (copy) NSString*          backgroundMusic;
@property (assign) int              backgroundMusicVolume;

@property (assign) int              navigationButtonDelayTime;
@property (assign) BOOL             navigationLeftButtonRender;
@property (assign) BOOL             navigationRightButtonRender;

@property (copy) NSString*          prevSceneButton;
@property (copy) NSString*          nextSceneButton;

@property (copy) NSString*          avatarDefault;
@property (copy) NSString*          avatarFrame;
@property (copy) NSString*          avatarMask;

@property (assign) BOOL             modified;
@property (copy) NSString*          filePath;
@property (copy) NSString*          fileName;
@property (copy) NSString*          directory;

@property (assign) int              currentTool;
@property (assign) int              currentTempTool;
@property (assign) float            zoom;
@property (assign) CGPoint          offset;

@property (strong) NSMutableArray*      selectedItems;
@property (assign) CGAffineTransform    workspaceMatrix;

@property (strong) UIImage*     run_avatar;

- (BOOL)parseXml:(SMXMLElement*)xml;
- (SMXMLElement*)toXml;

- (NSString*)getImagesDirectoryPath;
- (NSString*)getSoundsDirectoryPath;

- (void)checkProjectDirectories;
- (BOOL)open:(NSString*)path;
- (BOOL)save;
- (BOOL)save:(NSString*)filePathName;
- (void)export:(NSString*)filePathName;

- (void)drawWorkspace:(CGContextRef)context width:(float)width height:(float)height;
- (void)drawSelectedBound:(CGContextRef)context;

- (TScene*)currentScene;
- (TScene*)prevScene:(TScene*)scene;
- (TScene*)nextScene:(TScene*)scene;
- (TScene*)findScene:(NSString*)sceneName;

- (BOOL)haveSelection;
- (TActor*)selectedActor;
- (TLayer*)selectedLayer;
- (NSArray*)selectedBound;

- (UIImage*)getAvatarImage;
- (UIImage*)getAvatarFrameImage;
- (UIImage*)getAvatarMaskImage;

- (BOOL)containsInSelection:(CGPoint)pos;
- (int)partOfSelection:(CGPoint)pos cursor:(int*)cursor;
- (void)clearSelectedItems;
- (void)toggleSelectedItem:(TActor*)item;
- (void)moveSelectedItems:(CGPoint)distance fixedMove:(BOOL)fixedMove;
- (void)moveAnchorOfSelectedItem:(CGPoint)distance fixedMove:(BOOL)fixedMove;
- (void)scaleSelectedItems:(CGPoint)distance part:(int)part fixedRatio:(BOOL)fixedRatio;
- (void)rotateSelectedItems:(float)angle fixedAngle:(BOOL)fixedAngle;
- (void)rotateSelectedItemsTo:(float)angle;
- (BOOL)resizeSelectedTextActor:(CGPoint)distance part:(int)part;
- (void)moveInteractionBound:(CGPoint)distance fixedMove:(BOOL)fixedMove;
- (void)scaleInteractionBound:(CGPoint)distance part:(int)part fixedRatio:(BOOL)fixedRatio;

- (TActor*)actorAtScreenPosition:(CGPoint)pos withinInteraction:(BOOL)withinInteraction;
- (int)activeTool;
- (void)transferLayer:(TActor*)item target:(TLayer*)target;

- (BOOL)isUsingImage:(NSString*)image;
- (BOOL)isUsingSound:(NSString*)sound;

@end
