//
//  GTLCalendarView.m
//  GTLCalendar
//
//  Created by daisuke on 2017/5/23.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "GTLCalendarView.h"
#import "GTLGradientView.h"
#import "GTLCalendarCell.h"
#import "GTLCalendarHeaderReusableView.h"
#import "GTLCalendarCollectionViewFlowLayout.h"
#import "NSCalendar+GTLCategory.h"
#import "UIColorCategory.h"
#import "UICollectionViewFlowLayout+Add.h"
#define itemTexTColor [UIColor colorWithHex:0x333333]
#define dayTexTColor [UIColor colorWithHex:0x333333]
#define dayOutTexTColor [UIColor colorWithRed:65.0/255.0 green:65.0/255.0 blue:65.0/255.0 alpha:0.3]

@interface GTLCalendarView () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *sectionRows;
@property (strong, nonatomic) NSMutableDictionary *gradientViewInfos;
@property (strong, nonatomic) NSDate *selectFromDate;
@property (strong, nonatomic) NSDate *selectToDate;
@property (assign, nonatomic) NSInteger rangeDays;
@property (assign, nonatomic) NSInteger months;
@property (assign, nonatomic) NSInteger itemWidth;
@property (assign, nonatomic) NSInteger itemHeight;
@property (strong, nonatomic) UIButton *doneButton;
@property (nonatomic, copy) void(^selectRangeBlock)(NSDate *fromDate, NSDate *toDate);

@end
static NSInteger const GTLCanlendarHeader = 52;
static NSInteger const GTLCanlendarCellHeight = 60;
static NSInteger const GTLCanlendarCellHeaderHeight = 100;
static NSInteger const GTLCanlendarHeaderButtonLROffset = 10;
static NSInteger const GTLCanlendarBottomHeight = 74;
static NSInteger const GTLCanlendarBottomButtonLROffset = 25;
static NSInteger const GTLCanlendarContentViewHeight = 533;

@implementation GTLCalendarView
@synthesize formatString = _formatString;

#pragma mark - instance method

- (instancetype)init
{
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBg:)];
        [self addGestureRecognizer:tap];
        tap.delegate = self;
    }
    return self;
}

+ (GTLCalendarView *)shareinstance {
    GTLCalendarView *view = [GTLCalendarView new];
    return view;
}

- (void)tapBg:(UIGestureRecognizer *)gr {
    [self hide];
}

- (void)clear {
    
    self.selectFromDate = nil;
    self.selectToDate = nil;
    [self removeAllGTLGradientView];
    [self.collectionView reloadData];
    
}

