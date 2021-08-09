//
//  KFFoundationMacros.h
//  Khiyuan Fan
//
//  Created by Khiyuan on 4/2/19.
//
#import <Foundation/Foundation.h>

/**
 *  注意：插件使用判断 KF_APP_EXTENSIONS
 */
#if defined(__has_feature) && __has_feature(attribute_availability_app_extension)
#define KF_APP_EXTENSIONS 1
#endif


#ifndef struct_box
#   define struct_box struct __attribute__((objc_boxable))
#endif

#if DEBUG
#   define kf_keywordify autoreleasepool {}
#else
#   define kf_keywordify try {} @catch (...) {}
#endif

#ifndef weakifySelf
#   define weakifySelf \
    kf_keywordify \
    __weak typeof(self) weakSelf = self
#endif

#ifndef strongifySelf
#   define strongifySelf \
    kf_keywordify \
    __strong __typeof__(weakSelf) self = weakSelf
#endif

#ifndef kf_defer
_Pragma("clang diagnostic push")
_Pragma("clang diagnostic ignored \"-Wunused-function\"")
    static void KF_clearUpBlock(__strong void(^*block)(void)){
        (*block)();
    }
_Pragma("clang diagnostic pop")
#define     kf_defer \
    kf_keywordify \
    __strong void(^block)(void) __attribute__((cleanup(KF_clearUpBlock), unused)) = ^
#endif

/** Defination -- CGFunction ------------------------------------------------- */
#ifndef CGMinX
#   define CGMinX(_obj) CGRectGetMinX(_obj.frame)
#endif
#ifndef CGMaxX
#   define CGMaxX(_obj) CGRectGetMaxX(_obj.frame)
#endif
#ifndef CGMinY
#   define CGMinY(_obj) CGRectGetMinY(_obj.frame)
#endif
#ifndef CGMaxY
#   define CGMaxY(_obj) CGRectGetMaxY(_obj.frame)
#endif
#ifndef CGWidth
#   define CGWidth(_obj) CGRectGetWidth(_obj.frame)
#endif
#ifndef CGHeight
#   define CGHeight(_obj) CGRectGetHeight(_obj.frame)
#endif
#ifndef CGM
#   define CGM(X, Y, W, H) CGRectMake((X), (Y), (W), (H))
#endif

/** Defination -- 时间常数 --------------------------------------------- */
#ifndef KF_MINUTE
#   define KF_MINUTE    60
#endif
#ifndef KF_HOUR
#   define KF_HOUR      3600
#endif
#ifndef KF_DAY
#   define KF_DAY       86400
#endif
#ifndef KF_WEEK
#   define KF_WEEK      604800
#endif
#ifndef KF_YEAR
#   define KF_YEAR      31556926
#endif

/** Defination -- 常用值操作函数 --------------------------------------------- */
#ifndef IsEmptyValue
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    //空值判断
    static inline BOOL IsEmptyValue(id _Nullable  thing) {
        if (nil == thing) return YES;
        if ([thing isKindOfClass:NSNull.class]) return YES;
        SEL selLength = @selector(length);
        if ([thing respondsToSelector:selLength] && [thing performSelector:selLength] == 0) return YES;
        SEL selCount = @selector(count);
        if ([thing respondsToSelector:selCount] && [thing performSelector:selCount] == 0) return YES;
        return NO;
    }
#pragma clang diagnostic pop
#endif

#ifndef defaultValue
    /* 判空取默认值 */
    static inline id _Nonnull defaultValue(id _Nullable value,id _Nonnull defaultValue){
        if (IsEmptyValue(value)) {
            return defaultValue;
        }
        return value;
    }
#endif

#ifndef safeString
    /** 对字符串的特殊处理,如果为空,则统一返回@"",否则原形 */
    static inline NSString *_Nonnull safeString(NSString *_Nullable value) {
        if (IsEmptyValue(value))return @"".copy;
        NSString *mStr = value;
        if ([value isKindOfClass:[NSNumber class]]) {
            mStr = ((NSNumber *)value).stringValue;
        }
        return defaultValue(mStr, [@"" copy]);
    }

#endif

#ifndef safeArray
    static inline NSArray *_Nonnull safeArray(NSArray *_Nullable value) {
        NSDictionary *mValue = defaultValue(value, [@[] copy]);
        return ([mValue isKindOfClass:NSArray.class])?mValue: [@[] copy];
    }
#endif

#ifndef safeDict
    static inline NSDictionary *_Nonnull safeDict(NSDictionary *_Nullable value) {
        NSDictionary *mValue = defaultValue(value, [@{} copy]);
        return ([mValue isKindOfClass:NSDictionary.class])?mValue: [@{} copy];
    }
#endif

#ifndef IS_DOUBLE_ZERO // 双精度判断 0
#   define MIN_VALUE 1e-8  //根据需要调整这个值
#   define IS_DOUBLE_ZERO(d) (fabs(d) < MIN_VALUE)
#endif

/** Defination -- NSString ------------------------------------------------- */
#ifndef StrFmt
#   define StrFmt(FORMAT, ...) [NSString stringWithFormat:FORMAT,##__VA_ARGS__]
#endif
#ifndef strTrim
#define     strTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
#endif

/** Defination -- Others -------------------------------------------------- */

#ifndef APP_VERSION // 版本号
#   define APP_VERSION  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#endif

#ifndef APP_BUILD_VERSION // build 号
#   define APP_BUILD_VERSION  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#endif

/** Log ------------------------------------------------------------------- */

#pragma mark - 日志函数

#ifdef DEBUG
#   define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[StrFmt(FORMAT, ##__VA_ARGS__) UTF8String]);
#   define DLog(FORMAT, ...) {NSLog((@"%s [Line %d] " FORMAT), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#   define ELog(err) {if(err) DLog(@"ELog: %@", err.description)}

#   define HLog(type,description,path) {NSLog(@"\n\
\n-------------------------------------------------------------------------------\
\n-- %@ :\
\n%@\
\n%@\
\n-------------------------------------------------------------------------------\n"\
,type,path,description);}

#else
#   define NSLog(...)
#   define DLog(...)
#   define ELog(err)
#   define HLog(...)
#endif

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
