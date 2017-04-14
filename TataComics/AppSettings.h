//
//  AppSettings.h
//  TataComics
//
//  Created by Albert Li on 11/24/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "UIKit+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>

//#if !DEBUG
#define SERVER_URL					@"http://www.tataland.com"
//#else
//#define SERVER_URL					@"http://www.tata.com"
//#endif

#define APPSTORE_URL                @"https://itunes.apple.com/us/app/qss-tata/id951461934?ls=1&mt=8"
#define GOOGLEPLAY_URL              @"https://play.google.com/store/apps/details?id=com.tataland.tatacomics"

#define FIRST_MYBOOKS               false

//*****************************************************************************************//

#define DownloadBookStartingNotification    @"DownloadBookStartingNotification"
#define DownloadBookStartedNotification     @"DownloadBookStartedNotification"
#define DownloadBookCompletedNotification   @"DownloadBookCompletedNotification"
#define DownloadBookFailedNotification      @"DownloadBookFailedNotification"
#define DownloadBookCancelledNotification   @"DownloadBookCancelledNotification"

#define LocalBookChangedNotification        @"LocalBookChangedNotification"

@interface AppSettings : NSObject

@property (copy, atomic) NSString* userID;

@property (strong, atomic) AVAudioPlayer *appBGMPlayer;
@property (assign, atomic) BOOL bgmOn;

@property (strong, atomic) AFURLSessionManager *sessionManager;
@property (strong, atomic) NSMutableDictionary *downloadingBooks;

+ (AppSettings*)sharedInstance;

- (void)playBGM;
- (void)pauseBGM;
- (void)stopBGM;

- (void)checkDirectories;

- (NSString*)tempPath;
- (NSString*)booksPath;
- (NSString*)bookPath:(NSString*)bookIdentifier;

- (NSString *)randomStringLength:(int)len;

- (NSArray*)localBooksByKeyword:(NSString*)keyword;
- (NSDictionary*)localBookInfo:(NSString*)bookId;
- (void)deleteLocalBooks:(NSArray*)bookIds;
- (void)saveLocalBookOrders:(NSArray*)bookIds;

- (void)loadCategoriesWithCompletionHandler:(void (^)(NSArray* categories))completionHandler;

- (void)downloadBook:(NSString*)bookId;
- (NSURLSessionDownloadTask*)downloadingTaskOfBook:(NSString*)bookId;
- (void)stopDownloadingBook:(NSString*)bookId;

@end
