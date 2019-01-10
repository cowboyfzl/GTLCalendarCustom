# GTLCalendar


选取一个时间段的日历，根据GTLCalendar源码修改的一个自定义库

Usage
=============

1.初始化
```
 
 _gtlCalendarView = [GTLCalendarView shareinstance];
 _gtlCalendarView.dataSource = self;
 _gtlCalendarView.delegate = self;
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
[self.gtlCalendarView show];
});
```

2.dataSource
```
// 整個日曆的最小日期
- (NSDate *)minimumDateForGTLCalendar {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter dateFromString:@"2015-05-01"];
}

// 整個日曆的最大日期
- (NSDate *)maximumDateForGTLCalendar {
    return [NSDate new];
}
```

Property & Method
=============
GTLCalendarViewDataSource
```
// required
- (NSDate *)minimumDateForGTLCalendar;  // 日曆的最小日期
- (NSDate *)maximumDateForGTLCalendar;  // 日曆的最大日期

// optional
- (NSDate *)defaultSelectFromDate;      // 預設選擇起始日期
- (NSDate *)defaultSelectToDate;        // 預設選擇結束日期
```
GTLCalendarViewDelegate
```
// optional
- (void)selectNSDateFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;        // 回傳所選擇的日期為 NSDate 型別
- (void)selectNSStringFromDate:(NSString *)fromDate toDate:(NSString *)toDate;  // 回傳所選擇的日期為 NSString 型別
- (NSInteger)rangeDaysForGTLCalendar;   // 選擇範圍的天數
- (NSInteger)itemWidthForGTLCalendar;   // 項目寬，預設 30
```
Property
```
@property (strong, nonatomic) NSString *formatString;   // delagate 回傳的日期格式，預設格式 yyyy-MM-dd
```
Method
```
- (void)clear;        // 清除所有選擇的日期
- (void)reloadData;   // reload GTLCalendar
- (void)selectRangeDayBlock:(void(^)(NSDate *fromDate, NSDate *toDate))rangeDayBlock // 点击确定后的回调;
/// 显示视图
- (void)show;
/// 隐藏视图
- (void)hide;
```
