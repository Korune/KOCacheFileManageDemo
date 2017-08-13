# KOCacheFileManageDemo

## 使用场景
1. 在 App 启动的时候，扫描缓存目录。如果当前的缓存文件总大小，大于缓存文件的最大大小，则按比例删除时间比较早的缓存文件。
2. 加载文件的时候，首先从缓存目录中加载文件。如果有则加载缓存文件，如果没有则下载文件。每次下载文件完成后，都判断缓存文件的总大小。如果大于缓存文件的最大大小，则按比例删除时间比较早的缓存文件。

## 实现思路
1. 使用 `KOCacheFile` 模型保存文件信息。
2. 使用 `NSMutableSet` 来判断保存的文件是否重复、存在。

## API 的使用
使用 `KOCacheFileManger` 的下列方法：
```objc
+ (KOCacheFileManger *)sharedManger;

- (void)handleCacheFileOverSize;

- (void)saveCachePhotoInfo:(KOCacheFile *)cachePhoto
success:(void(^)())success
failure:(void(^)())failure;

- (void)deleteCachePhotoInfo:(KOCacheFile *)cachePhoto
success:(void(^)())success
failure:(void(^)())failure;

```

## 备注
如果只在 App 启动的时候，进行文件缓存管理。那么 `KOCacheFileManger` 可以不写成单例类，可以删除 `- (void)saveCachePhotoInfo: success: failure:` 和 `- (void)deleteCachePhotoInfo: success: failure:` 两个方法，其他进行细节修改即可。

