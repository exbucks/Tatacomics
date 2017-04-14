//
//  BookViewController.m
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "BookViewController.h"
#import "AppSettings.h"
#import "BookView.h"

#import "TLibraryManager.h"
#import "TSoundEmulator.h"
#import "TUtil.h"
#import "TStopwatch.h"

#import "TDocument.h"
#import "TScene.h"
#import "TImageActor.h"
#import "TActor.h"

#import "TAnimation.h"
#import "TSequence.h"
#import "TActionInstantGoScene.h"
#import "TActionInstantDispatchEvent.h"
#import "TActionIntervalFade.h"
#import "TActionIntervalMove.h"
#import "TActionIntervalDelay.h"
#import "TActionIntervalScale.h"
#import "TActionRuntime.h"
#import "TEasingFunction.h"

#import "AvatarViewController.h"

typedef NS_ENUM(NSInteger, MenuState) {
    MenuStateDefault,
    MenuStateHelp,
};

@interface BookViewController () {
    BOOL                needInit;
    
    CALayer*            bookLayer;
    CALayer*            backgroundLayer;
    
    TDocument*          document;
    TSoundEmulator*     soundEmulator;

    UIImage*            imgMenuButton;
    UIImage*            imgPrevButton;
    UIImage*            imgNextButton;
    
    TScene*             currentScene;
    TScene*             nextScene;
    
    BOOL                bgmOn;
    BOOL                effectOn;
    BOOL                voiceOn;
    
    TStopwatch*         sw;
    NSObject*           locker;
    NSTimer*            timerStep;
    
    BOOL                mousePressed;
    CGPoint             mouseDownPos;
    TActor*             mouseDownActor;

    MenuState           menuState;

    void                (^transitionDelegate)(long long);
    long long           transitionStartTime;
    
    NSMutableArray*     extraAnimations;
    
    ////////////////////// Accelerator Sensitivity ///////////////////////
    CMMotionManager*    motionManager;
    NSOperationQueue*   queue;
}

@end

@implementation BookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    soundEmulator = nil;
    
    currentScene = nil;
    nextScene = nil;
    
    bgmOn = YES;
    effectOn = YES;
    voiceOn = YES;
    _textOn = YES;
    
    sw = [[TStopwatch alloc] init];
    locker = [[NSObject alloc] init];
    timerStep = nil;
    
    mousePressed = NO;
    mouseDownPos = CGPointMake(0, 0);
    mouseDownActor = nil;
    
    extraAnimations = [[NSMutableArray alloc] init];
    
    // Initialize for accelerator
    [self initAccelerometer];
    
    imgMenuButton = [UIImage imageNamed:@"emulator_img_menu_button"];

    [self.bookView setDelegate:self];
    
    bookLayer = [CALayer layer];
    [self.bookView.layer addSublayer:bookLayer];
    
    needInit = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (needInit) {
        needInit = NO;
        [self initBookViewer];
    }

    if (self.isBeingPresented) {
        [[AppSettings sharedInstance] pauseBGM];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.isBeingDismissed) {
        [self exitBookViewer];
        
        if (bookLayer != nil) {
            [bookLayer removeFromSuperlayer];
            bookLayer = nil;
        }
        
        [[AppSettings sharedInstance] playBGM];
    }

    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (document != nil)
        [document.libraryManager clearImageCaches];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)initAccelerometer {
    self.accelerationWatch = [[TStopwatch alloc] init];
    queue = [[NSOperationQueue alloc] init];
    motionManager = [[CMMotionManager alloc]  init];
    motionManager.accelerometerUpdateInterval = 0.02f;
    [motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        
        // check the orientation of device
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CMAcceleration acceleration = { .x = accelerometerData.acceleration.y, .y = accelerometerData.acceleration.x };
            self.acceleration = acceleration;
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CMAcceleration acceleration = { .x = -accelerometerData.acceleration.y, .y = -accelerometerData.acceleration.x };
            self.acceleration = acceleration;
        } else {
            CMAcceleration acceleration = { .x = accelerometerData.acceleration.x, .y = accelerometerData.acceleration.y };
            self.acceleration = acceleration;
        }
        
    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Book View Events

- (void)touchesBeganOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event {
    if (currentScene == nil)
        return;
    
    if (touches.count == 1 && transitionDelegate == nil) {
        // get touch
        UITouch *touch = [touches anyObject];
        
        // set flag that mouse is pressed and store position
        mousePressed = YES;
        mouseDownPos = [touch locationInView:view];
        mouseDownPos = [view.layer convertPoint:mouseDownPos toLayer:bookLayer];
        
        // traget item
        TActor* selectedActor = [currentScene actorAtScreenPosition:mouseDownPos withinInteraction:YES];
        if (selectedActor != nil) {
            // fire touch event
            mouseDownActor = selectedActor;
            [mouseDownActor fireEvent:DEFAULT_EVENT_TOUCH recursive:NO];
            
            // fire drag event
            if (mouseDownActor.draggable || mouseDownActor.puzzle) {
                [mouseDownActor createBackup];
            }
        }
    }
}

- (void)touchesMovedOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event {
    if (currentScene == nil)
        return;
    
    if (touches.count == 1 && mousePressed) {
        // get touch
        UITouch *touch = [touches anyObject];
        CGPoint cp = [touch locationInView:view];
        cp = [view.layer convertPoint:cp toLayer:bookLayer];
        
        // if have selection, move it
        if (mouseDownActor != nil && (mouseDownActor.draggable || mouseDownActor.puzzle)) {
            CGPoint p = [mouseDownActor.parent logicalToScreen:mouseDownActor.location];
            p.x += cp.x - mouseDownPos.x;
            p.y += cp.y - mouseDownPos.y;
            
            // if clicked actor has accelorator sensitibility, set velocity
            if (mouseDownActor.acceleratorSensibility) {
                mouseDownActor.run_xVelocity = (cp.x - mouseDownPos.x) / 20;
                mouseDownActor.run_yVelocity = (cp.y - mouseDownPos.y) / 20;
            }
            
            mouseDownActor.location = [mouseDownActor.parent screenToLogical:p];
            
            // fire dragging event
            [mouseDownActor fireEvent:DEFAULT_EVENT_DRAGGING recursive:NO];
        }
        
        // update mouse position
        mouseDownPos = cp;
    }
}

- (void)touchesEndedOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event {
    if (currentScene == nil)
        return;
    
    if (touches.count == 1 && mousePressed) {
        if (mouseDownActor != nil) {
            // fire drop event
            [mouseDownActor fireEvent:DEFAULT_EVENT_DROP recursive:NO];
            
            // check this actor is puzzle actor
            if (mouseDownActor.puzzle && ![mouseDownActor isMoving]) {
                NSArray* bound1 = [mouseDownActor interactionBoundOnScreen];
                
                // check if the puzzle actor went the correct puzzle area
                if ([TUtil isPolygonsIntersectWithFirst:bound1 second:[mouseDownActor puzzleAreaOnScreen]]) {
                    
                    // turn off the puzzle function after success
                    mouseDownActor.puzzle = NO;
                    
                    // fire puzzle success event
                    [mouseDownActor fireEvent:DEFAULT_EVENT_PUZZLE_SUCCESS recursive:NO];
                } else {
                    // if puzzle is failed, actor return to original position
                    TAnimation* animation = [[TAnimation alloc] initWithLayer:mouseDownActor];
                    TSequence* sequence = [animation addSequence];

                    TActionIntervalMove* action1 = [[TActionIntervalMove alloc] init];
                    action1.duration = 300;
                    action1.position = mouseDownActor.backupActor.position;
                    [sequence addAction:action1];

                    TActionInstantDispatchEvent* action2 = [[TActionInstantDispatchEvent alloc] init];
                    action2.actor = mouseDownActor.name;
                    action2.event = DEFAULT_EVENT_PUZZLE_FAIL;
                    action2.recursive = NO;
                    [sequence addAction:action2];
                    
                    [animation start];
                    [extraAnimations addObject:animation];
                }
            }
            
            [mouseDownActor deleteBackup];
        }
        
        mousePressed = NO;
        mouseDownActor = nil;
    }
}

- (void)touchesCancelledOnBook:(BookView *)view touches:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self touchesEndedOnBook:view touches:touches withEvent:event];
}

