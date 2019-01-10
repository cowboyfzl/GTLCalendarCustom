//
//  NSObject+UIColorCategory.h
//  SinaWeather
//
//  Created by 得权 刘 on 12-1-6.
//  Copyright (c) 2012年 新浪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#ifdef RGB
#undef RGB
#endif
#define RGB(r,g,b) [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.0f]

@interface UIColor (UIColorCategory)
//根据rgb返回颜色;
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexARGBString:(NSString *)inColorString;
+ (UIColor *)colorWithHex:(UInt32)hex;
+ (UIColor *)colorWithHex:(UInt32)hex alpha:(float)alpha;
@end