- (void)reloadData {
    if ([self.dataSource respondsToSelector:@selector(defaultSelectFromDate)]) {
        self.selectFromDate = [self.dataSource defaultSelectFromDate];
    }
    
    if ([self.dataSource respondsToSelector:@selector(defaultSelectToDate)]) {
        self.selectToDate = [self.dataSource defaultSelectToDate];
    }
    
    if ([self.delegate respondsToSelector:@selector(rangeDaysForGTLCalendar)]) {
        self.rangeDays = [self.delegate rangeDaysForGTLCalendar];
    }
    
    if ([self.delegate respondsToSelector:@selector(itemWidthForGTLCalendar)]) {
        self.itemWidth = [self.delegate itemWidthForGTLCalendar];
    }
    else {
        self.itemWidth = 30;
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.months;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sectionRows[section] integerValue];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GTLCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GTLCalendarCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.isFromDate = NO;
    cell.isToDate = NO;
    cell.isCurrentDate = NO;
    cell.itemWidth = self.itemWidth;
    cell.lunarCalendarLabel.text = @"";
    cell.itemHeight = _itemHeight;
    // 依照 section index 計算日期
    NSDate *fromDate = [self.dataSource minimumDateForGTLCalendar];
    NSDate *sectionDate = [NSCalendar date:fromDate addMonth:indexPath.section];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy年MM月dd日";
    
    // 包含前一個月天數
    NSInteger containPreDays = [NSCalendar weekFromMonthFirstDate:sectionDate];
    
    
    NSInteger shiftIndex = indexPath.row - 1;
    if (shiftIndex >= containPreDays) {
        shiftIndex -= containPreDays;
        cell.dayLabel.text = [NSString stringWithFormat:@"%td", shiftIndex + 1];
        
        NSDate *yyMMDDDate = [self dateYYMMConvertToYYMMDD:sectionDate withDay:shiftIndex + 1];
        if (!yyMMDDDate) {
            cell.dayLabel.text = @"";
            cell.dayLabel.textColor = dayTexTColor;
            cell.lunarCalendarLabel.textColor = dayTexTColor;
            return cell;
        }
        
        NSDateFormatter *yyMMDDDateFormatter = [[NSDateFormatter alloc] init];
        yyMMDDDateFormatter.dateFormat = @"yyyy-MM-dd";
        NSString *formatterDate = [yyMMDDDateFormatter stringFromDate:yyMMDDDate];
        
        NSString *date = [self getChineseCalendarWithDate:formatterDate];
        cell.lunarCalendarLabel.text = date;
        
        if ([yyMMDDDate compare:fromDate] == NSOrderedAscending) {
            cell.dayLabel.textColor = dayOutTexTColor;
            cell.lunarCalendarLabel.textColor = dayOutTexTColor;
        }
        else {
             cell.lunarCalendarLabel.textColor = dayTexTColor;
            cell.dayLabel.textColor = ([NSCalendar weekFromDate:yyMMDDDate] == 5 || [NSCalendar weekFromDate:yyMMDDDate] == 6) ? [UIColor colorWithHex:0xff714a] : dayTexTColor;
        }
        
        NSDateFormatter *currentDateFormat = [[NSDateFormatter alloc] init];
        currentDateFormat.dateFormat = self.formatString;
        NSString *currentDateString = [currentDateFormat stringFromDate:[NSDate date]];
        
        if ([yyMMDDDate compare:[currentDateFormat dateFromString:currentDateString]] == NSOrderedSame) {
            cell.isCurrentDate = YES;
            cell.dayLabel.textColor = [UIColor colorWithRed:245.0/255.0 green:162.0/255.0 blue:27.0/255.0 alpha:1];
        }
        
        BOOL isOnRangeDate = [NSCalendar isOnRangeFromDate:self.selectFromDate toDate:self.selectToDate date:yyMMDDDate];
        
        if (isOnRangeDate) {
            cell.lunarCalendarLabel.textColor = [UIColor colorWithHex:0x54a8e1];
            cell.dayLabel.textColor = [UIColor colorWithHex:0x54a8e1];
            [self recordGradientInfo:yyMMDDDate frame:cell.frame];
        }
        
        NSString *selectFromDateString = [self yyMMDDStringConvertFromDate:self.selectFromDate];
        NSString *selectToDateString = [self yyMMDDStringConvertFromDate:self.selectToDate];
        NSString *yyMMDDDateString = [self yyMMDDStringConvertFromDate:yyMMDDDate];
        if ([selectFromDateString isEqualToString:yyMMDDDateString]) {
            cell.dayLabel.textColor = [UIColor whiteColor];
            cell.lunarCalendarLabel.textColor = [UIColor whiteColor];
            cell.isFromDate = YES;
            [self recordGradientInfo:yyMMDDDate frame:cell.frame];
        }
        
        if ([selectToDateString isEqualToString:yyMMDDDateString]) {
            cell.dayLabel.textColor = [UIColor whiteColor];
            cell.lunarCalendarLabel.textColor = [UIColor whiteColor];
            cell.isToDate = YES;
            [self recordGradientInfo:yyMMDDDate frame:cell.frame];
        }
        
        // 選擇第一個日期，則把大於 rangeDays 的日期關閉
        if (self.selectFromDate && !self.selectToDate) {
            NSInteger days = [NSCalendar daysFromDate:self.selectFromDate toDate:yyMMDDDate];
            if (labs(days) >= self.rangeDays) {
                cell.lunarCalendarLabel.textColor = dayOutTexTColor;
                cell.dayLabel.textColor = dayOutTexTColor;
            }
        }
        
        // 最大日期
        if (indexPath.section == self.sectionRows.count - 1) {
            NSDate *toDate = [self.dataSource maximumDateForGTLCalendar];
            NSInteger day = [NSCalendar dayFromDate:toDate];
            
            // 超過最大日期的日數則改變顏色
            if (shiftIndex + 1 > day) {
                cell.dayLabel.textColor = dayOutTexTColor;
                cell.lunarCalendarLabel.textColor = dayOutTexTColor;
            }
        }
    }
    else {
        // 前一個月份
        cell.dayLabel.text = @"";
        cell.dayLabel.textColor = dayTexTColor;
        cell.lunarCalendarLabel.textColor = dayTexTColor;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSDate *fromDate = [self.dataSource minimumDateForGTLCalendar];
        
        // 計算開始日期加上 x 數字後的日期
        NSDate *sectionDate = [NSCalendar date:fromDate addMonth:indexPath.section];
        
        // 轉日期格式 yyyy年MM月
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy年MM月";
        NSString *dateString = [dateFormatter stringFromDate:sectionDate];
        
        GTLCalendarHeaderReusableView *gtlCalendarHeaderReusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"GTLCalendarHeaderReusableView" forIndexPath:indexPath];
        [gtlCalendarHeaderReusableView setItemWidth:_itemWidth itemHeight:_itemHeight];
        gtlCalendarHeaderReusableView.dateLabel.text = dateString;
        return gtlCalendarHeaderReusableView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 依照 section index 計算日期
    NSDate *fromDate = [self.dataSource minimumDateForGTLCalendar];
    NSDate *sectionDate = [NSCalendar date:fromDate addMonth:indexPath.section];
    
    // 包含前一個月天數
    NSInteger containPreDays = [NSCalendar weekFromMonthFirstDate:sectionDate];
    
    NSInteger shiftIndex = indexPath.row - 1;
    // 項目 一、二 ... 日以外的點擊
    if (shiftIndex >= containPreDays) {
        shiftIndex -= containPreDays;
        
        // 判斷是否點超過當天日期
        if (indexPath.section == self.sectionRows.count - 1) {
            NSDate *toDate = [self.dataSource maximumDateForGTLCalendar];
            NSInteger day = [NSCalendar dayFromDate:toDate];
            
            // 超過最大日期的日數
            if (shiftIndex + 1 > day) {
                return;
            }
        }
        
        NSDate *yyMMDDDate = [self dateYYMMConvertToYYMMDD:sectionDate withDay:shiftIndex + 1];
        NSDate *yyMMDDFromDate = [self dateFormatter:fromDate];
        if ([yyMMDDDate compare:yyMMDDFromDate] == NSOrderedAscending) {
            return;
        }
        
        if (self.selectFromDate) {
            if (self.selectToDate) {
                // 重新選擇日期區域範圍
                self.selectFromDate = yyMMDDDate;
                self.selectToDate = nil;
                
                [self removeAllGTLGradientView];
            }
            else {
                NSInteger days = [NSCalendar daysFromDate:self.selectFromDate toDate:yyMMDDDate];
                if (days > 0 && days < self.rangeDays) {
                    self.selectToDate = yyMMDDDate;
                }
                else if (days < 0 && labs(days) < self.rangeDays){
                    self.selectToDate = self.selectFromDate;
                    self.selectFromDate = yyMMDDDate;
                }
                else if (days == 0) {
                    self.selectFromDate = nil;
                    [self removeAllGTLGradientView];
                }
            }
        }
        else {
            self.selectFromDate = yyMMDDDate;
            [self removeAllGTLGradientView];
        }
        
        // delegate
        if ([self.delegate respondsToSelector:@selector(selectNSStringFromDate:toDate:)]) {
            NSDateFormatter *selectFormatter = [[NSDateFormatter alloc] init];
            selectFormatter.dateFormat = self.formatString;
            NSString *cacheFromDate = [selectFormatter stringFromDate:self.selectFromDate];
            NSString *cacheToDate = [selectFormatter stringFromDate:self.selectToDate];
            
            if (self.selectFromDate && self.selectToDate) {
               
                [self.delegate selectNSStringFromDate:cacheFromDate toDate:cacheToDate];
            }
            else if(self.selectFromDate) {
               
                [self.delegate selectNSStringFromDate:cacheFromDate toDate:cacheFromDate];
            }
            else {
               
                [self.delegate selectNSStringFromDate:@"" toDate:@""];
            }
        }
        else if ([self.delegate respondsToSelector:@selector(selectNSDateFromDate:toDate:)]) {
            if (self.selectFromDate && self.selectToDate) {
                [self.delegate selectNSDateFromDate:self.selectFromDate toDate:self.selectToDate];
            }
            else if(self.selectFromDate) {
                [self.delegate selectNSDateFromDate:self.selectFromDate toDate:self.selectFromDate];
            }
            else {
                [self.delegate selectNSDateFromDate:nil toDate:nil];
            }
        }
        
        if (self.selectFromDate && self.selectToDate) {
            _doneButton.enabled = true;
            NSInteger day = [NSCalendar daysFromDate:self.selectFromDate toDate:self.selectToDate];
            [_doneButton setTitle:[NSString stringWithFormat:@"确定(共%ld天)", (long)day] forState:UIControlStateNormal];
            _doneButton.backgroundColor = [UIColor colorWithHex:0xff714a];
        } else if(self.selectFromDate) {
            [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
            _doneButton.enabled = false;
            _doneButton.backgroundColor = [UIColor lightGrayColor];
        } else {
            [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
            _doneButton.enabled = false;
            _doneButton.backgroundColor = [UIColor lightGrayColor];
        }
        
        [self.collectionView reloadData];
    }
}

#pragma mark - instance method

#pragma mark * properties

- (NSString *)formatString {
    if (_formatString.length == 0) {
        _formatString = @"yyyy-MM-dd";
    }
    return _formatString;
}

#pragma mark - private instance method

#pragma mark * init values

- (void)setupInitValues {
    if ([self.dataSource respondsToSelector:@selector(defaultSelectFromDate)]) {
        self.selectFromDate = [self.dataSource defaultSelectFromDate];
    }
    
    if ([self.dataSource respondsToSelector:@selector(defaultSelectToDate)]) {
        self.selectToDate = [self.dataSource defaultSelectToDate];
    }
    
    if ([self.delegate respondsToSelector:@selector(rangeDaysForGTLCalendar)]) {
        self.rangeDays = [self.delegate rangeDaysForGTLCalendar];
    }
    
    if ([self.delegate respondsToSelector:@selector(itemWidthForGTLCalendar)]) {
        self.itemWidth = [self.delegate itemWidthForGTLCalendar];
    }
    else {
        self.itemWidth = 30;
    }
    
    self.gradientViewInfos = [[NSMutableDictionary alloc] init];
    
    // 計算有幾個月份
    NSDate *fromDate = [self.dataSource minimumDateForGTLCalendar];
    NSDate *toDate = [self.dataSource maximumDateForGTLCalendar];
    self.months = [NSCalendar monthsFromDate:fromDate toDate:toDate];
    
    // 計算月份天數
    self.sectionRows = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < self.months; index++) {
        // 依照 section index 計算日期
        NSDate *fromDate = [self.dataSource minimumDateForGTLCalendar];
        NSDate *sectionDate = [NSCalendar date:fromDate addMonth:index];
        
        // 當月天數
        NSInteger days = [NSCalendar daysFromDate:sectionDate];
        
        // 包含前一個月天數
        NSInteger containPreDays = [NSCalendar weekFromMonthFirstDate:sectionDate];
        
        // 包含前一個月天數
        NSInteger weekItems = 0;
        
        [self.sectionRows addObject:@(weekItems + containPreDays + days)];
    }
}

- (void)setupCollectionViews {
    CGFloat calendarViewWidth = CGRectGetWidth(self.frame);
    CGFloat calendarViewHeight = CGRectGetHeight(self.frame);
    CGRect collectionViewFrame = CGRectMake(0, GTLCanlendarHeader, calendarViewWidth, GTLCanlendarContentViewHeight - GTLCanlendarHeader - GTLCanlendarBottomHeight);
    self.contentView.frame = CGRectMake(0, calendarViewHeight, calendarViewWidth, GTLCanlendarContentViewHeight);
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
    layer.path = path.CGPath;
    self.contentView.layer.mask = layer;
    
    CGFloat items = 7;              // 一、二 ... 日
    CGFloat itemWidth = self.itemWidth;         // 項目寬
    CGFloat interitem = items + 1;  // 項目間距數量
    CGFloat collectionViewWidth = CGRectGetWidth(collectionViewFrame);
    CGFloat space = (collectionViewWidth - (items * itemWidth)) / interitem;
    CGFloat headerWidth = calendarViewWidth;
    
    GTLCalendarCollectionViewFlowLayout *flowLayout = [[GTLCalendarCollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 12;
    CGFloat x = 320 / [UIScreen mainScreen].bounds.size.width;
    CGFloat height = x * GTLCanlendarCellHeight;
    _itemHeight = height;
    flowLayout.itemSize = CGSizeMake(itemWidth, height);
    flowLayout.headerReferenceSize = CGSizeMake(headerWidth, GTLCanlendarCellHeaderHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(15, space, 0, space);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionRows = self.sectionRows;
    flowLayout.itemWidth = self.itemWidth;
    flowLayout.sectionHeadersPinToVisibleBoundsAll = true;
    flowLayout.itemHeight = height;
    flowLayout.headerHeight = GTLCanlendarCellHeaderHeight;
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor colorWithHex:0xf8f8f8];
    [self.collectionView registerClass:[GTLCalendarCell class] forCellWithReuseIdentifier:@"GTLCalendarCell"];
    [self.collectionView registerClass:[GTLCalendarHeaderReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GTLCalendarHeaderReusableView"];
    [self.contentView addSubview:self.collectionView];
    
    // 移動到當天月份
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.months - 1];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:false];
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, calendarViewWidth, GTLCanlendarHeader)];
    headerView.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateNormal];
    CGFloat xp = headerView.bounds.size.width - headerView.bounds.size.height - GTLCanlendarHeaderButtonLROffset;
    button.frame = CGRectMake(xp, 0, headerView.bounds.size.height, headerView.bounds.size.height);
    [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:button];

    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.text = @"请选择起始时间";
    titleLabel.textColor = [UIColor colorWithHex:0x333333];
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(headerView.bounds.size.width / 2, headerView.bounds.size.height / 2);
    [headerView addSubview:titleLabel];
    headerView.layer.mask = layer;
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame), CGRectGetWidth(_collectionView.frame), GTLCanlendarBottomHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    self.doneButton.frame = CGRectMake(GTLCanlendarBottomButtonLROffset, 15, CGRectGetWidth(bottomView.frame) - GTLCanlendarBottomButtonLROffset * 2, 44);
    _doneButton.layer.cornerRadius = _doneButton.bounds.size.height / 2;
    [bottomView addSubview:_doneButton];
    [self.contentView addSubview:headerView];
    [self.contentView addSubview:bottomView];
}