#pragma mark - Book Viewer

- (NSString*)rect2String:(CGRect)rect {
    return [NSString stringWithFormat:@"%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

- (CGRect)rectOfBookViewer {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        return CGRectMake(0, 0, size.height, size.width);
    else
        return CGRectMake(0, 0, size.width, size.height);
}

- (void)initBookViewer {

    [CATransaction setDisableActions:YES];
    bookLayer.bounds = CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);
    bookLayer.affineTransform = [self matrixOfBook];
    bookLayer.anchorPoint = CGPointMake(0, 0);
    bookLayer.position = CGPointZero;
    
    // load document
    if ([self loadDocument]) {
        backgroundLayer = [self backgroundLayer];
        if (backgroundLayer != nil) {
            backgroundLayer.frame = [self rectOfBookViewer];
            [self.view.layer addSublayer:backgroundLayer];
        }
        
        [sw start];
        [self startDocument];
    } else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error was found in loading document." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 100;
        [alert show];
    }
}

- (void)exitBookViewer {
    
    // free document
    if (document != nil) {
        [self endDocument];
        [sw stop];
        
        document = nil;
    }
    
    if (backgroundLayer != nil) {
        [backgroundLayer removeFromSuperlayer];
        backgroundLayer = nil;
    }

    bookLayer.sublayers = nil;
}

- (CGAffineTransform)matrixOfBook {
    CGSize rect = [self rectOfBookViewer].size;
    float zoom = MIN(rect.width / BOOK_WIDTH, rect.height / BOOK_HEIGHT);
    
    CGAffineTransform mat = CGAffineTransformIdentity;
    mat = CGAffineTransformTranslate(mat, rect.width / 2, rect.height / 2);
    mat = CGAffineTransformScale(mat, zoom, zoom);
    mat = CGAffineTransformTranslate(mat, - 0.5f * BOOK_WIDTH, -0.5f * BOOK_HEIGHT);
    return mat;
}

