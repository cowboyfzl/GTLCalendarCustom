//
//  GTLCalendarCell.h
//  GTLCalendar
//
//  Created by daisuke on 2017/5/24.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTLCalendarCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *lunarCalendarLabel;
@property (assign, nonatomic) NSInteger itemWidth;
@property (assign, nonatomic) CGFloat itemHeight;
@property (assign, nonatomic) BOOL isCurrentDate;
@property (assign, nonatomic) BOOL isFromDate;
@property (assign, nonatomic) BOOL isToDate;

@end
