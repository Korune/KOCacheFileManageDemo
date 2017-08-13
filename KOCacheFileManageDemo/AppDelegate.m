//
//  AppDelegate.m
//  KOCacheFileManageDemo
//
//  Created by Korune on 2017/8/6.
//  Copyright © 2017年 Korune. All rights reserved.
//

#import "AppDelegate.h"
#import "KOCacheFileManger.h"
#import "KOCacheFile.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 写入文件
    
    NSLog(@"App 启动了，将写入缓存图片");
    KOCacheFileManger *cacheFileManager = [KOCacheFileManger sharedManger];
    
    for(int i = 1; i < 26; i ++) {
        
        NSString *fileName = [NSString stringWithFormat:@"%d.jpg", i];
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        [NSThread sleepForTimeInterval:0.5];
        
        NSString *savedFileName = [NSString stringWithFormat:@"%d.jpg", i];
        NSString *savedFilePath = [cacheFileManager.photoCachePath stringByAppendingPathComponent:savedFileName];
        BOOL isWriteSuccess = [data writeToFile:savedFilePath atomically:YES];
        if (!isWriteSuccess) {
            NSLog(@"写入文件 %@ 失败！", fileName);
        }
        
        // 加载 Assets.xcassets 里的图片，由于使用了 UIImageJPEGRepresentation 函数，导致写入后的图片所占存储空间变大
//        NSString *fileName = [NSString stringWithFormat:@"%d-1.jpg", i];
//        UIImage *image = [UIImage imageNamed:fileName];
//        NSData *data = UIImageJPEGRepresentation(image, 1.0);
//        [NSThread sleepForTimeInterval:0.1];
//        
//        NSString *savedFileName = [NSString stringWithFormat:@"%d-1.jpg", i];
//        NSString *savedFilePath = [cacheFileManager.photoCachePath stringByAppendingPathComponent:savedFileName];
//        BOOL isWriteSuccess = [data writeToFile:savedFilePath atomically:YES];
//        if (!isWriteSuccess) {
//            NSLog(@"%s 写入文件 %@ 失败！", __FUNCTION__, fileName);
//        }
    }
    NSLog(@"缓存图片写入完成");
    
    // 判断缓存文件大小是否超过最大缓存文件大小
    NSLog(@"%@", NSTemporaryDirectory());
    [cacheFileManager handleCacheFileOverSize];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
