//
//  KOCacheFileManger.m
//  KOCacheFileManageDemo
//
//  Created by Korune on 2017/8/6.
//  Copyright © 2017年 Korune. All rights reserved.
//

#import "KOCacheFileManger.h"
#import "KOCacheFile.h"

static const long long kCachePhotoMaxSize = 1 * 1024 * 1024; // XX MB
/// 文件缓存超过大小后，期望删除后的文件大小占最大缓存文件大小的比例
static const float kExpectdCachePhotoRatio = 0.6;

@interface KOCacheFileManger ()

@property (nonatomic, copy) NSString *photoCachePath;
@property (nonatomic, strong) NSMutableArray<KOCacheFile *> *cachePhotos;
@property (nonatomic) long long cachePhotoSize;

@end

@implementation KOCacheFileManger

static KOCacheFileManger *sharedManger;
+ (KOCacheFileManger *)sharedManger
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManger = [[self alloc] init];
    });
    return sharedManger;
}

- (NSString *)photoCachePath
{
    if (!_photoCachePath) {
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        _photoCachePath = [cacheDirectory stringByAppendingPathComponent:@"/KOPhotos"];
        
        // 如果路径不存在，则创建
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_photoCachePath]) {
            NSError *error;
            [fileManager createDirectoryAtPath:_photoCachePath withIntermediateDirectories:YES attributes:nil error:&error];
            
            if (error) {
                NSLog(@"创建路径 %@ 失败！Error：%@", _photoCachePath, [error localizedDescription]);
            }
        }
    }
    return _photoCachePath;
}

- (NSMutableArray<KOCacheFile *> *)cachePhotos
{
    if (!_cachePhotos) {
        _cachePhotos = [NSMutableArray array];
    }
    return _cachePhotos;
}

- (long long)cachePhotoSize
{
    if (!_cachePhotoSize) {
        _cachePhotoSize = [self folderSizeAtPath:self.photoCachePath cacheFileType:KOCacheFileTypePhoto];
    }
    return _cachePhotoSize;
}

- (long long)folderSizeAtPath:(NSString *)path cacheFileType:(KOCacheFileType)cacheFileType
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSLog(@"路径不存在，路径的大小为 0 byte");
        return 0;
    }
    
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir] || !isDir) {
        NSLog(@"path 不为目录（为文件），路径大小为 0 byte");
        return 0;
    }
    
    // 读取文件大小，并创建模型
    long long folderSize = 0;
    NSArray *subpaths = [fileManager subpathsAtPath:path];
    for (NSString *subFileName in subpaths) {
        NSString *fileAbsolutePath = [path stringByAppendingPathComponent:subFileName];
        NSError *error;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:fileAbsolutePath error:&error];
        long long size = fileAttributes.fileSize;
        if (error) {
            NSLog(@"获取文件大小失败！");
        }
        folderSize += size;
        
        KOCacheFile *cacheFile = [KOCacheFile new];
        cacheFile.filePath = fileAbsolutePath;
        cacheFile.fileSize = size;
        cacheFile.fileCreationDate = fileAttributes.fileCreationDate;
        cacheFile.cacheFileType = cacheFileType;
        
        if (cacheFileType == KOCacheFileTypePhoto) {
            [self.cachePhotos addObject:cacheFile];
        }
    }
    NSLog(@"缓存文件有 %ld 个", self.cachePhotos.count);
    
    // 根据时间从早到晚排序
    if (cacheFileType == KOCacheFileTypePhoto) {
        [self.cachePhotos sortUsingComparator:^NSComparisonResult(KOCacheFile*  _Nonnull obj1, KOCacheFile*  _Nonnull obj2) {
            if ([obj1.fileCreationDate timeIntervalSince1970] > [obj2.fileCreationDate timeIntervalSince1970]) {
                return NSOrderedDescending;
            }
            else if ([obj1.fileCreationDate timeIntervalSince1970] < [obj2.fileCreationDate timeIntervalSince1970]) {
                return NSOrderedAscending;
            }
            
            return NSOrderedSame;
        }];
    }
        
    return folderSize;
}

- (void)handleCacheFileOverSize
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"将处理缓存图片大小超过最大缓存图片大小");
        [self handleCachePhotoOverSize];
    });
}

- (void)handleCachePhotoOverSize
{
    if (self.cachePhotoSize < kCachePhotoMaxSize) {
        NSLog(@"缓存的图片小于最大图片缓存大小，不需要删除缓存图片");
        return;
    }
    
    // 计算要删除的文件，并删除
    long long deletedFileSize = self.cachePhotoSize - kCachePhotoMaxSize * kExpectdCachePhotoRatio;
    long long size = 0;
    int i;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    for (i = 0; i < self.cachePhotos.count; i++) {
        KOCacheFile *cacheFile = self.cachePhotos[i];
        
        [fileManager removeItemAtPath:cacheFile.filePath error:&error];
        if (error) {
            NSLog(@"删除 %@ 文件失败，Error：%@", [cacheFile.filePath lastPathComponent], [error localizedDescription]);
        }
        
        size += cacheFile.fileSize;
        if (size >= deletedFileSize) {
            break;
        }
    }
    NSLog(@"已经删除 %d 个文件了", i +1);
    
    self.cachePhotoSize -= size;
    NSRange range = NSMakeRange(0, i + 1); // 不要写成 NSMakeRange(0, i)
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.cachePhotos removeObjectsAtIndexes:indexSet];
    NSLog(@"模型中剩余 %ld 个模型", self.cachePhotos.count);
}

- (void)saveCachePhotoInfo:(KOCacheFile *)cachePhoto
                   success:(void(^)())success
                   failure:(void(^)())failure
{
    // 使用 NSMutableSet 来判断文件是否保存过
    NSMutableSet *set = [NSMutableSet setWithArray:self.cachePhotos];
    NSInteger count = set.count;
    [set addObject:cachePhoto];
    NSInteger newConut = set.count;
    if (count == newConut) {
        NSLog(@"文件 %@ 已保存过", [cachePhoto.filePath lastPathComponent]);
        if (failure) {
            failure();
        }
        return;
    }
    
    [self.cachePhotos addObject:cachePhoto];
    self.cachePhotoSize += cachePhoto.fileSize;
    [self handleCacheFileOverSize];
    
    NSLog(@"保存 %@ 文件信息成功", [cachePhoto.filePath lastPathComponent]);
    if (success) {
        success();
    }
}

- (void)deleteCachePhotoInfo:(KOCacheFile *)cachePhoto
                     success:(void(^)())success
                     failure:(void(^)())failure
{
    // 使用 NSMutableSet 来判断文件是否存在
    NSMutableSet *set = [NSMutableSet setWithArray:self.cachePhotos];
    NSInteger count = set.count;
    [set removeObject:cachePhoto];
    NSInteger newConut = set.count;
    if (count == newConut) {
        NSLog(@"在缓存文件中，没有文件 %@", [cachePhoto.filePath lastPathComponent]);
        if (failure) {
            failure();
        }
        return;
    }
    
    [self.cachePhotos removeObject:cachePhoto];
    self.cachePhotoSize -= cachePhoto.fileSize;
    if (success) {
        success();
    }
    NSLog(@"删除 %@ 文件信息成功", [cachePhoto.filePath lastPathComponent]);
}

@end
