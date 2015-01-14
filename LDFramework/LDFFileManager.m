//
//  LDFFileManager.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import <objective-zip/ZipFile.h>
#import <objective-zip/FileInZipInfo.h>
#import <objective-zip/ZipReadStream.h>
#import <objective-zip/ZipException.h>
#import <ZipArchive/ZipArchive.h>
#import "LDFFileManager.h"
#import "LDFDebug.h"


@interface NSDictionary (NSDataHelper)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data;

@end

@implementation NSDictionary (Helpers)

+ (NSDictionary *)dictionaryWithContentsOfData:(NSData *)data {
    CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault,(__bridge CFDataRef)data,kCFPropertyListImmutable,NULL);
    if(plist == nil){
        return nil;
    }
    
    if ([(__bridge id)plist isKindOfClass:[NSDictionary class]]) {
        return (__bridge NSDictionary *)plist;
    }
    else {
        CFRelease(plist);
        return nil;
    }
}

@end



@implementation LDFFileManager

/**
 * 获取Bundle存储的目录
 * @return bundle存储目录
 */
+(NSString *) bundleCacheDir {
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *bundleCacheDir = [cacheDir stringByAppendingPathComponent:@"_dynamic_bundleCache_"];
    NSLog(@"bundleCacheDir>>>>%@", bundleCacheDir);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:bundleCacheDir]){
        BOOL isCreate = [fileManager createDirectoryAtPath:bundleCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        //bundle cache 目录建立不成功，返回不进行拷贝
        if(!isCreate) {
            return @"";
        }
    }
    
    return bundleCacheDir;
}

/**
 * 从给定file路径读取bundle的配置信息
 */
+(NSDictionary *)getPropertiesFromLocalBundleFile:(NSString *)bundleFilePath{
    NSDictionary *properties = nil;
    if([bundleFilePath hasSuffix:BUNDLE_EXTENSION] &&[[NSFileManager defaultManager] fileExistsAtPath:bundleFilePath]){
        //限定ipa的名字和framework的名字相同
        NSString *bundleName = [[bundleFilePath lastPathComponent] stringByDeletingPathExtension];
        NSString *propertyfile = [NSString stringWithFormat:@"%@.framework/%@", bundleName, INFO_PLIST];
        @try {
            ZipFile *unzipFile = [[ZipFile alloc] initWithFileName:bundleFilePath mode:ZipFileModeUnzip];
            FileInZipInfo *currentInfo = nil;
            if([unzipFile locateFileInZip:propertyfile]){
                ZipReadStream *inZipData = [unzipFile readCurrentFileInZip];
                currentInfo = [unzipFile getCurrentFileInZipInfo];
                
                NSMutableData *inData = [[NSMutableData alloc] initWithLength:currentInfo.length];
                [inZipData readDataWithBuffer:inData];
                properties = [NSDictionary dictionaryWithContentsOfData:inData];
                inData = nil;
            }
            
            [unzipFile close];
        }
        @catch (ZipException *ze) {
            LOG(@"ZipException caught: %ld - %@", (long)ze.error, [ze reason]);
            
        }
        @catch(id e) {
            LOG(@"Exception caught: %@ - %@", [[e class] description], [e description]);
        }
        
        @finally {
        }
    }
    
    return properties;
}


/**
 * 从zip文件解压到指定位置
 */
+(BOOL)unZipFile:(NSString *)filePath destPath:(NSString *)destPath{
    BOOL success = NO;
    if([filePath hasSuffix:BUNDLE_EXTENSION] &&[[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        ZipArchive *zip = [[ZipArchive alloc] init];
        if([zip UnzipOpenFile:filePath]){
            success = [zip UnzipFileTo:destPath overWrite:YES];
            [zip UnzipCloseFile];
        }
    }
    
    return success;
}


/**
 * 获取ipa文件的CRC值
 */
+(long)getCRC32:(NSString *)filePath {
    return 1000;
}




/*
 //遍历zip文件
 NSArray *infos= [unzipFile listFileInZipInfos];
 FileInZipInfo *currentInfo=Nil;
 //列出所有在zip中的文件信息
 for (FileInZipInfo *info in infos) {
 //@"- %@ %@ %d (%d)"
 NSString *fileInfo= [NSString stringWithFormat:@"%@", info.name];
 LOG(@"list file: %@", info.name);
 }
 */

@end
