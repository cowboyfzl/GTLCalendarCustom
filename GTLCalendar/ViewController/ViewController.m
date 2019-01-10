//
//  ViewController.m
//  GTLCalendar
//
//  Created by daisuke on 2017/5/23.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "ViewController.h"
#import "GTLCalendarView.h"

@interface ViewController () <GTLCalendarViewDataSource, GTLCalendarViewDelegate>
@property (nonatomic, strong) GTLCalendarView *gtlCalendarView;
@end

@implementation ViewController

#pragma mark - GTLCalendarViewDataSource

- (NSDate *)minimumDateForGTLCalendar {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:@"2015-05-01"];
}

- (NSDate *)maximumDateForGTLCalendar {
    return [NSDate new];
}

- (NSDate *)defaultSelectFromDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:@"2017-05-10"];
}

- (NSDate *)defaultSelectToDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:@"2017-05-26"];
}

#pragma mark - GTLCalendarViewDelegate

- (NSInteger)rangeDaysForGTLCalendar {
    return 30 * 6;
}

- (void)selectNSStringFromDate:(NSString *)fromDate toDate:(NSString *)toDate {
    NSLog(@"fromDate: %@, toDate: %@", fromDate, toDate);
}

#pragma mark - private instance method

#pragma mark * init values

- (void)setupGTLCalendarViews {
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - 100;
    CGRect frame = CGRectMake(0, 50, screenWidth, screenHeight);
    
    _gtlCalendarView = [GTLCalendarView shareinstance];
    _gtlCalendarView.dataSource = self;
    _gtlCalendarView.delegate = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
}
- (IBAction)aaa:(id)sender {
    [_gtlCalendarView show];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGTLCalendarViews];
}

@end
