//
//  GTLCalendarHeaderReusableView.m
//  GTLCalendar
//
//  Created by daisuke on 2017/5/24.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "GTLCalendarHeaderReusableView.h"
#import "UIColorCategory.h"

@interface GTLCalendarHeaderReusableView ()
@property (weak, nonatomic) IBOutlet UIView *dayView;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *leftOffsets;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *itemWidth;

@end

@implementation GTLCalendarHeaderReusableView

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self = arrayOfViews[0];
        self.backgroundColor = [UIColor whiteColor];
      
    }
    return self;
}

- (void)setItemWidth:(CGFloat )itemWidth itemHeight:(CGFloat )itemHeight {
    CGFloat items = 7;              // 一、二 ... 日    // 項目寬
    CGFloat interitem = items + 1;  // 項目間距數量
    CGFloat collectionViewWidth = self.bounds.size.width;
    CGFloat space = (collectionViewWidth - (items * itemWidth)) / interitem;
    _itemWidth.constant = itemWidth;
    for (NSLayoutConstraint *constraint in _leftOffsets) {
        constraint.constant = space;
    }
}

@end
