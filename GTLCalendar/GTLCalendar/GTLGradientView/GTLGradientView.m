//
//  GTLGradientView.m
//  GTLCalendar
//
//  Created by daisuke on 2017/5/26.
//  Copyright © 2017年 dse12345z. All rights reserved.
//

#import "GTLGradientView.h"
#import "UIColorCategory.h"
#define squashColor [UIColor colorWithRed:245.0/255.0 green:162.0/255.0 blue:27.0/255.0 alpha:0.7]
#define dustyOrangeColor [UIColor colorWithRed:233.0/255.0 green:97.0/255.0 blue:75.0/255.0 alpha:0.7]

@interface GTLGradientView ()

@property (strong, nonatomic) CAShapeLayer *gradientLayer;

@end

@implementation GTLGradientView

#pragma mark - private instance method

#pragma mark * init values

- (void)setupInitValues {
    // 漸層
    self.gradientLayer = [CAShapeLayer layer];
    self.gradientLayer.backgroundColor = [UIColor colorWithHex:0x3498db alpha:0.2].CGColor;
    self.gradientLayer.cornerRadius = 6;
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
}

#pragma mark * override

- (void)layoutSubviews {
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
}

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitValues];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupInitValues];
    }
    return self;
}

@end
