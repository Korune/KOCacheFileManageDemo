//
//  KOCacheFile.m
//  KOCacheFileManageDemo
//
//  Created by Korune on 2017/8/6.
//  Copyright © 2017年 Korune. All rights reserved.
//

#import "KOCacheFile.h"

@implementation KOCacheFile

// 实现 - isEqual: 和 - hash 两个方法，为了是使这个类可以添加进 NSMutableSet 中。

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if ([self class] != [object class]) {
        return NO;
    }
    
    KOCacheFile *cacheFile = (KOCacheFile *)object;
    if (![_filePath isEqualToString:cacheFile.filePath]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger filePathHash = [_filePath hash];
//    NSUInteger fileCreationDateHash = [_fileCreationDate hash];
//    return filePathHash ^ fileCreationDateHash;
    
    return filePathHash;
}

@end
