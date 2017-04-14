//
//  AppSettings.m
//  TataComics
//
//  Created by Albert Li on 11/24/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import "AppSettings.h"
#import "SSZipArchive.h"

@interface AppSettings() {
    NSArray* categories;
}

@end

@implementation AppSettings

+ (AppSettings*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static AppSettings* _sharedObject = nil;
    
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}

- (id)init
{
    if (self = [super init]) {
        // background audio player
        NSString *appBGMPath = [[NSBundle mainBundle] pathForResource:@"bgm" ofType:@"mp3"];
        NSURL *appBGMURL = [[NSURL alloc] initFileURLWithPath:appBGMPath];
        self.appBGMPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:appBGMURL error:nil];
        if (self.appBGMPlayer != nil) {
            self.appBGMPlayer.numberOfLoops = -1;
            [self.appBGMPlayer prepareToPlay];
        }
        
        self.bgmOn = YES;

        // AFNetworking URL Session Manager
        NSURLSessionConfiguration *configuration;
        if ([[NSURLSessionConfiguration class] respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)])
            configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.tataland.tatacomics"];
        else
            configuration = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.tataland.tatacomics"];

//        configuration.HTTPMaximumConnectionsPerHost = 10;
        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        self.downloadingBooks = [[NSMutableDictionary alloc] init];
        
        // load categories
        categories = nil;
        [self loadCategoriesWithCompletionHandler:nil];
    }
    
    return self;
}

- (void)playBGM {
    if (self.appBGMPlayer != nil && self.bgmOn)
        [self.appBGMPlayer play];
}

- (void)pauseBGM {
    if (self.appBGMPlayer != nil)
        [self.appBGMPlayer pause];
}

- (void)stopBGM {
    if (self.appBGMPlayer != nil) {
        [self.appBGMPlayer stop];
        self.appBGMPlayer.currentTime = 0;
    }
}

