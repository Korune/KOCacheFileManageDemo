//
//  ViewController.m
//  KOCacheFileManageDemo
//
//  Created by Korune on 2017/8/6.
//  Copyright © 2017年 Korune. All rights reserved.
//

#import "ViewController.h"
#import "KOCacheFileManger.h"
#import "KOCacheFile.h"

@interface ViewController ()

- (IBAction)saveButtonOnClicked:(id)sender;
- (IBAction)deleteButtonOnClicked:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)saveButtonOnClicked:(id)sender {
    
    // 保存文件信息
    KOCacheFileManger *cacheFileManager = [KOCacheFileManger sharedManger];
    KOCacheFile *cachePhoto = [[KOCacheFile alloc] init];
    NSString *fileName = @"25.jpg";
    NSString *filePath = [cacheFileManager.photoCachePath stringByAppendingPathComponent:fileName];
    cachePhoto.filePath = filePath;
    [cacheFileManager saveCachePhotoInfo:cachePhoto success:^{
        // 写入文件
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        
        NSString *savedFilePath = [cacheFileManager.photoCachePath stringByAppendingPathComponent:fileName];
        BOOL isWriteSuccess = [data writeToFile:savedFilePath atomically:YES];
        if (!isWriteSuccess) {
            NSLog(@"写入文件 %@ 失败！", fileName);
        }
    } failure:^{
        // 错误提示
    }];
}

- (IBAction)deleteButtonOnClicked:(id)sender {
    
    // 删除文件信息
    KOCacheFileManger *cacheFileManager = [KOCacheFileManger sharedManger];
    KOCacheFile *cachePhoto = [[KOCacheFile alloc] init];
    NSString *filePath = [cacheFileManager.photoCachePath stringByAppendingPathComponent:@"25.jpg"];
    cachePhoto.filePath = filePath;
    [cacheFileManager deleteCachePhotoInfo:cachePhoto success:^{
        // 删除文件
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:cachePhoto.filePath error:nil];
    } failure:^{
        // 错误提示
    }];
}
@end
