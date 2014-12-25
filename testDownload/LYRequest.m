//
//  LYRequest.m
//  testDownload
//
//  Created by Leon on 14-12-12.
//  Copyright (c) 2014年 __FULLNAME__. All rights reserved.
//

#import "LYRequest.h"

#define GET     @"GET"
#define POST    @"POST"

@interface LYRequest()
@property (nonatomic, assign) long long             filesize;
@property (nonatomic, retain) NSMutableData         *data;
@property (nonatomic, retain) NSURLConnection       *connection;
@property (nonatomic, copy) RequestFinishBlock      requestFinish;
@property (nonatomic, copy) RequestErrorBlock       requestError;
@property (nonatomic, copy) RequestProgressBlock    requestProgress;
@end

@implementation LYRequest

+ (id)allocWithZone:(struct _NSZone *)zone{
    static LYRequest *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

+ (instancetype)shareInstance {
    return [[self alloc] init];
}

- (void)requestWithURL:(NSURL*)url
           finishBlock:(RequestFinishBlock)success
            errorBlock:(RequestErrorBlock)error{
    [self requestWithURL:url params:nil method:GET useCache:NO finishBlock:success errorBlock:error];
}

- (void)requestWithURL:(NSURL*)url
                params:(NSDictionary*)param
                method:(NSString*)method
              useCache:(BOOL)use
           finishBlock:(RequestFinishBlock)success
            errorBlock:(RequestErrorBlock)error{
    [self setURL:url];
    [self setHTTPMethod:method];
    if (success){
        self.requestFinish   = success;
    }
    if (error){
        self.requestError    = error;
    }
    if ([[method uppercaseString] isEqualToString:POST]) {
        NSData *data = [[self urlEncodedKeyValueString:param] dataUsingEncoding:NSUTF8StringEncoding];
        [self setHTTPBody:data];
    }
    [self startAsyncRequest];
}

- (void)downloadWithURL:(NSURL*)url
          progressBlock:(RequestProgressBlock)progress
            finishBlock:(RequestFinishBlock)success
             errorBlock:(RequestErrorBlock)error{
    
    if (progress){
        self.requestProgress = progress;
    }
    [self requestWithURL:url
                  params:nil
                  method:GET
                useCache:NO
             finishBlock:success
              errorBlock:error];
}

//请求网络
- (void)startAsyncRequest{
    self.data       = [NSMutableData data];
    self.connection = [NSURLConnection connectionWithRequest:self delegate:self];
}

//取消请求
- (void)cancelAsyncRequest{
    if (self.connection) {
        [self.connection cancel];
    }
}

#pragma mark <NSURLConnectionDataDelegate>
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if (self.requestProgress) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
            NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
            self.filesize = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.data appendData:data];
    if (self.requestProgress) {
        float progress  = self.data.length/(float)self.filesize;
        float d = round(progress*100);
        self.requestProgress(d);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.requestFinish(_data);
    if (self.requestProgress) {
        self.requestProgress = nil;
    }
}

#pragma mark <NSURLConnectionDelegate>
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.requestError(connection,error);
}


#pragma mark dictionary parse
-(NSString*) urlEncodedKeyValueString:(NSDictionary*)dict {
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in dict) {
        NSObject *value = [dict valueForKey:key];
        if([value isKindOfClass:[NSString class]]){
            [string appendFormat:@"%@=%@&", [self urlEncodedString:key], [self urlEncodedString:((NSString*)value)]];
        }else{
            [string appendFormat:@"%@=%@&", [self urlEncodedString:key], value];
        }
    }
    if([string length] > 0){
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    }
    return string;
}

- (NSString*) urlEncodedString:(NSString*)key {
    CFStringRef encodedCFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (__bridge CFStringRef) key,
                                                                          nil,
                                                                          CFSTR("?!@#$^&%*+,:;='\"`<>()[]{}/\\| "),
                                                                          kCFStringEncodingUTF8);
    NSString *encodedString = [[NSString alloc] initWithString:(__bridge_transfer NSString*) encodedCFString];
    if(!encodedString)
        encodedString = @"";
    return encodedString;
}
@end
