//
//  AvatarViewController.m
//  test
//
//  Created by Albert Li on 10/31/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "AvatarViewController.h"

#define BOOK_WIDTH      1024
#define BOOK_HEIGHT     768

@interface AvatarViewController () {
    FDTakeController*   takeController;
    
    UIImageView* imvOriginal;
    UIPanGestureRecognizer* panGestureRecognizer;
    UIPinchGestureRecognizer* pinchGestureRecognizer;
    UIRotationGestureRecognizer* rotationGestureRecognizer;
}

@end

@implementation AvatarViewController

#pragma mark AvatarViewController Events

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // overlay image
    self.imvAvatarOverlay.image = [self makeAvatarOverlayImage];
    
    // image view for original image of avatar
    imvOriginal = [[UIImageView alloc] init];
    imvOriginal.userInteractionEnabled = YES;
    imvOriginal.multipleTouchEnabled = YES;
    [self.viewAvatarWrapper insertSubview:imvOriginal atIndex:0];
    
    // gesture recognizer
    panGestureRecognizer        = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];             panGestureRecognizer.delegate = self;
    pinchGestureRecognizer      = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];         pinchGestureRecognizer.delegate = self;
    rotationGestureRecognizer   = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];   rotationGestureRecognizer.delegate = self;
    [imvOriginal addGestureRecognizer:panGestureRecognizer];
    [imvOriginal addGestureRecognizer:pinchGestureRecognizer];
    [imvOriginal addGestureRecognizer:rotationGestureRecognizer];

    takeController = [[FDTakeController alloc] init];
    takeController.delegate = self;
    takeController.allowsEditingPhoto = NO;
    takeController.defaultToFrontCamera = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateAvatarRawImage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (IBAction)backClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneClicked:(UIButton *)sender {
    [self.delegate didMadeAvatar:[self composeAvatarImage]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)photoClicked:(UIButton *)sender {
    takeController.popOverPresentRect = sender.frame;
    takeController.showFullScreenInPad = YES;
    [takeController takePhotoOrChooseFromLibrary];
}

#pragma mark - FDTakeDelegate

- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
//    if (madeAttempt)
//        NSLog(@"The take was cancelled after selecting media");
//    else
//        NSLog(@"The take was cancelled without selecting media");
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    self.avatarRaw = photo;
    [self updateAvatarRawImage];
}