- (void)doneTap:(UIButton *)btn {
    if (_selectRangeBlock) {
        _selectRangeBlock(self.selectFromDate, self.selectToDate);
    }
    if ([self.delegate respondsToSelector:@selector(selectNSDateFromDate:toDate:)]) {
        [self.delegate selectNSDateFromDate:self.selectFromDate toDate:self.selectToDate];
    }
    
    [self hide];
}

- (void)selectRangeDayBlock:(void (^)(NSDate *, NSDate *))rangeDayBlock {
    _selectRangeBlock = rangeDayBlock;
}

- (void)buttonTap:(UIButton *)btn {
    [self hide];
}

- (void)show {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.5];
    self.frame = window.bounds;
    [window addSubview:self];
    [self addSubview:self.contentView];
    [self setupInitValues];
    [self setupCollectionViews];
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.frame = CGRectMake(CGRectGetMinX(self.contentView.frame),  CGRectGetHeight(self.frame) - GTLCanlendarContentViewHeight, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.2 animations:^{
         self.contentView.frame = CGRectMake(CGRectGetMinX(self.contentView.frame),  CGRectGetHeight(self.frame), CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

#pragma mark * misc

- (GTLGradientView *)gtlGradientView:(CGPoint)point {
    CGRect frame = CGRectMake(point.x, point.y, self.itemWidth, self.itemHeight);
    GTLGradientView *gtlGradientView = [[GTLGradientView alloc] initWithFrame:frame];
    return gtlGradientView;
}

- (void)removeAllGTLGradientView {
    for (NSString *key in self.gradientViewInfos.allKeys) {
        GTLGradientView *gtlGradientView = self.gradientViewInfos[key][@"view"];
        [gtlGradientView removeFromSuperview];
    }
    [self.gradientViewInfos removeAllObjects];
}

- (NSString *)yyMMDDStringConvertFromDate:(NSDate *)date {
    NSDateFormatter *yyMMDDDateFormatter = [[NSDateFormatter alloc] init];
    yyMMDDDateFormatter.dateFormat = @"yyyy年MM月dd日";
    return [yyMMDDDateFormatter stringFromDate:date];
}

- (NSDate *)dateFormatter:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy年MM月dd日";
    NSString *dateString = [dateFormatter stringFromDate:date];
    return [dateFormatter dateFromString:dateString];
}

- (NSDate *)dateYYMMConvertToYYMMDD:(NSDate *)date withDay:(NSInteger)day {
    // 轉日期格式 yyyy年MM月 to yyyy年MM月DD日
    NSDateFormatter *yyMMDateFormatter = [[NSDateFormatter alloc] init];
    yyMMDateFormatter.dateFormat = @"yyyy年MM月";
    NSString *yyMMString = [yyMMDateFormatter stringFromDate:date];
    NSString *yyMMDDString = [NSString stringWithFormat:@"%@%02ld日", yyMMString, day];
    
    NSDateFormatter *yyMMDDDateFormatter = [[NSDateFormatter alloc] init];
    yyMMDDDateFormatter.dateFormat = @"yyyy年MM月dd日";
    return [yyMMDDDateFormatter dateFromString:yyMMDDString];
}

- (void)recordGradientInfo:(NSDate *)date frame:(CGRect)frame {
    NSString *key = [NSString stringWithFormat:@"%f", CGRectGetMinY(frame)];
    if (self.gradientViewInfos[key]) {
        GTLGradientView *gtlGradientView = self.gradientViewInfos[key][@"view"];
        [self.collectionView sendSubviewToBack:gtlGradientView];
        CGRect cacheFrame = gtlGradientView.frame;
        CGRect convertFrame = gtlGradientView.frame;
        
        if (CGRectGetMinX(cacheFrame) > CGRectGetMinX(frame)) {
            convertFrame.origin.x = CGRectGetMinX(frame);
            convertFrame.size.width = CGRectGetMaxX(cacheFrame) - CGRectGetMinX(frame);
        }
        else if (CGRectGetMinX(cacheFrame) < CGRectGetMinX(frame)){
            convertFrame.size.width = CGRectGetMaxX(frame) - CGRectGetMinX(cacheFrame);
        }
        
        if (CGRectGetWidth(cacheFrame) < CGRectGetWidth(convertFrame)) {
            gtlGradientView.frame = convertFrame;
        }
    }
    else {
        CGRect convertFrame = [self.collectionView convertRect:frame toView:self.collectionView];
        GTLGradientView *gtlGradientView = [self gtlGradientView:convertFrame.origin];
        [self.collectionView insertSubview:gtlGradientView atIndex:0];
        self.gradientViewInfos[key] = @{ @"view":gtlGradientView };
    }
}

#pragma mark - life cycle

//- (void)didMoveToWindow {
//    [super didMoveToWindow];
//    if (self.superview) {
//        [self setupInitValues];
//        [self setupCollectionViews];
//    }
//}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _doneButton.enabled = false;
        _doneButton.backgroundColor = [UIColor lightGrayColor];
        [_doneButton addTarget:self action:@selector(doneTap:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneButton;
}

-(NSString*)getChineseCalendarWithDate:(NSString*)date {
    NSArray *chineseYears = [NSArray arrayWithObjects:
                             @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                             @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                             @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                             @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                             @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                             @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    
    NSArray *chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"十一月", @"腊月", nil];
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    NSDate *dateTemp = nil;
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc]init];
    
    [dateFormater setDateFormat:@"yyyy-MM-dd"];
    
    dateTemp = [dateFormater dateFromString:date];
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:dateTemp];
    
    //   NSLog(@"%ld_%ld_%ld  %@",(long)localeComp.year,(long)localeComp.month,(long)localeComp.day, localeComp.date);
    
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    NSString *chineseCal_str =nil;
    NSString *choose_str = [NSString stringWithFormat: @"%@%@",m_str,d_str];
    
    NSString *riqi_str = [date substringWithRange:NSMakeRange(5, 5)];
    
    if ([d_str isEqualToString:@"初一"]) {
        chineseCal_str =[NSString stringWithFormat: @"%@",m_str];
    }else{
        if ([riqi_str isEqualToString:@"01-01"]) {
            chineseCal_str = @"元旦节";
        }else if([riqi_str isEqualToString:@"04-01"]){
            chineseCal_str = @"愚人节";
        }else if([riqi_str isEqualToString:@"05-01"]){
            chineseCal_str = @"劳动节";
        }else if([riqi_str isEqualToString:@"06-01"]){
            chineseCal_str = @"儿童节";
        }else if([riqi_str isEqualToString:@"07-01"]){
            chineseCal_str = @"建党节";
        }else if([riqi_str isEqualToString:@"08-01"]){
            chineseCal_str = @"建军节";
        }else if([riqi_str isEqualToString:@"09-10"]){
            chineseCal_str = @"教师节";
        }else if([riqi_str isEqualToString:@"10-01"]){
            chineseCal_str = @"国庆节";
        }else if([riqi_str isEqualToString:@"12-25"]){
            chineseCal_str = @"圣诞节";
        }else if ([choose_str isEqualToString:@"腊月三十"]) {
            chineseCal_str = @"除夕夜";
        }else if ([choose_str isEqualToString:@"正月十五"]){
            chineseCal_str =@"元宵节";
        }else if ([choose_str isEqualToString:@"二月初二"]){
            chineseCal_str =@"龙头节";
        }else if ([choose_str isEqualToString:@"三月初八"]){
            chineseCal_str =@"清明节";
        }else if ([choose_str isEqualToString:@"五月初五"]){
            chineseCal_str =@"端午节";
        }else if ([choose_str isEqualToString:@"八月十五"]){
            chineseCal_str =@"中秋节";
        }else{
            chineseCal_str =[NSString stringWithFormat: @"%@",d_str];
        }
        
    }
    
    return chineseCal_str;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isEqual:self]) {
        [self hide];
        return true;
    }
    return false;
}
@end
