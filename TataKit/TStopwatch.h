//
//  TStopwatch.h
//  TataViewer
//
//  Created by Lucas Opel on 18/10/14.
//  Copyright (c) 2014 Tataland. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TStopwatch : NSObject

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) CFTimeInterval startedTime;

- (void)start;
- (void)stop;
- (void)restart;
- (long long)elapsedMilliseconds;

@end
