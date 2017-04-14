//
//  LibraryViewController.h
//  TataComics
//
//  Created by Albert Li on 11/15/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionView+Draggable.h"

@interface LibraryViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource_Draggable, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UICollectionView *booksCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *btnStore;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnDone;

- (IBAction)storeClicked:(id)sender;
- (IBAction)logoutClicked:(id)sender;
- (IBAction)shareClicked:(id)sender;
- (IBAction)editClicked:(id)sender;
- (IBAction)deleteClicked:(id)sender;
- (IBAction)doneClicked:(id)sender;

@end
