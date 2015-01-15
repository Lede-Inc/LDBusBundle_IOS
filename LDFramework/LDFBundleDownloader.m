//
//  LDFBundleDownloader.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/6/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFBundleDownloader.h"
#import "LDFDebug.h"
#import "LDFCommonDef.h"
#import "LDFFileManager.h"

@interface LDFBundleDownloader() <NSURLConnectionDataDelegate>{
    NSURLConnection *_currentConnection;
    long long _packageTotalByteLenth;
    long long _packageWrittenByteLenth;
    NSMutableData *_packageData;
    NSString *_fileName;
    
    id<LDFBundleDownloadListener> _listener;
    LDFBundle *_bundle;
}

@end


@implementation LDFBundleDownloader


+(BOOL) updateRemoteBundlePackage:(LDFBundle *)bundle delegate:(id<LDFBundleDownloadListener>) listener{
    if(!bundle || !bundle.updateURL || [bundle.updateURL isEqualToString:@""]){
        return NO;
    }
    
    LDFBundleDownloader *downloader = [[LDFBundleDownloader alloc] initBundleDownloaderWithBundle:bundle andDelegate:listener];
    if(downloader){
        NSString *realDownloadURL = [bundle.updateURL stringByAppendingFormat:@"?time=%d",rand()];
        [downloader startDownloadFromURL:realDownloadURL];
        return YES;
    }
    
    else {
        return NO;
    }
}


-(id) initBundleDownloaderWithBundle:(LDFBundle *)bundle andDelegate:(id<LDFBundleDownloadListener>) listener{
    self = [super init];
    if(self){
        _bundle = bundle;
        _packageTotalByteLenth = 0;
        _packageWrittenByteLenth = 0;
        _packageData = [[NSMutableData alloc] initWithCapacity:1000];
        _listener = listener;
    }
    return self;
}

-(void)dealloc {
    _packageData = nil;
    _listener = nil;
    _bundle = nil;
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
    if([_listener respondsToSelector:@selector(downloaderOnFinish:withBundle:)]){
        [_listener downloaderOnFinish:STATUS_ERR_DOWNLOAD withBundle:_bundle];
    }
}

//接受到服务端连接成功的回应
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _packageTotalByteLenth = [response expectedContentLength];
    _fileName = [response suggestedFilename];
    if(_listener && [_listener respondsToSelector:@selector(downloaderOnProgress:total:withBundle:)]){
        [_listener downloaderOnProgress:_packageWrittenByteLenth total:_packageTotalByteLenth withBundle:_bundle];
    }
    LOG(@"download file: %@, totalLength: %lld", _fileName, _packageTotalByteLenth);
}

//接受服务器端传回的数据
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    _packageWrittenByteLenth += data.length;
    [_packageData appendData:data];
    if(_listener && [_listener respondsToSelector:@selector(downloaderOnProgress:total:withBundle:)]){
        [_listener downloaderOnProgress:_packageWrittenByteLenth total:_packageTotalByteLenth withBundle:_bundle];
    }
    LOG(@"download file: %@, writtenLength: %lld/%lld", _fileName, _packageWrittenByteLenth,  _packageTotalByteLenth);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //数据写入doument
    if(_packageData && _packageWrittenByteLenth == _packageTotalByteLenth){
        NSString *newFileName = [[[_fileName lastPathComponent] stringByDeletingPathExtension] stringByAppendingFormat:@"_new.%@", BUNDLE_EXTENSION];
        NSString *toSavePath = [NSString stringWithFormat:@"%@/%@", [LDFFileManager bundleCacheDir], newFileName];
        //创建文件
        [_packageData writeToFile:toSavePath atomically:YES];
        if(_listener && [_listener respondsToSelector:@selector(downloaderOnFinish:withBundle:)]){
            [_listener downloaderOnFinish:STATUS_SCUCCESS withBundle:_bundle];
        }
    }
    
    //销毁connection
    _packageData = nil;
    _packageTotalByteLenth = _packageWrittenByteLenth = 0;
    _currentConnection = nil;
    _fileName = nil;
}

@end
