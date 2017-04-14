//
//  BookViewController.h
//  TataViewer
//
//  Created by Albert Li on 10/16/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "BookView.h"
#import "TTataDelegate.h"
#import "TStopwatch.h"

@class TScene;

@interface BookViewController : UIViewController <BookViewDelegate, TTataDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet BookView *bookView;

@property (nonatomic, copy)     NSString*           identifier;
@property (nonatomic, assign)   BOOL                textOn;
@property (nonatomic, assign)   CMAcceleration      acceleration;
@property (nonatomic, strong)   TStopwatch*         accelerationWatch;

- (void)didMadeAvatar:(UIImage*)avatar;

@end
