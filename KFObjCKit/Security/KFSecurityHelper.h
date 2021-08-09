//
//  KFSecurityHelper.h
//  Khiyuan Fan
//
//  Created by Khiyuan Fan on 2018/11/7.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
__attribute__((objc_runtime_name("abb961f0b65e20c5f18dd6d22f7d68d9")))
@interface KFSecurityHelper : NSObject
/**判断设备网络代理*/
+ (BOOL)isNetworkProxy;
/**判断设备是否已经越狱*/
+ (BOOL)isJailBreak;
// 检查模拟器运行
+(void)checkSimulator;
// 检查调试
+ (void)checkDebug;
// 检查签名
+(void)checkSign:(NSString *)signStr;
@end

NS_ASSUME_NONNULL_END
