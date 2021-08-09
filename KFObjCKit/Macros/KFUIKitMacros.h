//
//  KFUIKitMacros.h
//
//  Created by Khiyuan on 4/10/19.
//
#import <UIKit/UIKit.h>

#ifndef KFUIKitMacros_h
#define KFUIKitMacros_h


/** 版本判断 ---------------------------------------------------------------- */
#define OS_VERSION                      [[UIDevice currentDevice] systemVersion]
#define OS_VERSION_EQUAL(v)             ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define OS_VERSION_ABOVE(v)             ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define OS_VERSION_ABOVE_OR_EQUAL(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define OS_VERSION_UNDER(v)             ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define OS_VERSION_UNDER_OR_EQUAL(v)    ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/** 颜色 ------------------------------------------------------------------- */
#define rgba(r, g, b, a)    [UIColor colorWithRed: r/255.0 green: g/255.0 blue: b/255.0 alpha: a]
#define rgb(r, g, b)        rgba(r,g,b,1.f)

/** 颜色 ------------------------------------------------------------------- */
#define UI_STATUS_BAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define UI_SCREEN_WIDTH             ([UIScreen mainScreen].bounds.size.width)
#define UI_SCREEN_HEIGHT            ([UIScreen mainScreen].bounds.size.height)

#define UI_KeyWindow [UIApplication sharedApplication].keyWindow
#define UI_KeyWindow [UIApplication sharedApplication].keyWindow

/** 字体 ------------------------------------------------------------------- */
/** System font of size */
#define Font(size) [UIFont systemFontOfSize: (size)]
/** System Bold font of size */
#define BFont(size) [UIFont boldSystemFontOfSize: (size)]
/** System Semibold font of size */
#define SmBFont(size)  [UIFont systemFontOfSize:size weight:UIFontWeightSemibold]

#endif /* KFUIKitMacros_h */
