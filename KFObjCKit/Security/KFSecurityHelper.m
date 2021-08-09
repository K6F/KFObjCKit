//
//  KFSecurityHelper.m
//  Khiyuan Fan
//
//  Created by Khiyuan Fan on 2018/11/7.
//

#import "KFSecurityHelper.h"

#import <sys/sysctl.h>
#import <sys/utsname.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

#import <SystemConfiguration/CaptiveNetwork.h>
#import <UIKit/UIApplication.h>

#import <fishhook/fishhook.h>

#import "KFFoundationMacros.h"

//原始函数的地址
int (*sysctl_p)(int *, u_int, void *, size_t *, void *, size_t);

//自定义函数
int mySysctl(int *name, u_int namelen, void *info, size_t *infosize, void *newinfo, size_t newinfosize){
    if (namelen == 4
        && name[0] == CTL_KERN
        && name[1] == KERN_PROC
        && name[2] == KERN_PROC_PID
        && info
        && (int)*infosize == sizeof(struct kinfo_proc))
    {
        int err = sysctl_p(name, namelen, info, infosize, newinfo, newinfosize);
        //拿出info做判断
        struct kinfo_proc * myInfo = (struct kinfo_proc *)info;
        if((myInfo->kp_proc.p_flag & P_TRACED) != 0){
            //使用异或取反
            myInfo->kp_proc.p_flag ^= P_TRACED;
        }
        
        return err;
    }
    
    return sysctl_p(name, namelen, info, infosize, newinfo, newinfosize);
}

BOOL checkCodesign(NSString *id){
    // 描述文件路径
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    // 读取application-identifier 注意描述文件的编码要使用:NSASCIIStringEncoding
    NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
    NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (int i = 0; i < embeddedProvisioningLines.count; i++) {
        if ([embeddedProvisioningLines[i] rangeOfString:@"application-identifier"].location == NSNotFound) continue;
        
        NSInteger fromPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"<string>"].location+8;
        
        NSInteger toPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"</string>"].location;
        
        NSRange range;
        range.location = fromPosition;
        range.length = toPosition - fromPosition;
        
        NSString *fullIdentifier = [embeddedProvisioningLines[i+1] substringWithRange:range];
        NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
        NSString *appIdentifier = [identifierComponents firstObject];
        
        // 对比签名ID
        if (![appIdentifier isEqual:id]) {
            return NO;
        }
        break;
    }
    return YES;
}


BOOL checkDebugger(){
    //控制码
    int name[4];//放字节码-查询信息
    name[0] = CTL_KERN;//内核查看
    name[1] = KERN_PROC;//查询进程
    name[2] = KERN_PROC_PID; //通过进程id查进程
    name[3] = getpid();//拿到自己进程的id
    //查询结果
    struct kinfo_proc info;//进程查询信息结果
    size_t info_size = sizeof(info);//结构体大小
    int error = sysctl(name, sizeof(name)/sizeof(*name), &info, &info_size, 0, 0);
    assert(error == 0);//0就是没有错误
    
    //结果解析 p_flag的第12位为1就是有调试
    //p_flag 与 P_TRACED =0 就是有调试
    return ((info.kp_proc.p_flag & P_TRACED) !=0);
}

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])
#if DEBUG
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/etc/apt",
    "/private/var/lib/apt/"
};
#else
const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app"
    ,"/private/var/lib/apt/"
    ,"/Applications/FakeCarrier.app"
    ,"/Applications/Icy.app"
    ,"/Applications/IntelliScreen.app"
    ,"/Applications/MxTube.app"
    ,"/Applications/RockApp.app"
    ,"/Applications/SBSettings.app"
    ,"/Applications/WinterBoard.app"
    ,"/Applications/blackra1n.app"
    ,"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist"
    ,"/Library/MobileSubstrate/DynamicLibraries/Veency.plist"
    ,"/Library/MobileSubstrate/MobileSubstrate.dylib"
    ,"/System/Library/LaunchDaemons/com.ikey.bbot.plist"
    ,"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist"
    ,"/bin/bash"
    ,"/bin/sh"
    ,"/etc/apt"
    ,"/etc/ssh/sshd_config"
    ,"/private/var/lib/apt"
    ,"/private/var/lib/cydia"
    ,"/private/var/mobile/Library/SBSettings/Themes"
    ,"/private/var/stash"
    ,"/private/var/tmp/cydia.log"
    ,"/usr/bin/sshd"
    ,"/usr/libexec/sftp-server"
    ,"/usr/libexec/ssh-keysign"
    ,"/usr/sbin/sshd"
    ,"/var/cache/apt"
    ,"/var/lib/apt"
    ,"/var/lib/cydia"
    ,"/usr/sbin/frida-server"
    ,"/usr/bin/cycript"
    ,"/usr/local/bin/cycript"
    ,"/usr/lib/libcycript.dylib"
};
#endif

