//
//  GTLCalendarCell.m
//  GTLCalendar
//
//  Created by daisuke on 2017/5/24.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "GTLCalendarCell.h"
#import "UIColorCategory.h"
@interface GTLCalendarCell ()

@property (weak, nonatomic) CAShapeLayer *shapeLayer;
@property (weak, nonatomic) CAShapeLayer *currentDateShapeLayer;
@property (weak, nonatomic) CAShapeLayer *fromDateShapeLayer;
@property (weak, nonatomic) CAShapeLayer *toDateshapeLayer;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;


@end
static NSInteger const Fillet = 6;
@implementation GTLCalendarCell
@synthesize isCurrentDate = _isCurrentDate;
@synthesize isFromDate = _isFromDate;
@synthesize isToDate = _isToDate;

#pragma mark - instance method

#pragma mark * properties

- (void)setIsCurrentDate:(BOOL)isCurrentDate {
    _isCurrentDate = isCurrentDate;
    [self.currentDateShapeLayer removeFromSuperlayer];
    self.currentDateShapeLayer = nil;
    
    if (isCurrentDate) {
        CGRect rect = CGRectMake(0, 0, self.itemWidth, self.itemHeight);
        UIRectCorner rectCorner = UIRectCornerAllCorners;
        CGSize cornerRadii = CGSizeMake(CGRectGetWidth(rect)/2, CGRectGetWidth(rect)/2);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:rectCorner cornerRadii:cornerRadii];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor colorWithRed:245.0/255.0 green:162.0/255.0 blue:27.0/255.0 alpha:1].CGColor;
        if (self.shapeLayer) {
            [self.contentView.layer insertSublayer:shapeLayer above:self.shapeLayer];
        }
        else {
            [self.contentView.layer insertSublayer:shapeLayer below:self.dayLabel.layer];
        }
        self.currentDateShapeLayer = shapeLayer;
    }
    
    _descriptionLabel.hidden = true;
}

- (void)setIsFromDate:(BOOL)isFromDate {
    _isFromDate = isFromDate;
    [self.fromDateShapeLayer removeFromSuperlayer];
    self.fromDateShapeLayer = nil;
    
    if (isFromDate) {
        CGRect rect = CGRectMake(0, 0, self.itemWidth, self.itemHeight);
        UIRectCorner rectCorner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
        CGSize cornerRadii = CGSizeMake(Fillet, Fillet);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:rectCorner cornerRadii:cornerRadii];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = [UIColor colorWithHex:0x3498db alpha:0.8].CGColor;
        if (self.shapeLayer) {
            [self.contentView.layer insertSublayer:shapeLayer above:self.shapeLayer];
        }
        else {
            [self.contentView.layer insertSublayer:shapeLayer below:self.dayLabel.layer];
        }

        self.fromDateShapeLayer = shapeLayer;
        _descriptionLabel.hidden = false;
        _descriptionLabel.text = @"开始";
        [self.currentDateShapeLayer removeFromSuperlayer];
    }
}

- (void)setIsToDate:(BOOL)isToDate {
    _isToDate = isToDate;
    [self.toDateshapeLayer removeFromSuperlayer];
    self.toDateshapeLayer = nil;
    
    if (isToDate) {
        CGRect rect = CGRectMake(0, 0, self.itemWidth, self.itemHeight);
        UIRectCorner rectCorner = UIRectCornerTopRight | UIRectCornerBottomRight;
        CGSize cornerRadii = CGSizeMake(Fillet, Fillet);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:rectCorner cornerRadii:cornerRadii];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        shapeLayer.fillColor = [UIColor colorWithHex:0x3498db alpha:0.8].CGColor;
        if (self.shapeLayer) {
            [self.contentView.layer insertSublayer:shapeLayer above:self.shapeLayer];
        }
        else {
            [self.contentView.layer insertSublayer:shapeLayer below:self.dayLabel.layer];
        }
        _descriptionLabel.hidden = false;
        _descriptionLabel.text = @"结束";
        self.toDateshapeLayer = shapeLayer;
    }
   
    [self.currentDateShapeLayer removeFromSuperlayer];
}

#pragma mark - life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        self = arrayOfViews[0];
    }
    return self;
}

@end