- (CALayer*)backgroundLayer {
    // draw size image when device's ratio is not same with book
    CGSize bounds = [self rectOfBookViewer].size;
    float w = bounds.height * BOOK_WIDTH / BOOK_HEIGHT;
    
    if (bounds.width > w) {
        float w_2 = (bounds.width - w) / 2;
        
        UIGraphicsBeginImageContext( bounds );
        
        UIImage *imgLeftSide = [UIImage imageNamed:@"emulator_side_left"];
        [imgLeftSide drawInRect:CGRectMake(0, 0, w_2, bounds.height)];
        
        UIImage *imgRightSide = [UIImage imageNamed:@"emulator_side_right"];
        [imgRightSide drawInRect:CGRectMake(bounds.width - w_2, 0, w_2, bounds.height)];
        
        UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *imageData = UIImagePNGRepresentation(picture1);
        UIImage *img=[UIImage imageWithData:imageData];
        
        CALayer* layer = [CALayer layer];
        layer.name = @"[emulator_background]";
        layer.contents = (id)img.CGImage;
        
        return layer;
    } else {
        return nil;
    }
}

#pragma mark - document

- (BOOL)loadDocument {
    NSString* mainFilePath = [[[AppSettings sharedInstance] bookPath:self.identifier] stringByAppendingPathComponent:@"main.ttb"];
    document = [[TDocument alloc] init];
    return [document open:mainFilePath];
}

- (void)startDocument {
    // default values
    bgmOn = YES;
    effectOn = YES;
    voiceOn = YES;
    
    transitionDelegate = nil;
    transitionStartTime = 0;
    
    // sound emulator
    soundEmulator = [[TSoundEmulator alloc] initWithLibraryManager:document.libraryManager];
    
    // play document background
    [self playBGM:document.backgroundMusic volume:document.backgroundMusicVolume];
    
    // load prev button image
    @try {
        int prevSceneButtonIndex = [document.libraryManager imageIndex:document.prevSceneButton];
        UIImage* image;
        if (prevSceneButtonIndex == -1)
            image = [UIImage imageNamed:@"emulator_img_nav_prev"];
        else
            image = [UIImage imageWithContentsOfFile:[document.libraryManager imageFilePath:prevSceneButtonIndex]];
        imgPrevButton = [TUtil resizedImage:image size:CGSizeMake(NAVBUTTON_WIDTH, NAVBUTTON_HEIGHT) stretch:NAVBUTTON_STRETH];
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        UIImage* image = [UIImage imageNamed:@"emulator_img_nav_prev"];
        imgPrevButton = [TUtil resizedImage:image size:CGSizeMake(NAVBUTTON_WIDTH, NAVBUTTON_HEIGHT) stretch:NAVBUTTON_STRETH];
    }
    
    // load next button image
    @try {
        int nextSceneButtonIndex = [document.libraryManager imageIndex:document.nextSceneButton];
        UIImage* image;
        if (nextSceneButtonIndex == -1)
            image = [UIImage imageNamed:@"emulator_img_nav_next"];
        else
            image = [UIImage imageWithContentsOfFile:[document.libraryManager imageFilePath:nextSceneButtonIndex]];
        imgNextButton = [TUtil resizedImage:image size:CGSizeMake(NAVBUTTON_WIDTH, NAVBUTTON_HEIGHT) stretch:NAVBUTTON_STRETH];
    } @catch (NSException* e) {
        NSLog(@"Error: %@", e);
        UIImage* image = [UIImage imageNamed:@"emulator_img_nav_next"];
        imgNextButton = [TUtil resizedImage:image size:CGSizeMake(NAVBUTTON_WIDTH, NAVBUTTON_HEIGHT) stretch:NAVBUTTON_STRETH];
    }
    
    // initial scene
    [self changeScene:[document currentScene]];
    
    // start thread
    timerStep = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(step) userInfo:nil repeats:YES];
}

- (void)endDocument {
    if (timerStep != nil) {
        [timerStep invalidate];
        timerStep = nil;
    }
    
    // stop current scene;
    [self finishCurrentScene];
    
    // stop All sounds
    [soundEmulator stopAllSounds];
    soundEmulator = nil;
    
    // clear document's running state
    document.run_avatar = nil;
}

- (void)finishCurrentScene {
    // free resources for old scene
    [self stopAllEffects];
    [self stopAllVoices];
    
    // free captured mouse
    mousePressed = NO;
    mouseDownActor = nil;
    
    // clear extra animations
    [extraAnimations removeAllObjects];
    
    // remove current scene from screen
    [currentScene removeFromSuperlayer];
    currentScene = nil;
    
    // clear resources
    [document.libraryManager clearImageCaches];
}

