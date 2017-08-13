//
//  KOCacheFile.h
//  KOCacheFileManageDemo
//
//  Created by Korune on 2017/8/6.
//  Copyright © 2017年 Korune. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, KOCacheFileType) {
    KOCacheFileTypePhoto,
    KOCacheFileTypeOther,
};

@interface KOCacheFile : NSObject

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic) long long fileSize;
@property (nonatomic, strong) NSDate *fileCreationDate;
@property (nonatomic) KOCacheFileType cacheFileType;

@end