// Check directories
- (void)checkDirectories {
    
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //================================== temp folder ==============================================//
    NSString *tempPath = [self tempPath];
    
    if ([fileManager fileExistsAtPath:tempPath]) {
        // clear temp folder
        for (NSString *file in [fileManager contentsOfDirectoryAtPath:tempPath error:&error]) {
            [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", tempPath, file] error:&error];
        }
    } else {
        // create new temp folder
        [fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    //================================== books folder =============================================//
    NSString *booksPath = [self booksPath];
    
    // check and create books folder
    if (![fileManager fileExistsAtPath:booksPath])
        [fileManager createDirectoryAtPath:booksPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    // mark to prevent backup to iCloud
    NSURL* booksURL= [NSURL fileURLWithPath: booksPath];
    [booksURL setResourceValue: [NSNumber numberWithBool: YES] forKey: NSURLIsExcludedFromBackupKey error: &error];
}

- (NSString*)tempPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"];
}

- (NSString*)booksPath {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    return [docsDir stringByAppendingPathComponent:@"books"];
}

- (NSString*)bookPath:(NSString*)bookIdentifier {
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    return [[docsDir stringByAppendingPathComponent:@"books"] stringByAppendingPathComponent:bookIdentifier];
}

// Generates alpha-numeric-random string
- (NSString *)randomStringLength:(int)len {
    
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

- (NSArray*)localBooksByKeyword:(NSString*)keyword {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *booksPath = [self booksPath];
    NSArray* bookIds = [fileManager contentsOfDirectoryAtPath:booksPath error:nil];

    NSMutableArray* filterdBookIds = [[NSMutableArray alloc] init];
    NSString* trimmedKeyword = [keyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedKeyword.length > 0) {
        for (NSString* bookId in bookIds) {
            NSDictionary* bookData = [self localBookInfo:bookId];
            if (bookData != nil && [[bookData objectForKey:@"title"] rangeOfString:trimmedKeyword options:NSCaseInsensitiveSearch].location != NSNotFound)
                [filterdBookIds addObject:bookId];
        }
    } else {
        [filterdBookIds addObjectsFromArray:bookIds];
    }
    
    return [filterdBookIds sortedArrayUsingComparator:^NSComparisonResult(id bookId1, id bookId2) {
        NSDictionary* book1 = [self localBookInfo:bookId1];
        NSDictionary* book2 = [self localBookInfo:bookId2];
        
        int orderNo1 = [book1 objectForKey:@"orderNo"] != nil ? [[book1 objectForKey:@"orderNo"] intValue] : 0;
        int orderNo2 = [book2 objectForKey:@"orderNo"] != nil ? [[book2 objectForKey:@"orderNo"] intValue] : 0;
        NSTimeInterval downloadTime1 = [book1 objectForKey:@"downloadTime"] != nil ? [[book1 objectForKey:@"downloadTime"] doubleValue] : 0;
        NSTimeInterval downloadTime2 = [book2 objectForKey:@"downloadTime"] != nil ? [[book2 objectForKey:@"downloadTime"] doubleValue] : 0;
        
        if (orderNo1 < orderNo2)
            return NSOrderedAscending;
        else if (orderNo1 > orderNo2)
            return NSOrderedDescending;
        else if (downloadTime1 > downloadTime2)
            return NSOrderedAscending;
        else if (downloadTime1 < downloadTime2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
}

- (NSDictionary*)localBookInfo:(NSString*)bookId {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *bookPath = [self bookPath:bookId];
    NSString *infoPath = [bookPath stringByAppendingPathComponent:@"info.plist"];
    if ([fileManager fileExistsAtPath:infoPath]) {
        return [NSDictionary dictionaryWithContentsOfFile:infoPath];
    }
    
    return nil;
}

- (void)deleteLocalBooks:(NSArray*)bookIds {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (NSString *bookId in bookIds) {
        NSString *bookPath = [self bookPath:bookId];
        [fileManager removeItemAtPath:bookPath error:nil];
    }
}

- (void)saveLocalBookOrders:(NSArray*)bookIds {
    for (int i = 0; i < bookIds.count; i++) {
        // set order
        NSString* bookId = [bookIds objectAtIndex:i];
        NSMutableDictionary* bookInfo = [[NSMutableDictionary alloc] initWithDictionary:[self localBookInfo:bookId]];
        [bookInfo setObject:[NSNumber numberWithInt:i + 1] forKey:@"orderNo"];
        
        // save info
        NSString* bookPath = [self bookPath:bookId];
        [bookInfo writeToFile:[bookPath stringByAppendingPathComponent:@"info.plist"] atomically:YES];
    }
}

- (void)loadCategoriesWithCompletionHandler:(void (^)(NSArray* categories))completionHandler {
    if (categories != nil) {
        if (completionHandler != nil)
            completionHandler(categories);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/categories", SERVER_URL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // save the result
        if ([responseObject isKindOfClass:[NSArray class]]) {
            categories = responseObject;
            if (completionHandler != nil)
                completionHandler(categories);
        }
    } failure:nil];
    
    [operation start];
}

#pragma mark - Download Book from store

- (void)downloadBook:(NSString*)bookId {
    // temp file paths
    NSMutableString* iconTempFile   = [[NSMutableString alloc] initWithString:@""];
    NSMutableString* binTempFile    = [[NSMutableString alloc] initWithString:@""];
    
    // file manager
    NSFileManager* fileManager      = [NSFileManager defaultManager];
    
    // add item into purchasing list
    [self.downloadingBooks setObject:@{} forKey:bookId];
    
    void (^failure)(BOOL) = ^(BOOL cancelled) {
        
        if (![iconTempFile isEqualToString:@""])
            [fileManager removeItemAtPath:iconTempFile error:nil];
        
        if (![binTempFile isEqualToString:@""])
            [fileManager removeItemAtPath:binTempFile error:nil];
        
        [self.downloadingBooks removeObjectForKey:bookId];
        
        // broadcast failed
        if (!cancelled)
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadBookFailedNotification object:nil userInfo:@{@"book": bookId}];
    };
    
    // step 1: download info
    [self downloadInfo:bookId success:^(NSDictionary* info, NSString* iconURL) {

        // if download cancelled
        if ([self.downloadingBooks objectForKey:bookId] == nil)
            return;
        
        // step 2: download icon
        [self downloadIcon:bookId url:iconURL success:^(NSString *tempFile) {

            // if download cancelled
            if ([self.downloadingBooks objectForKey:bookId] == nil)
                return;
            
            // save temp file path
            [iconTempFile setString:tempFile];
            
            // step 3: download binary
            [self downloadBinary:bookId success:^(NSString *tempFile) {
                
                // save temp file path
                [binTempFile setString:tempFile];
                
                NSError* error;
                
                // book path
                NSString *bookPath = [self bookPath:bookId];
                
                // delete old book
                if ([fileManager fileExistsAtPath:bookPath])
                    [fileManager removeItemAtPath:bookPath error:&error];
                
                // extract new book
                bool ret = [SSZipArchive unzipFileAtPath:binTempFile toDestination:bookPath];
                if (ret) {
                    
                    // move temp file to normal path
                    [fileManager moveItemAtPath:iconTempFile toPath:[bookPath stringByAppendingPathComponent:@"icon.png"] error:nil];
                    
                    // save info
                    NSMutableDictionary* finalInfo = [[NSMutableDictionary alloc] initWithDictionary:info];
                    [finalInfo setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"downloadTime"];
                    [finalInfo writeToFile:[bookPath stringByAppendingPathComponent:@"info.plist"] atomically:YES];

                    // delete temp binary file
                    [fileManager removeItemAtPath:binTempFile error:nil];

                    // clear from purchasing list
                    [self.downloadingBooks removeObjectForKey:bookId];

                    // broadcast show completed
                    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadBookCompletedNotification object:nil userInfo:@{@"book": bookId}];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LocalBookChangedNotification object:nil userInfo:nil];

                    NSLog(@"Download completed: %@", bookId);
                } else {
                    failure(NO);
                }
            } failure:failure];
            
            // broadcast show progressing
            [[NSNotificationCenter defaultCenter] postNotificationName:DownloadBookStartedNotification object:nil userInfo:@{@"book": bookId}];
            
        } failure:failure];
    } failure:failure];
}

- (void)downloadInfo:(NSString*)bookId success:(void (^)(NSDictionary* info, NSString* iconURL))success failure:(void (^)(BOOL))failure {

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/info/%@", SERVER_URL, bookId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // extract info to save
        NSDictionary* info = @{
                               @"title" : [responseObject objectForKey:@"title"],
                               @"author" : [responseObject objectForKey:@"author"],
                               @"category" : [responseObject objectForKey:@"category"],
                               @"version" : [responseObject objectForKey:@"version"]
        };
        
        // callback function
        success(info, [responseObject objectForKey:@"icon"]);
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled);
    }];
    
    [operation start];
}