@implementation KFSecurityHelper

#if !TARGET_OS_SIMULATOR
+(void)load{
    //交换
    rebind_symbols((struct rebinding[1]){{"sysctl",mySysctl,(void *)&sysctl_p}}, 1);
}
#endif

+(void)checkSimulator{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneType = [NSString stringWithCString:systemInfo.machine
                                             encoding:NSUTF8StringEncoding];
    
    if(!isatty(STDOUT_FILENO) && (phoneType.length != 0)
       && ([@"i386" isEqualToString:phoneType] || [@"x86_64" isEqualToString:phoneType])){
        exit(0);
    }
}

+(BOOL)isNetworkProxy{
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    CFArrayRef cfProxies = CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings));
    NSArray *proxies = (__bridge NSArray *)(cfProxies);
    NSLog(@"\n%@",proxies);
    NSDictionary *settings = proxies[0];
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"]){
        NSLog(@"代理设置检测正常");
        CFRelease(cfProxies);
        return NO;
    }else{
        NSLog(@"代理设置检测:");
        NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyHostNameKey]);
        NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyPortNumberKey]);
        NSLog(@"%@",[settings objectForKey:(NSString *)kCFProxyTypeKey]);
        CFRelease(cfProxies);
        return YES;
    }
}

/**判断设备是否已经越狱*/
+ (BOOL)isJailBreak {
#ifndef KF_APP_EXTENSIONS
#   if !TARGET_IPHONE_SIMULATOR
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://"]]) {
        NSLog(@"The device is jail broken!");
        return YES;
    }
    NSLog(@"JailBreak:openURL 检测正常");
#   endif
#endif
    
#if !TARGET_IPHONE_SIMULATOR
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES
                          encoding:NSUTF8StringEncoding error:&error];
    if(error==nil){
        //Device is jailbroken
        return YES;
    } else {
        //Device is not jailbroken
        [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
    DLog(@"JailBreak:private write 检测正常");
#endif
    
    
#if !TARGET_IPHONE_SIMULATOR
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            return YES;
        }
    }
    DLog(@"JailBreak:fileExits 检测正常");
    
#endif
    
#if !TARGET_IPHONE_SIMULATOR
    
    struct stat stat_info;
    
    
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if (0 == stat(jailbreak_tool_pathes[i], &stat_info)) {
            return YES;
        }
    }
    DLog(@"JailBreak:stat 检测正常");
    
    //可能存在stat也被hook了，可以看stat是不是出自系统库，有没有被攻击者换掉
    //这种情况出现的可能性很小
    int ret;
    Dl_info dylib_info;
    int (*func_stat)(const char *,struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSLog(@"lib:%s",dylib_info.dli_fname);      //如果不是系统库，肯定被攻击了
        if (strcmp(dylib_info.dli_fname, "/usr/lib/system/libsystem_kernel.dylib")) {
            //不相等，肯定被攻击了，相等为0
            return YES;
        }
    }
    DLog(@"JailBreak:dylib_info 检测正常");
    
    //还可以检测链接动态库，看下是否被链接了异常动态库，但是此方法存在appStore审核不通过的情况，这里不作罗列
    //通常，越狱机的输出结果会包含字符串： Library/MobileSubstrate/MobileSubstrate.dylib——之所以用检测链接动态库的方法，是可能存在前面的方法被hook的情况。这个字符串，前面的stat已经做了
    
    //如果攻击者给MobileSubstrate改名，但是原理都是通过DYLD_INSERT_LIBRARIES注入动态库
    //那么可以，检测当前程序运行的环境变量
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env != NULL) {
        return YES;
    }
    DLog(@"JailBreak:DYLD_INSERT_LIBRARIES 检测正常");
#endif
    return NO;
}

+(void)checkDebug{
#if !TARGET_OS_SIMULATOR
    if (checkDebugger()) {
        exit(0);
    }
#endif
}

+(void)checkSign:(NSString *)signStr{
#if !TARGET_OS_SIMULATOR
    if (!checkCodesign(signStr)) {
        exit(0);
    }
#endif
}
@end