#pragma mark - Gesture Handlers

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan)
        self.imvAvatarOverlay.alpha = 0.9;
    else if (recognizer.state == UIGestureRecognizerStateEnded)
        self.imvAvatarOverlay.alpha = 1;

    CGPoint translation = [recognizer translationInView:recognizer.view.superview];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan)
        self.imvAvatarOverlay.alpha = 0.9;
    else if (recognizer.state == UIGestureRecognizerStateEnded)
        self.imvAvatarOverlay.alpha = 1;
    
    recognizer.view.layer.affineTransform = CGAffineTransformScale(recognizer.view.layer.affineTransform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

- (void)handleRotationGesture:(UIRotationGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan)
        self.imvAvatarOverlay.alpha = 0.9;
    else if (recognizer.state == UIGestureRecognizerStateEnded)
        self.imvAvatarOverlay.alpha = 1;
    
    recognizer.view.layer.affineTransform = CGAffineTransformRotate(recognizer.view.layer.affineTransform, recognizer.rotation);
    recognizer.rotation = 0;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && ![otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Private Method

- (UIImage*)makeAvatarOverlayImage {
    
    // create image context
    CGRect rect = CGRectMake(0, 0, BOOK_WIDTH, BOOK_HEIGHT);
    UIGraphicsBeginImageContext( rect.size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState (context);
    
    // rect
    CGSize maskSize = self.avatarMask.size;
    float maskZoom = self.avatarHeight / maskSize.height; // to fix the avatar size as 500px height, even use the large image as avatar mask.
    maskSize = CGSizeMake(maskSize.width * maskZoom, maskSize.height * maskZoom);
    CGRect maskRect = CGRectMake(self.neckPoint.x - maskSize.width / 2, self.neckPoint.y - maskSize.height, maskSize.width, maskSize.height);
    
    // mask image
    UIImage* imgInverseMask = [self invertAlpha:self.avatarMask containerSize:rect.size maskRegion:maskRect];
    CGContextTranslateCTM(context, 0, BOOK_HEIGHT);
    CGContextScaleCTM(context, 1, -1);
    CGContextClipToMask(context, rect, imgInverseMask.CGImage);

    // overlay image
    CGContextTranslateCTM(context, 0, BOOK_HEIGHT);
    CGContextScaleCTM(context, 1, -1);
    [self.backgroundImage drawInRect:rect];
    
    // frame image
    CGContextRestoreGState(context);
    [self.avatarFrame drawInRect:maskRect];

    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    return [UIImage imageWithData:imageData];
}

- (UIImage *)invertAlpha:(UIImage *)image containerSize:(CGSize)size maskRegion:(CGRect)region {
    // get width and height as integers, since we'll be using them as
    // array subscripts, etc, and this'll save a whole lot of casting
    int width = size.width;
    int height = size.height;
    
    // Create a suitable RGB+alpha bitmap context in BGRA colour space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *memoryPool = (unsigned char *)calloc(width*height*4, 1);
    CGContextRef context = CGBitmapContextCreate(memoryPool, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    // draw the current image to the newly created context
    CGRect rect2 = CGRectMake(region.origin.x, size.height - region.origin.y - region.size.height, region.size.width, region.size.height);
    CGContextDrawImage(context, rect2, image.CGImage);
    
    // run through every pixel, a scan line at a time...
    for(int y = 0; y < height; y++)
    {
        // get a pointer to the start of this scan line
        unsigned char *linePointer = &memoryPool[y * width * 4];
        
        // step through the pixels one by one...
        for(int x = 0; x < width; x++)
        {
            linePointer[3] = 255 - linePointer[3];
            linePointer += 4;
        }
    }
    
    // get a CG image from the context, wrap that into a UIImage
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];
    
    // clean up
    CGImageRelease(cgImage);
    CGContextRelease(context);
    free(memoryPool);
    
    // and return
    return returnImage;
}

- (void)updateAvatarRawImage {
    CGSize size = self.avatarRaw.size;
    CGRect rect = [self screenRect];
    CGRect frame = CGRectMake((rect.size.width - size.width) / 2, (rect.size.height - size.height) / 2, size.width, size.height);
    imvOriginal.layer.affineTransform = CGAffineTransformIdentity;
    imvOriginal.frame = frame;
    imvOriginal.image = self.avatarRaw;
}

- (CGRect)screenRect {
    float screen_Height;
    float screen_Width;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]  >= 8) {
        screen_Height = [[UIScreen mainScreen] bounds].size.height;
        screen_Width = [[UIScreen mainScreen] bounds].size.width;
    } else {
        screen_Height = ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width);
        screen_Width = ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height);
    }
    
    return CGRectMake(0, 0, screen_Width, screen_Height);
}

- (UIImage*)composeAvatarImage {

    CGSize maskSize = self.avatarMask.size;
    float maskZoom = self.avatarHeight / maskSize.height; // to fix the avatar size as 500px height, even use the large image as avatar mask.
    maskSize = CGSizeMake(maskSize.width * maskZoom, maskSize.height * maskZoom);
    
    // create image context
    CGRect rect = CGRectMake(0, 0, maskSize.width, maskSize.height);
    UIGraphicsBeginImageContext( maskSize );
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // mask
    CGContextTranslateCTM(context, 0, maskSize.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextClipToMask(context, rect, self.avatarMask.CGImage);

    // revert coordinates
    CGContextTranslateCTM(context, 0, maskSize.height);
    CGContextScaleCTM(context, 1, -1);

    // raw image
    CGContextSaveGState (context);
    CGRect screenRect = [self screenRect];
    float r = MIN(BOOK_WIDTH / screenRect.size.width, BOOK_HEIGHT / screenRect.size.height);
    CGPoint orgCenter = CGPointMake((BOOK_WIDTH - screenRect.size.width * r) / 2 + imvOriginal.center.x * r, (BOOK_HEIGHT - screenRect.size.height * r) / 2 + imvOriginal.center.y * r);
    CGContextConcatCTM(context, CGAffineTransformMakeTranslation(orgCenter.x - (self.neckPoint.x - maskSize.width / 2), orgCenter.y - (self.neckPoint.y - maskSize.height)));
    CGContextScaleCTM(context, r, r);
    CGContextConcatCTM(context, imvOriginal.layer.affineTransform);
    [self.avatarRaw drawAtPoint:CGPointMake(-self.avatarRaw.size.width / 2,  -self.avatarRaw.size.height / 2)];
    
    // frame image
    CGContextRestoreGState(context);
    [self.avatarFrame drawInRect:rect];
    
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(picture1);
    return [UIImage imageWithData:imageData];
}

@end