- (NSArray*)extraActorsOfScene:(TScene*)scene {
    // result
    NSMutableArray* extras = [[NSMutableArray alloc] init];
    
    // back navigation button
    if (scene.prevButtonVisible && imgPrevButton != nil) {
        TImageActor* btnPrev = [[TImageActor alloc] initWithDocument:document image:imgPrevButton x:0 y:BOOK_HEIGHT parent:scene name:@"[emulator_actor]:prev_button"];
        btnPrev.anchorPoint = CGPointMake(0, 1);
        [extras addObject:btnPrev];
        
        if (document.navigationLeftButtonRender) {
            TAnimation* animation = [[TAnimation alloc] initWithLayer:btnPrev];
            TSequence* sequence = [animation addSequence];
            
            TActionIntervalDelay* action1 = [[TActionIntervalDelay alloc] init];
            action1.duration = document.navigationButtonDelayTime * 1000;
            
            TActionInstantDispatchEvent* action2 = [[TActionInstantDispatchEvent alloc] init];
            action2.actor = btnPrev.name;
            action2.event = DEFAULT_EVENT_UNDEFINED;
            action2.recursive = NO;
            
            [sequence addAction:action1];
            [sequence addAction:action2];
            [animation start];
            animation.event = DEFAULT_EVENT_ENTER;
            [btnPrev.animations addObject:animation];
            
            
            animation = [[TAnimation alloc] initWithLayer:btnPrev];
            sequence = [animation addSequence];
            
            TActionIntervalDelay* action3 = [[TActionIntervalDelay alloc] init];
            action3.duration = 500;
            
            TActionIntervalScale* action4 = [[TActionIntervalScale alloc] init];
            action4.duration = 300;
            action4.scale = CGSizeMake(1.4, 1.4);
            
            TActionIntervalScale* action5 = [[TActionIntervalScale alloc] init];
            action5.duration = 300;
            action5.scale = CGSizeMake(1.0, 1.0);
            
            [sequence addAction:action3];
            [sequence addAction:action4];
            [sequence addAction:action5];
            sequence.repeat = 100;
            animation.event = DEFAULT_EVENT_UNDEFINED;
            [btnPrev.animations addObject:animation];
            
            
            TActionInstantGoScene* action = [[TActionInstantGoScene alloc] init];
            action.type = GoSceneTypePrevious;
            
            animation = [TAnimation newAnimation:btnPrev action:action];
            animation.event = DEFAULT_EVENT_TOUCH;
            
            [btnPrev.animations addObject:animation];
        } else {
            TActionInstantGoScene* action = [[TActionInstantGoScene alloc] init];
            action.type = GoSceneTypePrevious;
            
            TAnimation* animation = [TAnimation newAnimation:btnPrev action:action];
            animation.event = DEFAULT_EVENT_TOUCH;
            
            [btnPrev.animations addObject:animation];
        }
    }
    
    // next navigation button
    if (scene.nextButtonVisible && imgNextButton != nil) {
        TImageActor* btnNext = [[TImageActor alloc] initWithDocument:document image:imgNextButton x:BOOK_WIDTH y:BOOK_HEIGHT parent:scene name:@"[emulator_actor]:next_button"];
        btnNext.anchorPoint = CGPointMake(1, 1);
        [extras addObject:btnNext];
        
        if (document.navigationRightButtonRender) {
            TAnimation* animation = [[TAnimation alloc] initWithLayer:btnNext];
            TSequence* sequence = [animation addSequence];
            
            TActionIntervalDelay* action1 = [[TActionIntervalDelay alloc] init];
            action1.duration = document.navigationButtonDelayTime * 1000;
            
            TActionInstantDispatchEvent* action2 = [[TActionInstantDispatchEvent alloc] init];
            action2.actor = btnNext.name;
            action2.event = DEFAULT_EVENT_UNDEFINED;
            action2.recursive = NO;
            
            [sequence addAction:action1];
            [sequence addAction:action2];
            [animation start];
            animation.event = DEFAULT_EVENT_ENTER;
            [btnNext.animations addObject:animation];
            
            
            animation = [[TAnimation alloc] initWithLayer:btnNext];
            sequence = [animation addSequence];
            
            TActionIntervalDelay* action3 = [[TActionIntervalDelay alloc] init];
            action3.duration = 500;
            
            TActionIntervalScale* action4 = [[TActionIntervalScale alloc] init];
            action4.duration = 300;
            action4.scale = CGSizeMake(1.4, 1.4);
            
            TActionIntervalScale* action5 = [[TActionIntervalScale alloc] init];
            action5.duration = 300;
            action5.scale = CGSizeMake(1.0, 1.0);
            
            [sequence addAction:action3];
            [sequence addAction:action4];
            [sequence addAction:action5];
            sequence.repeat = 100;
            animation.event = DEFAULT_EVENT_UNDEFINED;
            [btnNext.animations addObject:animation];
            
            
            TActionInstantGoScene* action = [[TActionInstantGoScene alloc] init];
            action.type = GoSceneTypeNext;
            
            animation = [TAnimation newAnimation:btnNext action:action];
            animation.event = DEFAULT_EVENT_TOUCH;
            
            [btnNext.animations addObject:animation];
        } else {
            TActionInstantGoScene* action = [[TActionInstantGoScene alloc] init];
            action.type = GoSceneTypeNext;
            
            TAnimation* animation = [TAnimation newAnimation:btnNext action:action];
            animation.event = DEFAULT_EVENT_TOUCH;
            
            [btnNext.animations addObject:animation];
        }
    }
    
    // menu button
    {
        UIImage* image = [UIImage imageNamed:@"emulator_img_menu_button"];
        TImageActor* btnMenu = [[TImageActor alloc] initWithDocument:document image:image x:BOOK_WIDTH y:0 parent:scene name:@"[emulator_actor]:menu_button"];
        btnMenu.anchorPoint = CGPointMake(1, 0);
        [extras addObject:btnMenu];
        
        TActionInstantDispatchEvent* action = [[TActionInstantDispatchEvent alloc] init];
        action.actor = @"[emulator_actor]:menu_dialog";
        action.event = @"[emulator_event]:show_dialog";
        action.recursive = YES;
        
        TAnimation* animation = [TAnimation newAnimation:btnMenu action:action];
        animation.event = DEFAULT_EVENT_TOUCH;

        [btnMenu.animations addObject:animation];
    }
    
    // menu popup
    {
        // background
        UIImage* image = [UIImage imageNamed:@"emulator_img_menu_dialog_bg"];
        TImageActor* dlgMenu = [[TImageActor alloc] initWithDocument:document image:image x:0 y:0 parent:scene name:@"[emulator_actor]:menu_dialog"];
        {
            dlgMenu.anchorPoint = CGPointMake(0, 0);
            dlgMenu.alpha = 0;
            [extras addObject:dlgMenu];
            
            // show dialog
            TAnimation* animShow = [[TAnimation alloc] initWithLayer:dlgMenu];
            TSequence* seqShow = [animShow addSequence];
            
            TActionIntervalFade* action1 = [[TActionIntervalFade alloc] init];
            action1.duration = 100;
            action1.type = FadeActionTypeIn;
            [seqShow addAction:action1];
            
            animShow.event = @"[emulator_event]:show_dialog";
            [dlgMenu.animations addObject:animShow];
            
            // hide dialog
            TAnimation* animHide = [[TAnimation alloc] initWithLayer:dlgMenu];
            TSequence* seqHide = [animHide addSequence];
            
            TActionIntervalDelay* action5 = [[TActionIntervalDelay alloc] init];
            action5.duration = 200;
            [seqHide addAction:action5];
            
            TActionIntervalFade* action6 = [[TActionIntervalFade alloc] init];
            action6.duration = 100;
            action6.type = FadeActionTypeOut;
            [seqHide addAction:action6];
            
            animHide.event = @"[emulator_event]:hide_dialog";
            [dlgMenu.animations addObject:animHide];
            
            TActionInstantDispatchEvent* action = [[TActionInstantDispatchEvent alloc] init];
            action.actor = @"[emulator_actor]:menu_dialog";
            action.event = @"[emulator_event]:hide_dialog";
            action.recursive = YES;
            TAnimation* animation = [TAnimation newAnimation:dlgMenu action:action];
            animation.event = DEFAULT_EVENT_TOUCH;
            [dlgMenu.animations addObject:animation];
        }

        //================== base animations for menu show/hiding animation =====================
        TAnimation *animShowBase, *animHideBase;
        {
            TActionIntervalMove* action1 = [[TActionIntervalMove alloc] init];
            action1.duration = 300;
            action1.easingType = EasingTypeBounce;
            action1.easingMode = EasingModeOut;

            animShowBase = [TAnimation newAnimation:nil action:action1];
            animShowBase.event = @"[emulator_event]:show_dialog";
            
            TActionIntervalMove* action2 = [[TActionIntervalMove alloc] init];
            action2.duration = 300;
            action2.easingType = EasingTypeBack;
            action2.easingMode = EasingModeIn;
            
            animHideBase = [TAnimation newAnimation:nil action:action2];
            animHideBase.event = @"[emulator_event]:hide_dialog";
        }
        
        UIImage* imgBGMButton = [UIImage imageNamed:@"emulator_img_bgm_off"];
        TImageActor* btnBGM = [[TImageActor alloc] initWithDocument:document image:imgBGMButton x:250 y:-290 parent:dlgMenu name:@"[emulator_actor]:menu_bgm_button"];
        {
            btnBGM.anchorPoint = CGPointMake(0.5f, 0.5f);
            [dlgMenu addChild:btnBGM];

            // show animatin from base show animation
            TAnimation* animShow = [animShowBase clone];
            animShow.layer = btnBGM;
            ((TActionIntervalMove*)[animShow actionAtIndex:0 action:0]).position = CGPointMake(250, 290);
            [btnBGM.animations addObject:animShow];
            
            // hide animation from base hide animation
            TAnimation* animHide = [animHideBase clone];
            animHide.layer = btnBGM;
            ((TActionIntervalMove*)[animHide actionAtIndex:0 action:0]).position = btnBGM.position;
            [btnBGM.animations addObject:animHide];
            
            // initialize button status, when menu is popuped
            TActionRuntime* action1 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                if (bgmOn)
                    [btnBGM loadImage:[UIImage imageNamed:@"emulator_img_bgm_on"]];
                else
                    [btnBGM loadImage:[UIImage imageNamed:@"emulator_img_bgm_off"]];
            }];
            TAnimation* animInit = [TAnimation newAnimation:btnBGM action:action1];
            animInit.event = @"[emulator_event]:show_dialog";
            [btnBGM.animations addObject:animInit];
            
            TActionRuntime* action2 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                [self toggleBGMByAuto:YES on:YES];
                
                if (bgmOn)
                    [btnBGM loadImage:[UIImage imageNamed:@"emulator_img_bgm_on"]];
                else
                    [btnBGM loadImage:[UIImage imageNamed:@"emulator_img_bgm_off"]];
            }];
            TAnimation* animToggle = [TAnimation newAnimation:btnBGM action:action2];
            animToggle.event = DEFAULT_EVENT_TOUCH;
            [btnBGM.animations addObject:animToggle];
        }
        
        UIImage* imgEffectButton = [UIImage imageNamed:@"emulator_img_effect_off"];
        TImageActor* btnEffect = [[TImageActor alloc] initWithDocument:document image:imgEffectButton x:420 y:-290 parent:dlgMenu name:@"[emulator_actor]:menu_effect_button"];
        {
            btnEffect.anchorPoint = CGPointMake(0.5f, 0.5f);
            [dlgMenu addChild:btnEffect];
            
            // show animatin from base show animation
            TAnimation* animShow = [animShowBase clone];
            animShow.layer = btnEffect;
            ((TActionIntervalMove*)[animShow actionAtIndex:0 action:0]).position = CGPointMake(420, 290);
            [btnEffect.animations addObject:animShow];
            
            // hide animation from base hide animation
            TAnimation* animHide = [animHideBase clone];
            animHide.layer = btnEffect;
            ((TActionIntervalMove*)[animHide actionAtIndex:0 action:0]).position = btnEffect.position;
            [btnEffect.animations addObject:animHide];
            
            // initialize button status, when menu is popuped
            TActionRuntime* action1 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                if (effectOn)
                    [btnEffect loadImage:[UIImage imageNamed:@"emulator_img_effect_on"]];
                else
                    [btnEffect loadImage:[UIImage imageNamed:@"emulator_img_effect_off"]];
            }];
            TAnimation* animInit = [TAnimation newAnimation:btnEffect action:action1];
            animInit.event = @"[emulator_event]:show_dialog";
            [btnEffect.animations addObject:animInit];
            
            TActionRuntime* action2 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                [self toggleEffectByAuto:YES on:YES];
                
                if (effectOn)
                    [btnEffect loadImage:[UIImage imageNamed:@"emulator_img_effect_on"]];
                else
                    [btnEffect loadImage:[UIImage imageNamed:@"emulator_img_effect_off"]];
            }];
            TAnimation* animToggle = [TAnimation newAnimation:btnEffect action:action2];
            animToggle.event = DEFAULT_EVENT_TOUCH;
            [btnEffect.animations addObject:animToggle];
        }
        
        UIImage* imgVoiceButton = [UIImage imageNamed:@"emulator_img_voice_off"];
        TImageActor* btnVoice = [[TImageActor alloc] initWithDocument:document image:imgVoiceButton x:590 y:-290 parent:dlgMenu name:@"[emulator_actor]:menu_voice_button"];
        {
            btnVoice.anchorPoint = CGPointMake(0.5f, 0.5f);
            [dlgMenu addChild:btnVoice];
            
            // show animatin from base show animation
            TAnimation* animShow = [animShowBase clone];
            animShow.layer = btnVoice;
            ((TActionIntervalMove*)[animShow actionAtIndex:0 action:0]).position = CGPointMake(590, 290);
            [btnVoice.animations addObject:animShow];
            
            // hide animation from base hide animation
            TAnimation* animHide = [animHideBase clone];
            animHide.layer = btnVoice;
            ((TActionIntervalMove*)[animHide actionAtIndex:0 action:0]).position = btnVoice.position;
            [btnVoice.animations addObject:animHide];
            
            // initialize button status, when menu is popuped
            TActionRuntime* action1 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                if (voiceOn)
                    [btnVoice loadImage:[UIImage imageNamed:@"emulator_img_voice_on"]];
                else
                    [btnVoice loadImage:[UIImage imageNamed:@"emulator_img_voice_off"]];
            }];
            TAnimation* animInit = [TAnimation newAnimation:btnVoice action:action1];
            animInit.event = @"[emulator_event]:show_dialog";
            [btnVoice.animations addObject:animInit];
            
            TActionRuntime* action2 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                [self toggleVoiceByAuto:YES on:YES];
                
                if (voiceOn)
                    [btnVoice loadImage:[UIImage imageNamed:@"emulator_img_voice_on"]];
                else
                    [btnVoice loadImage:[UIImage imageNamed:@"emulator_img_voice_off"]];
            }];
            TAnimation* animToggle = [TAnimation newAnimation:btnVoice action:action2];
            animToggle.event = DEFAULT_EVENT_TOUCH;
            [btnVoice.animations addObject:animToggle];
        }
       
        UIImage* imgTextButton = [UIImage imageNamed:@"emulator_img_text_off"];
        TImageActor* btnText = [[TImageActor alloc] initWithDocument:document image:imgTextButton x:760 y:-290 parent:dlgMenu name:@"[emulator_actor]:menu_text_button"];
        {
            btnText.anchorPoint = CGPointMake(0.5f, 0.5f);
            [dlgMenu addChild:btnText];
            
            // show animatin from base show animation
            TAnimation* animShow = [animShowBase clone];
            animShow.layer = btnText;
            ((TActionIntervalMove*)[animShow actionAtIndex:0 action:0]).position = CGPointMake(760, 290);
            [btnText.animations addObject:animShow];
            
            // hide animation from base hide animation
            TAnimation* animHide = [animHideBase clone];
            animHide.layer = btnText;
            ((TActionIntervalMove*)[animHide actionAtIndex:0 action:0]).position = btnText.position;
            [btnText.animations addObject:animHide];
            
            // initialize button status, when menu is popuped
            TActionRuntime* action1 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                if (self.textOn)
                    [btnText loadImage:[UIImage imageNamed:@"emulator_img_text_on"]];
                else
                    [btnText loadImage:[UIImage imageNamed:@"emulator_img_text_off"]];
            }];
            TAnimation* animInit = [TAnimation newAnimation:btnText action:action1];
            animInit.event = @"[emulator_event]:show_dialog";
            [btnText.animations addObject:animInit];
            
            TActionRuntime* action2 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                [self toggleTextByAuto:YES on:YES];
                
                if (self.textOn)
                    [btnText loadImage:[UIImage imageNamed:@"emulator_img_text_on"]];
                else
                    [btnText loadImage:[UIImage imageNamed:@"emulator_img_text_off"]];
            }];
            TAnimation* animToggle = [TAnimation newAnimation:btnText action:action2];
            animToggle.event = DEFAULT_EVENT_TOUCH;
            [btnText.animations addObject:animToggle];
        }
        
        UIImage* imgBackButton = [UIImage imageNamed:@"emulator_img_back_on"];
        TImageActor* btnBack = [[TImageActor alloc] initWithDocument:document image:imgBackButton x:867 y:-160 parent:dlgMenu name:@"[emulator_actor]:menu_back_button"];
        {
            btnBack.anchorPoint = CGPointMake(0.5f, 0.5f);
            [dlgMenu addChild:btnBack];
            
            // show animatin from base show animation
            TAnimation* animShow = [animShowBase clone];
            animShow.layer = btnBack;
            ((TActionIntervalMove*)[animShow actionAtIndex:0 action:0]).position = CGPointMake(867, 160);
            [btnBack.animations addObject:animShow];
            
            // hide animation from base hide animation
            TAnimation* animHide = [animHideBase clone];
            animHide.layer = btnBack;
            ((TActionIntervalMove*)[animHide actionAtIndex:0 action:0]).position = btnBack.position;
            [btnBack.animations addObject:animHide];

            // register touch animation to back button
            TActionInstantDispatchEvent* action = [[TActionInstantDispatchEvent alloc] init];
            action.actor = @"[emulator_actor]:menu_dialog";
            action.event = @"[emulator_event]:hide_dialog";
            action.recursive = YES;
            TAnimation* animation = [TAnimation newAnimation:btnBack action:action];
            animation.event = DEFAULT_EVENT_TOUCH;
            [btnBack.animations addObject:animation];
        }
        
        // menu bar
        UIImage* imgExitButton = [UIImage imageNamed:@"emulator_img_exit"];
        TImageActor* btnExit = [[TImageActor alloc] initWithDocument:document image:imgExitButton x:510 y:500 parent:dlgMenu name:@"[emulator_actor]:exit_button"];
        {
            btnExit.anchorPoint = CGPointMake(0.5f, 0.5f);
            [dlgMenu addChild:btnExit];
            
            // showing animation
            TActionIntervalFade* action1 = [[TActionIntervalFade alloc] init];
            action1.duration = 300;
            action1.type = FadeActionTypeIn;
            
            TAnimation* animShow = [TAnimation newAnimation:btnExit action:action1];
            animShow.event = @"[emulator_event]:show_dialog";
            [btnExit.animations addObject:animShow];
            
            // hiding animation
            TActionIntervalFade* action2 = [[TActionIntervalFade alloc] init];
            action2.duration = 300;
            action2.type = FadeActionTypeOut;
            
            TAnimation* animHide = [TAnimation newAnimation:btnExit action:action2];
            animHide.event = @"[emulator_event]:hide_dialog";
            [btnExit.animations addObject:animHide];
            
            // touch event
            TActionRuntime* action3 = [[TActionRuntime alloc] initWithDuration:0 runtimeCode:^(float percent) {
                [self exitBookViewer];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            TAnimation* animExit = [TAnimation newAnimation:btnExit action:action3];
            animExit.event = DEFAULT_EVENT_TOUCH;
            [btnExit.animations addObject:animExit];
        }
    }
    
    return extras;
}

