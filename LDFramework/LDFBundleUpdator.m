//
//  LDFBundleUpdator.m
//  LDBusBundle
//
//  Created by 庞辉 on 1/7/15.
//  Copyright (c) 2015 庞辉. All rights reserved.
//

#import "LDFBundleUpdator.h"

@interface LDFBundleUpdator () {
    id<LDFBundleUpdatorListener> _listener;
    
    NSMutableData *_responseData;
}
@end


@implementation LDFBundleUpdator

+(void)refreshRemoteBundleInfoWithURL:(NSString *) refreshURLString delegate:(id<LDFBundleUpdatorListener>) listener{
    if(!refreshURLString || [refreshURLString isEqualToString:@""]){
        return;
    }
    
    [[LDFBundleUpdator sharedBundleUpdator] refreshRemoteBundleInfoWithURL:refreshURLString delegate:listener];
}


+ (instancetype)sharedBundleUpdator
{
    static LDFBundleUpdator *bundleUpdator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundleUpdator = [[LDFBundleUpdator alloc] init];
    });
    return bundleUpdator;
}


-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}


-(void) refreshRemoteBundleInfoWithURL:(NSString *) refreshURLString delegate:(id<LDFBundleUpdatorListener>) listener {
    _listener = listener;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:refreshURLString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setHTTPMethod:@"GET"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection start];
}


#pragma mark connection-delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] initWithCapacity:1000];
}


//接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_responseData appendData:data];
}


//数据传完之后调用此方法
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    id resultJson = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableLeaves error:nil];
    NSArray *items = [resultJson objectAtIndex:0];
    if(_listener && [_listener respondsToSelector:@selector(updatorOnSuccess:)]){
        [_listener updatorOnSuccess:items];
    }
}

//网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
-(void)connection:(NSURLConnection *)connection
 didFailWithError:(NSError *)error{
    if(_listener && [_listener respondsToSelector:@selector(updatorOnFailure)]){
        [_listener updatorOnFailure];
    }
}



@end
