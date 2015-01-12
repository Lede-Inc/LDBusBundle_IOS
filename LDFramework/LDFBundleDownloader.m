//
//  LDFBundleDownloader.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/6/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFBundleDownloader.h"
#import "LDFDebug.h"
#import "LDFFileManager.h"

@interface LDFBundleDownloader() <NSURLConnectionDataDelegate>{
    NSURLConnection *_currentConnection;
    long long _packageTotalByteLenth;
    long long _packageWrittenByteLenth;
    NSMutableData *_packageData;
    NSString *_fileName;
    
    id<LDBundleDownloadListener> _listener;
}

@end


@implementation LDFBundleDownloader


+(void) updateRemoteBundlePackage:(NSString *)downloadURLString delegate:(id<LDBundleDownloadListener>) listener{
    if(!downloadURLString || [downloadURLString isEqualToString:@""]){
        return;
    }
    
    LDFBundleDownloader *downloader = [[LDFBundleDownloader alloc] initBundleDownloaderWithDelegate:listener];
    if(downloader){
        [downloader startDownloadFromURL:downloadURLString];
    }
}


-(id) initBundleDownloaderWithDelegate:(id<LDBundleDownloadListener>) listener{
    self = [super init];
    if(self){
        _packageTotalByteLenth = 0;
        _packageWrittenByteLenth = 0;
        _packageData = [[NSMutableData alloc] initWithCapacity:1000];
        _listener = listener;
    }
    return self;
}


-(void) startDownloadFromURL:(NSString *) downloadURLString {
    NSURL *url = [NSURL URLWithString:downloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _currentConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if(_currentConnection){
        LOG(@"bundle download connection is created successfully: %@", @"hello");
    } else {
        LOG(@"bundle download connection is created failly: %@", @"hello");
    }
}


#pragma mark  connection-data-delegate
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    LOG(@"connection did failWithEroor");
    //销毁connection
    _packageData = nil;
    _currentConnection = nil;
    _fileName = nil;
    [_listener downloaderOnFinish:0];
}

//接受到服务端连接成功的回应
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _packageTotalByteLenth = [response expectedContentLength];
    _fileName = [response suggestedFilename];
    if(_listener && [_listener respondsToSelector:@selector(downloaderOnProgress:total:)]){
        [_listener downloaderOnProgress:_packageWrittenByteLenth total:_packageTotalByteLenth];
    }
    LOG(@"download file: %@, totalLength: %lld", _fileName, _packageTotalByteLenth);
}

//接受服务器端传回的数据
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    _packageWrittenByteLenth += data.length;
    [_packageData appendData:data];
    if(_listener && [_listener respondsToSelector:@selector(downloaderOnProgress:total:)]){
        [_listener downloaderOnProgress:_packageWrittenByteLenth total:_packageTotalByteLenth];
    }
    LOG(@"download file: %@, writtenLength: %lld/%lld", _fileName, _packageWrittenByteLenth,  _packageTotalByteLenth);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //数据写入doument
    if(_packageData && _packageWrittenByteLenth == _packageTotalByteLenth){
        NSString *toSavePath = [NSString stringWithFormat:@"%@/%@", [LDFFileManager bundleCacheDir], _fileName];
        //创建文件
        [_packageData writeToFile:toSavePath atomically:YES];
        if(_listener && [_listener respondsToSelector:@selector(onFinish:)]){
            [_listener downloaderOnFinish:_packageTotalByteLenth];
        }
    }
    
    //销毁connection
    _packageData = nil;
    _packageTotalByteLenth = _packageWrittenByteLenth = 0;
    _currentConnection = nil;
    _fileName = nil;
}

@end
