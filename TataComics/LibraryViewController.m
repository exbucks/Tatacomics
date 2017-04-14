//
//  LibraryViewController.m
//  TataComics
//
//  Created by Albert Li on 11/15/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "LibraryViewController.h"
#import "ThumbnailBookCell.h"
#import "AppSettings.h"
#import "Common.h"
#import "BookViewController.h"

@interface LibraryViewController () {
    BOOL needLoad;
    BOOL needShowStore;
    
    BOOL editMode;
    
    NSMutableArray* myBooks;
    NSMutableDictionary* bookSelectionStates;
    
    UIDocumentInteractionController* docController;
}

@end

@implementation LibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // buttons
    [self.btnStore setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonStore", nil)] forState:UIControlStateNormal];
    [self.btnLogout setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonAccount", nil)] forState:UIControlStateNormal];
    [self.btnShare setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"ButtonShare", nil)] forState:UIControlStateNormal];
    
    // dismiss keyboard when touching outside of search box
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

    // data
    myBooks = [[NSMutableArray alloc] init];
    [self refreshData:nil];
    
    // init selection states
    bookSelectionStates = [[NSMutableDictionary alloc] init];
    
    needLoad = NO;
#if FIRST_MYBOOKS
    needShowStore = (myBooks.count == 0);
#else
    needShowStore = YES;
#endif
    editMode = NO;
    
    [self updateToolbar];
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.booksCollectionView.collectionViewLayout;
    layout.itemSize = isPhone ? CGSizeMake(93, 120) : CGSizeMake(140, 180);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // when a book is closed, remove loading view was shown before book was shown.
    [Common removeWaitingViewFromContainer:self.view];
    
    // local data
    if (needLoad)
        [self refreshData:nil];
    else
        needLoad = YES;

    editMode = NO;
    
    [self updateToolbar];

    // register keyboard event listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)    name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)    name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:)         name:LocalBookChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LocalBookChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateShelfBackground];

    if (needShowStore) {
        needShowStore = NO;
        UINavigationController* storeNC  = [self.storyboard instantiateViewControllerWithIdentifier:@"storeNavController"];
        [self.navigationController presentViewController:storeNC animated:YES completion:nil];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self updateShelfBackground];
}

- (void)updateShelfBackground {
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.booksCollectionView.collectionViewLayout;
    CGSize rowSize = CGSizeMake(self.booksCollectionView.bounds.size.width, layout.itemSize.height);
    
    UIGraphicsBeginImageContext(rowSize);
    [[UIImage imageNamed:@"LibraryShelfRow"] drawInRect:CGRectMake(0, 0, rowSize.width, rowSize.height)];
    UIImage* rowImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.booksCollectionView.backgroundColor = [UIColor colorWithPatternImage:rowImage];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    CGRect kbFrame = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGSize kbSize = [self.view convertRect:kbFrame fromView:self.view.window].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)dismissKeyboard {
    [self.txtSearch resignFirstResponder];
}

- (void)refreshData:(NSNotification *)notification {
    [bookSelectionStates removeAllObjects];
    
    [myBooks removeAllObjects];
    [myBooks addObjectsFromArray:[[AppSettings sharedInstance] localBooksByKeyword:self.txtSearch.text]];
    
    [self.booksCollectionView reloadData];
}

- (IBAction)storeClicked:(id)sender {
    UINavigationController* storeNC  = [self.storyboard instantiateViewControllerWithIdentifier:@"storeNavController"];
    [self.navigationController presentViewController:storeNC animated:YES completion:nil];
}

- (IBAction)logoutClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareClicked:(id)sender {
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Share", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles: NSLocalizedString(@"Facebook", @""), NSLocalizedString(@"Twitter", @""), NSLocalizedString(@"Instagram", @""), NSLocalizedString(@"WhatsApp", @""), nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [popup showFromRect:self.btnShare.frame inView:self.view animated:YES];
    else
        [popup showInView:self.view];
}

- (IBAction)editClicked:(id)sender {
    if (editMode == NO) {
        editMode = YES;
        
        NSString* bookId = [myBooks objectAtIndex:0];
        if ([bookSelectionStates objectForKey:bookId] == nil)
          [bookSelectionStates setObject:@YES forKey:bookId];
        else
          [bookSelectionStates removeObjectForKey:bookId];
        
        [self.booksCollectionView reloadData];
        
    } else {
        [bookSelectionStates removeAllObjects];
        [self.booksCollectionView reloadData];
        
        editMode = NO;
    }
}

