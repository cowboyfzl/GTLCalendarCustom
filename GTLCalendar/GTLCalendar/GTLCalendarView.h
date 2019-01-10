//
//  GTLCalendarView.h
//  GTLCalendar
//
//  Created by daisuke on 2017/5/23.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GTLCalendarViewDataSource <NSObject>

@required

// 日曆的最小日期
- (NSDate *)minimumDateForGTLCalendar;

// 日曆的最大日期
- (NSDate *)maximumDateForGTLCalendar;

@optional

// 預設選擇起始日期
- (NSDate *)defaultSelectFromDate;

// 預設選擇結束日期
- (NSDate *)defaultSelectToDate;

@end

@protocol GTLCalendarViewDelegate <NSObject>

@optional

// 回傳所選擇的日期為 NSDate 型別
- (void)selectNSDateFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

// 回傳所選擇的日期為 NSString 型別
- (void)selectNSStringFromDate:(NSString *)fromDate toDate:(NSString *)toDate;

// 選擇範圍的天數
- (NSInteger)rangeDaysForGTLCalendar;

// 項目寬，預設 30
- (NSInteger)itemWidthForGTLCalendar;

@end

@interface GTLCalendarView : UIView

@property (weak, nonatomic) id<GTLCalendarViewDataSource> dataSource;
@property (weak, nonatomic) id<GTLCalendarViewDelegate> delegate;

// delagate 回傳的日期格式，預設格式 yyyy-MM-dd
@property (strong, nonatomic) NSString *formatString;
+ (GTLCalendarView *)shareinstance;

- (void)show;

- (void)hide;

// 清除所有選擇的日期
- (void)clear;

- (void)reloadData;

- (void)selectRangeDayBlock:(void(^)(NSDate *fromDate, NSDate *toDate))rangeDayBlock;
@end
