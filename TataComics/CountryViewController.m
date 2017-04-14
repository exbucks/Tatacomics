//
//  CountryViewController.m
//  TataComics
//
//  Created by Albert on 1/20/15.
//  Copyright (c) 2015 Tataland. All rights reserved.
//

#import "CountryViewController.h"

@interface CountryViewController () {
    NSArray* callingData;
}

@end

@implementation CountryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // load calling codes
    NSString *path = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    NSArray *callingCodes = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray* tempData = [[NSMutableArray alloc] init];
    
    for (NSDictionary* item in callingCodes) {
        NSString* isoCode = [item objectForKey:@"isocode"];
        NSString* callingcode = [item objectForKey:@"callingcode"];
        
        NSString* identifier = [NSLocale localeIdentifierFromComponents:@{ NSLocaleCountryCode : isoCode }];
        NSString* regionName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
        [tempData addObject:@{ @"isocode": isoCode, @"callingcode": callingcode, @"name": regionName }];
    }
    
    callingData = [tempData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [a objectForKey:@"name"];
        NSString *second = [b objectForKey:@"name"];
        return [first compare:second];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Global methods
+ (NSDictionary*)deviceCountry {

    // loading calling data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    NSArray *callingCodes = [NSArray arrayWithContentsOfFile:path];
    
    // current locale
    NSLocale* currentLocale = [NSLocale currentLocale];

    // code and display name
    NSString *isoCode = [currentLocale objectForKey:NSLocaleCountryCode];
    NSString* identifier = [NSLocale localeIdentifierFromComponents:@{ NSLocaleCountryCode : isoCode }];
    NSString* regionName = [currentLocale displayNameForKey:NSLocaleIdentifier value:identifier];
    
    // find calling code
    NSString* callingCode = @"";
    for (NSDictionary* item in callingCodes) {
        if ([isoCode isEqualToString:[item objectForKey:@"isocode"]]) {
            callingCode = [item objectForKey:@"callingcode"];
            break;
        }
    }
    
    return @{ @"isocode": isoCode, @"callingcode": callingCode, @"name": regionName };
}

+ (NSDictionary*)countryFromCallingCode:(NSString*)callingCode {
    
    // loading calling data
    NSString *path = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    NSArray *callingCodes = [NSArray arrayWithContentsOfFile:path];
    
    // find iso code
    NSString* isoCode = nil;
    for (NSDictionary* item in callingCodes) {
        if ([callingCode isEqualToString:[item objectForKey:@"callingcode"]]) {
            isoCode = [item objectForKey:@"isocode"];
            break;
        }
    }

    if (isoCode == nil)
        return nil;
    
    // display name
    NSString* identifier = [NSLocale localeIdentifierFromComponents:@{ NSLocaleCountryCode : isoCode }];
    NSString* regionName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];

    return @{ @"isocode": isoCode, @"callingcode": callingCode, @"name": regionName };
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return callingData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RegionCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"RegionCell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString* regionName = [[callingData objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString* callingCode = [[callingData objectAtIndex:indexPath.row] objectForKey:@"callingcode"];
    cell.textLabel.text = regionName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"+%@", callingCode];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate != nil) {
        NSDictionary* item = [callingData objectAtIndex:indexPath.row];
        [self.delegate didSelectCountry:item];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
