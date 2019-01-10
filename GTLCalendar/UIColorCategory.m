//
//  NSObject+UIColorCategory.m
//  SinaWeather
//
//  Created by 得权 刘 on 12-1-6.
//  Copyright (c) 2012年 新浪. All rights reserved.
//

#import "UIColorCategory.h"

@implementation UIColor (UIColorCategory)
//根据rgb返回颜色;


+ (UIColor *)colorWithHexString:(NSString *)inColorString
{
    static NSMutableDictionary *_cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[NSMutableDictionary alloc] initWithCapacity:32];
    });
    
    inColorString = [inColorString lowercaseString];
    UIColor *color = [_cache objectForKey:inColorString];
    if (color) return color;
    
    unsigned colorCode =0;
    CGFloat alpha = 1.0;
    unsigned char redByte, greenByte, blueByte;
    if ([inColorString hasPrefix:@"#"]) {
        inColorString=[inColorString substringFromIndex:1];
    }
    NSUInteger leng=inColorString.length;
    if (leng==3) {
        redByte=[inColorString characterAtIndex:0];
        greenByte=[inColorString characterAtIndex:1];
        blueByte=[inColorString characterAtIndex:2];
        inColorString =[NSString stringWithFormat:@"%c%c%c%c%c%c",redByte,redByte,greenByte,greenByte,blueByte,blueByte];
    }
    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        [scanner scanHexInt:&colorCode]; // ignore error
    }

    if(leng==8){
        alpha = ((CGFloat)((unsigned char)(colorCode)))/ 0xff;
        redByte = (unsigned char)(colorCode >> 24);
        greenByte = (unsigned char)(colorCode >> 16);
        blueByte = (unsigned char)(colorCode >> 8); // masks off high bits
    }else{
        redByte = (unsigned char)(colorCode >> 16);
        greenByte = (unsigned char)(colorCode >> 8);
        blueByte = (unsigned char)(colorCode); // masks off high bits
    }
    color = [UIColor colorWithRed:(CGFloat)redByte / 0xff green:(CGFloat)greenByte / 0xff blue:(CGFloat)blueByte / 0xff alpha:alpha];
    [_cache setValue:color forKey:inColorString];
    return color;
}

+ (UIColor *)colorWithHexARGBString:(NSString *)inColorString
{
    if (nil == inColorString) return nil;
    static NSMutableDictionary *_cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[NSMutableDictionary alloc] initWithCapacity:32];
    });
    
    inColorString = [inColorString lowercaseString];
    UIColor *color = [_cache objectForKey:inColorString];
    if (color) return color;
    
    unsigned colorCode =0;
    CGFloat alpha = 1.0;
    unsigned char redByte, greenByte, blueByte;
    if ([inColorString hasPrefix:@"#"]) {
        inColorString=[inColorString substringFromIndex:1];
    }
    NSUInteger leng=inColorString.length;
    if (leng==3) {
        redByte=[inColorString characterAtIndex:0];
        greenByte=[inColorString characterAtIndex:1];
        blueByte=[inColorString characterAtIndex:2];
        inColorString =[NSString stringWithFormat:@"%c%c%c%c%c%c",redByte,redByte,greenByte,greenByte,blueByte,blueByte];
    }
    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        [scanner scanHexInt:&colorCode]; // ignore error
    }
    
    if(leng==8){
        alpha = ((CGFloat)((unsigned char)(colorCode>>24)))/ 0xff;
        redByte = (unsigned char)(colorCode >> 16);
        greenByte = (unsigned char)(colorCode >> 8);
        blueByte = (unsigned char)(colorCode); // masks off high bits
    }else{
        redByte = (unsigned char)(colorCode >> 16);
        greenByte = (unsigned char)(colorCode >> 8);
        blueByte = (unsigned char)(colorCode); // masks off high bits
    }
    color = [UIColor colorWithRed:(CGFloat)redByte / 0xff green:(CGFloat)greenByte / 0xff blue:(CGFloat)blueByte / 0xff alpha:alpha];
    [_cache setValue:color forKey:inColorString];
    return color;
}


+ (UIColor *)colorWithHexString2:(NSString *)hexString
{
    if (!hexString || [hexString isEqualToString:@""]) 
    {
        return [UIColor blackColor];
    }
   	/* convert the string into a int */
	unsigned int colorValueR,colorValueG,colorValueB,colorValueA;
	NSString *hexStringCleared = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
	if(hexStringCleared.length == 3) 
    {
		/* short color form */
		/* im lazy, maybe you have a better idea to convert from #fff to #ffffff */
		hexStringCleared = [NSString stringWithFormat:@"%@%@%@%@%@%@", 
                            [hexStringCleared substringWithRange:NSMakeRange(0, 1)],[hexStringCleared substringWithRange:NSMakeRange(0, 1)],
                            [hexStringCleared substringWithRange:NSMakeRange(1, 1)],[hexStringCleared substringWithRange:NSMakeRange(1, 1)],
                            [hexStringCleared substringWithRange:NSMakeRange(2, 1)],[hexStringCleared substringWithRange:NSMakeRange(2, 1)]];
	}
	if(hexStringCleared.length == 6) 
    {
		hexStringCleared = [hexStringCleared stringByAppendingString:@"ff"];
	}
    hexStringCleared = [[hexStringCleared stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
	/* im in hurry ;) */
	NSString *red = [hexStringCleared substringWithRange:NSMakeRange(0, 2)];
	NSString *green = [hexStringCleared substringWithRange:NSMakeRange(2, 2)];
	NSString *blue = [hexStringCleared substringWithRange:NSMakeRange(4, 2)];
	NSString *alpha = [hexStringCleared substringWithRange:NSMakeRange(6, 2)];
    
	[[NSScanner scannerWithString:red] scanHexInt:&colorValueR];
	[[NSScanner scannerWithString:green] scanHexInt:&colorValueG];
	[[NSScanner scannerWithString:blue] scanHexInt:&colorValueB];
	[[NSScanner scannerWithString:alpha] scanHexInt:&colorValueA];
    
    
	return [UIColor colorWithRed:((colorValueR)&0xFF)/255.0 
                           green:((colorValueG)&0xFF)/255.0 
                            blue:((colorValueB)&0xFF)/255.0 
                           alpha:((colorValueA)&0xFF)/255.0];
}

+ (UIColor *)colorWithHex:(UInt32)hex
{
    return [UIColor colorWithHex:hex alpha:1];
}

+ (UIColor *)colorWithHex:(UInt32)hex alpha:(float)alpha
{
    CGFloat r = ((hex & 0xff0000) >> 16) / 255.f;
    CGFloat g = ((hex & 0x00ff00) >> 8) / 255.f;
    CGFloat b = (hex & 0x0000ff) / 255.f;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}
@end