- (IBAction)deleteClicked:(id)sender {
    if (editMode == NO) {
        editMode = YES;
        
        NSString* bookId = [myBooks objectAtIndex:0];
        if ([bookSelectionStates objectForKey:bookId] == nil)
            [bookSelectionStates setObject:@YES forKey:bookId];
        else
            [bookSelectionStates removeObjectForKey:bookId];
        
        [self.booksCollectionView reloadData];
        
    } else {
        [bookSelectionStates removeAllObjects];
        [self.booksCollectionView reloadData];
        
        editMode = NO;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSMutableArray* selectedBookIds = [[NSMutableArray alloc] init];
        NSMutableArray* selectedBookIndices = [[NSMutableArray alloc] init];
        
        NSString* bookId = [myBooks objectAtIndex:alertView.tag];
        if ([bookSelectionStates objectForKey:bookId] != nil) {
            [selectedBookIds addObject:bookId];
            [selectedBookIndices addObject:[NSIndexPath indexPathForItem:alertView.tag inSection:0]];
        }
        
        [myBooks removeObjectsInArray:selectedBookIds];
        [self.booksCollectionView deleteItemsAtIndexPaths:selectedBookIndices];
        [[AppSettings sharedInstance] deleteLocalBooks:selectedBookIds];
    }
}

- (IBAction)doneClicked:(id)sender {
    [bookSelectionStates removeAllObjects];
    [self.booksCollectionView reloadData];
    
    editMode = NO;
    [self updateToolbar];
}

- (void)updateToolbar {
    self.btnDelete.hidden = !editMode;
    self.btnDone.hidden = !editMode;
    self.btnEdit.hidden = editMode;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    if (textField == self.txtSearch) {
        [textField resignFirstResponder];
        [self refreshData:nil];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.txtSearch) {
        textField.text = @"";
        [textField resignFirstResponder];
        [self refreshData:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (myBooks != nil)
        return myBooks.count;
    else
        return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // book data
    NSString* bookId = [myBooks objectAtIndex:indexPath.item];
    NSDictionary* bookData = [[AppSettings sharedInstance] localBookInfo:bookId];

    // make the cell
    ThumbnailBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailBookCell" forIndexPath:indexPath];
    cell.lblTitle.text = [bookData objectForKey:@"title"];
    
    NSString *path = [[[AppSettings sharedInstance] bookPath:bookId] stringByAppendingPathComponent:@"icon.png"];
    [cell.imgCover setImage:[UIImage imageWithContentsOfFile:path]];
    
    cell.marked = ([bookSelectionStates objectForKey:bookId] != nil);
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (editMode) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                        message:NSLocalizedString(@"ConfirmDelete", @"")
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
        [alert setTag:indexPath.item];
        [alert show];
    } else {
        
        // show loading view because some book's loading is very slow.
        [Common showWaitingViewWithMessage:NSLocalizedString(@"Waiting", @"") container:self.view];

        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
        dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
            // data for book
            NSString* bookId = [myBooks objectAtIndex:indexPath.item];
            
            // show info dialog
            BookViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"bookViewController"];
            vc.identifier = bookId;
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) {
    if (editMode) {
        // toggle selection
        NSString* bookId = [myBooks objectAtIndex:indexPath.item];
        if ([bookSelectionStates objectForKey:bookId] == nil)
            [bookSelectionStates setObject:@YES forKey:bookId];
        else
            [bookSelectionStates removeObjectForKey:bookId];
        
        // redraw cell
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        NSLog(@"---%ld", indexPath.item);
    }
}

#pragma mark - UICollectionViewDataSource_Draggable

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString* bookId = [myBooks objectAtIndex:fromIndexPath.item];
    [myBooks removeObjectAtIndex:fromIndexPath.item];
    [myBooks insertObject:bookId atIndex:toIndexPath.item];
    
    [[AppSettings sharedInstance] saveLocalBookOrders:myBooks];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [Common shareOnFacebook:self];

    } else if (buttonIndex == 1) {
        [Common shareOnTwitter:self];

    } else if (buttonIndex == 2) {
        // share on Instagram
        
        // copy image to documents folder
        NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"instagram" ofType:@"jpg"];
        NSString *targetPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Tata.igo"];
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
        BOOL ret = [[NSFileManager defaultManager] copyItemAtPath:resourcePath toPath:targetPath error:nil];

        if (ret) {
            // present document interaction controller
            NSURL *igoURL = [NSURL fileURLWithPath:targetPath];
            docController = [UIDocumentInteractionController interactionControllerWithURL:igoURL];
            docController.delegate = self;
            docController.UTI = @"com.instagram.photo";
            
            ret = [docController presentOpenInMenuFromRect:self.btnShare.frame inView:self.view animated: YES ];
            if (!ret) {
                UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                                 message:NSLocalizedString(@"NoInstagramApp", @"")
                                                                delegate:nil
                                                       cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                       otherButtonTitles: nil];
                [alert show];
            }
        } else {
            UIAlertView * alert =[[UIAlertView alloc ] initWithTitle:NSLocalizedString(@"Error", @"")
                                                             message:NSLocalizedString(@"UnknownError", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"Close", @"")
                                                   otherButtonTitles: nil];
            [alert show];            
        }
        
    } else if (buttonIndex == 3) {
        [Common shareOnWhatsapp:self];
    }
}

@end
