//
//  CountryViewController.h
//  TataComics
//
//  Created by Albert on 1/20/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryViewControllerDelegate <NSObject>

- (void)didSelectCountry:(NSDictionary*)country;

@end

@interface CountryViewController : UITableViewController

@property (nonatomic, weak) id <CountryViewControllerDelegate> delegate;

+ (NSDictionary*)deviceCountry;
+ (NSDictionary*)countryFromCallingCode:(NSString*)callingCode;

@end