- (void)changeScene:(TScene*)scene {
    @synchronized (locker)
    {
        // stop/free all sounds and effects of current scene
        [self finishCurrentScene];

        // assign running properties before clone
        scene.run_delegate = self;
        scene.run_matrix = [self matrixOfBook];

        // assign new scene to current scene
        currentScene = (TScene*)[scene clone];
        
        // prepare resources
        [currentScene prepareResources];
        
        // extra actor
        currentScene.run_extraActors = [self extraActorsOfScene:currentScene];
        for (TActor* actor in currentScene.run_extraActors) {
            actor.zPosition = 9999;
            [currentScene addSublayer:actor];
        }
        
        [bookLayer addSublayer:currentScene];
        
        // scene have owner bgm
        if (![currentScene.backgroundMusic isEqualToString:@""])
            [self playBGM:currentScene.backgroundMusic volume:currentScene.backgroundMusicVolume];
        
        // fire enter event
        [currentScene fireEvent:DEFAULT_EVENT_ENTER recursive:YES];
    }
}

- (void)transitScene:(TScene*)scene {
    if (transitionDelegate != nil)
        transitionDelegate(transitionStartTime + 100000);
    
    nextScene = (TScene*)[scene clone];
    transitionStartTime = [sw elapsedMilliseconds];

    __weak BookViewController* weakSelf = self;
    transitionDelegate = ^(long long time) {
        __strong typeof(self) strongSelf = weakSelf;
        
        const int duration = 400; // ms
        int elapsed = (int)(time - strongSelf->transitionStartTime);
        if (elapsed >= duration / 2 && strongSelf->nextScene != nil) {
            [weakSelf changeScene:strongSelf->nextScene];
            strongSelf->nextScene = nil;
        }
        
        if (elapsed >= duration) {
            elapsed = duration;
            strongSelf->transitionDelegate = nil;
        }
        
        if (elapsed < duration / 2)
            strongSelf->currentScene.alpha = 1 - elapsed / (duration / 2.0);
        else
            strongSelf->currentScene.alpha = elapsed / (duration / 2.0) - 1;
    };
}

