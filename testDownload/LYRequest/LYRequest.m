//
//  LYRequest.m
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Leon https://github.com/leiyong316
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "LYRequest.h"

#define GET     @"GET"
#define POST    @"POST"

@interface LYRequest()

/**
 *  下载时的文件总大小
 */
@property (nonatomic, assign) long long             filesize;

/**
 *  请求data
 */
@property (nonatomic, strong) NSMutableData         *data;

/**
 *  请求connection
 */
@property (nonatomic, strong) NSURLConnection       *connection;

/**
 *  请求成功处理block
 */
@property (nonatomic, copy) RequestFinishBlock      requestFinish;

/**
 *  请求失败处理block
 */
@property (nonatomic, copy) RequestErrorBlock       requestError;

/**
 *  上传或下载progress
 */
@property (nonatomic, copy) RequestProgressBlock    requestProgress;

/**
 *  请求类型, 普通请求(get/post)或者上传下载
 */
@property (nonatomic, assign) LYRequestType requestType;
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

- (instancetype)init{
    self = [super init];
    if (self) {
        self.requestType = LYRequestTypeDefault;
    }
    return self;
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
    if (self.requestType == LYRequestTypeDefault &&
        [[method uppercaseString] isEqualToString:POST]) {
        NSData *data = [[self urlEncodedKeyValueString:param] dataUsingEncoding:NSUTF8StringEncoding];
        [self setHTTPBody:data];
    }
    [self startAsyncRequest];
}

- (void)downloadWithURL:(NSURL*)url
          progressBlock:(RequestProgressBlock)progress
            finishBlock:(RequestFinishBlock)success
             errorBlock:(RequestErrorBlock)error{
    self.requestType = LYRequestTypeDownload;
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

- (void)uploadWithURL:(NSURL*)url
             filename:(NSString*)filename
               params:(NSDictionary*)params
             filePath:(NSString*)filepath
             progress:(RequestProgressBlock)progress
               finish:(RequestFinishBlock)success
                error:(RequestErrorBlock)error{    
    self.requestType = LYRequestTypeUpload;
    [self setURL:url];
    [self setHTTPMethod:@"POST"];
    if (success){
        self.requestFinish   = success;
    }
    if (error){
        self.requestError    = error;
    }
    if (progress){
        self.requestProgress = progress;
    }
    NSString *mimeType = [self getFileMIMEType:filepath];
    NSMutableData *body = [NSMutableData data];
    NSString *boundary = @"0xKhTmLbOuNdArY";
    NSString *thisFieldString = [NSString stringWithFormat:
                                 @"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n",
                                 boundary,
                                 @"file",
                                 filename,
                                 mimeType];
    [body appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithContentsOfFile:filepath]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *thisFieldString = [NSString stringWithFormat:
                                     @"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n",
                                     boundary, key, obj];
        [body appendData:[thisFieldString dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    NSString *overString = [NSString stringWithFormat:@"--%@--\r\n",boundary];
    [body appendData:[overString dataUsingEncoding:NSUTF8StringEncoding]];
    [self setHTTPBody:body];
    [self setValue:[NSString stringWithFormat:@"%lu", (unsigned long)body.length] forHTTPHeaderField:@"Content-Length"];
    [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    [self startAsyncRequest];
}


/**
 *  获取文件mimeType
 *
 *  @param path 文件路径
 *
 *  @return mimeType
 */
- (NSString*)getFileMIMEType:(NSString*)path{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]];
    NSError *error;
    NSURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
    return [response MIMEType];
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
    if (self.requestType == LYRequestTypeDownload && self.requestProgress) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
            NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
            self.filesize = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.data appendData:data];
    if (self.requestType == LYRequestTypeDownload && self.requestProgress) {
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

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
                                               totalBytesWritten:(NSInteger)totalBytesWritten
                                       totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (self.requestType == LYRequestTypeUpload && self.requestProgress) {
        if(totalBytesExpectedToWrite > 0) {
            self.requestProgress(round(((double)totalBytesWritten/(double)totalBytesExpectedToWrite)*100));
        }
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
