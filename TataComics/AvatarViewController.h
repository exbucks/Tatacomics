//
//  AvatarViewController.h
//  test
//
//  Created by Albert Li on 10/31/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"
#import "BookViewController.h"

@interface AvatarViewController : UIViewController <FDTakeDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) BookViewController* delegate;

@property (strong, nonatomic) UIImage*  avatarRaw;
@property (strong, nonatomic) UIImage*  avatarFrame;
@property (strong, nonatomic) UIImage*  avatarMask;

@property (strong, nonatomic) UIImage*  backgroundImage;
@property (assign, nonatomic) CGPoint   neckPoint;
@property (assign, nonatomic) float     avatarHeight;

@property (weak, nonatomic) IBOutlet UIView *viewAvatarWrapper;
@property (weak, nonatomic) IBOutlet UIImageView *imvAvatarOverlay;

@end