- (void)step {
    @synchronized (locker)
    {
        // animations of current scene
        long long time = [sw elapsedMilliseconds];
        [currentScene step:self time:time];

        // extra animation
        for (TAnimation* animation in extraAnimations) {
            if (animation.run_executing) {
                [animation step:self time:time];
            }
        }
        
        // transition effect of emulator
        if (transitionDelegate != nil)
            transitionDelegate(time);
        
        // mark the stop watch for acceleration
        [self.accelerationWatch restart];
    }
}

#pragma mark - TTataDelegate Methods

- (TScene*)currentScene {
    return currentScene;
}

- (void)gotoPrevScene {
    [self transitScene:[document prevScene:currentScene]];
}

- (void)gotoNextScene {
    [self transitScene:[document nextScene:currentScene]];
}

- (void)gotoCoverScene {
//    [self transitScene:[document coverScene]];
}

- (void)gotoSpecificScene:(NSString*)sceneName {
    TScene* scene = [document findScene:sceneName];
    if (scene != nil) {
        [self transitScene:scene];
    }
}

- (void)makeAvatar {
    if (document != nil) {
        AvatarViewController *vc  = [self.storyboard instantiateViewControllerWithIdentifier:@"avatarViewController"];
        vc.delegate = self;
        vc.avatarRaw = nil;
        vc.avatarFrame = [document getAvatarFrameImage];
        vc.avatarMask = [document getAvatarMaskImage];
        vc.backgroundImage = [UIImage imageNamed:@"emulator_img_avatar_maker"];
        vc.neckPoint = CGPointMake(811, 592);
        vc.avatarHeight = 350;
        
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)didMadeAvatar:(UIImage*)avatar {
    document.run_avatar = avatar;
    [currentScene refresh];
}

- (void)clearAvatar {
    document.run_avatar = nil;
    [currentScene refresh];
}

- (void)playEffect:(NSString*)fileName volume:(int)volume loop:(BOOL)loop {
    if (effectOn)
        [soundEmulator playEffect:fileName volume:volume loop:loop];
}

- (void)stopEffect:(NSString*)fileName {
    if (effectOn)
        [soundEmulator stopEffect:fileName];
}

- (void)toggleEffectByAuto:(BOOL)autoToggle on:(BOOL)on {
    if ((autoToggle && effectOn) || (!autoToggle && !on)) {
        [soundEmulator stopAllEffects];
        effectOn = NO;
    } else {
        effectOn = YES;
    }
}

- (void)stopAllEffects {
    if (effectOn)
        [soundEmulator stopAllEffects];
}

- (void)playVoice:(NSString*)fileName volume:(int)volume loop:(BOOL)loop {
    if (voiceOn)
        [soundEmulator playVoice:fileName volume:volume loop:loop];
}

- (void)stopVoice:(NSString*)fileName {
    if (voiceOn)
        [soundEmulator stopVoice:fileName];
}

- (void)toggleVoiceByAuto:(BOOL)autoToggle on:(BOOL)on {
    if ((autoToggle && voiceOn) || (!autoToggle && !on)) {
        [soundEmulator stopAllVoices];
        voiceOn = NO;
    } else {
        voiceOn = YES;
    }
}

- (void)stopAllVoices {
    if (voiceOn)
        [soundEmulator stopAllVoices];
}

- (void)playBGM {
    if (bgmOn)
        [soundEmulator playBGM];
}

- (void)playBGM:(NSString*)fileName volume:(int)volume {
    if (bgmOn)
        [soundEmulator playBGM:fileName volume:volume];
}

- (void)toggleBGMByAuto:(BOOL)autoToggle on:(BOOL)on {
    if ((autoToggle && bgmOn) || (!autoToggle && !on)) {
        [soundEmulator stopBGM];
        bgmOn = NO;
    } else {
        [soundEmulator playBGM];
        bgmOn = YES;
    }
}

- (void)stopBGM {
    if (bgmOn)
        [soundEmulator stopBGM];
}

- (void)stopAllSoundsOfBGM:(BOOL)bgm effect:(BOOL)effect voice:(BOOL)voice {
    [soundEmulator stopAllSoundsOfBGM:bgm effect:effect voice:voice];
}

- (void)toggleTextByAuto:(BOOL)autoToggle on:(BOOL)on {
    if ((autoToggle && _textOn) || (!autoToggle && !on)) {
        _textOn = false;
    } else {
        _textOn = true;
    }

    [currentScene refresh];
}

@end