- (void)downloadIcon:(NSString*)bookId url:(NSString*)iconURL success:(void (^)(NSString* tempFile))success failure:(void (^)(BOOL))failure {
    NSURL *url = [NSURL URLWithString:iconURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // prepare temp path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempPath;
    do {
        tempPath = [NSString stringWithFormat:@"%@/%f_%@.icon", [self tempPath], [[NSDate date] timeIntervalSince1970], [self randomStringLength:4]];
    } while ([fileManager fileExistsAtPath:tempPath]);
    
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        // return destination path
        return [NSURL fileURLWithPath:tempPath];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (error == nil) {
            // callback function
            success(tempPath);
        } else {
            failure([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled);
        }
    }];
    
    downloadTask.taskDescription = [NSString stringWithFormat:@"Icon %@", bookId];
    [downloadTask resume];
}

- (void)downloadBinary:(NSString*)bookId success:(void (^)(NSString* tempFile))success failure:(void (^)(BOOL))failure {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/download/%@", SERVER_URL, bookId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    // prepare temp path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempPath;
    do {
        tempPath = [NSString stringWithFormat:@"%@/%f_%@.tpk", [self tempPath], [[NSDate date] timeIntervalSince1970], [self randomStringLength:4]];
    } while ([fileManager fileExistsAtPath:tempPath]);

    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {

        // return destination path
        return [NSURL fileURLWithPath:tempPath];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {

        if (error == nil) {
            // callback function
            success(tempPath);
        } else {
            failure([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled);
        }
    }];

    downloadTask.taskDescription = [NSString stringWithFormat:@"Binary %@", bookId];
    [downloadTask resume];
}

- (NSURLSessionDownloadTask*)downloadingTaskOfBook:(NSString*)bookId {
    NSArray* tasks = self.sessionManager.downloadTasks;
    NSString* taskDesc = [NSString stringWithFormat:@"Binary %@", bookId];
    for (NSURLSessionDownloadTask* task in tasks) {
        if ([task.taskDescription isEqualToString:taskDesc])
            return task;
    }
    
    return nil;
}

- (void)stopDownloadingBook:(NSString*)bookId {

    NSArray* tasks = self.sessionManager.downloadTasks;
    for (NSURLSessionDownloadTask* task in tasks) {
        if ([task.taskDescription isEqualToString:[NSString stringWithFormat:@"Icon %@", bookId]] || [task.taskDescription isEqualToString:[NSString stringWithFormat:@"Binary %@", bookId]])
            [task cancel];
    }
    
    [self.downloadingBooks removeObjectForKey:bookId];
    
    // broadcast failed
    [[NSNotificationCenter defaultCenter] postNotificationName:DownloadBookCancelledNotification object:nil userInfo:@{@"book": bookId}];
}

@end
