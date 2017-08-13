//
//  KOCacheFileManger.h
//  KOCacheFileManageDemo
//
//  Created by Korune on 2017/8/6.
//  Copyright © 2017年 Korune. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KOCacheFile;

@interface KOCacheFileManger : NSObject

+ (KOCacheFileManger *)sharedManger;

@property (nonatomic, readonly, copy) NSString *photoCachePath;

- (void)handleCacheFileOverSize;

- (void)saveCachePhotoInfo:(KOCacheFile *)cachePhoto
                   success:(void(^)())success
                   failure:(void(^)())failure;

- (void)deleteCachePhotoInfo:(KOCacheFile *)cachePhoto
                     success:(void(^)())success
                     failure:(void(^)())failure;

@end
