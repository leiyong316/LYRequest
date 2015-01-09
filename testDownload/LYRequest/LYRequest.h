//
//  LYRequest.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LYRequestType) {
    LYRequestTypeDefault,       //default get or post
    LYRequestTypeDownload,
    LYRequestTypeUpload
};

typedef void(^RequestFinishBlock)(NSData *data);
typedef void(^RequestErrorBlock)(NSURLConnection *connection,NSError *error);
typedef void(^RequestProgressBlock)(float progress);

@interface LYRequest : NSMutableURLRequest<NSURLConnectionDataDelegate,NSURLConnectionDelegate>

+ (instancetype)shareInstance;
- (void)cancelAsyncRequest;

/**
 *  网络请求 默认get方法  (default GET Method)
 *
 *  @param url     请求地址
 *  @param success success
 *  @param error   error
 */
- (void)requestWithURL:(NSURL*)url
           finishBlock:(RequestFinishBlock)success
            errorBlock:(RequestErrorBlock)error;

/**
 *  网络请求
 *
 *  @param url     请求地址
 *  @param param   请求参数
 *  @param method  method
 *  @param use     是否使用缓存（目前缓存没有，加续加上）
 *  @param success success
 *  @param error   error
 */
- (void)requestWithURL:(NSURL*)url
                params:(NSDictionary*)param
                method:(NSString*)method
              useCache:(BOOL)use
           finishBlock:(RequestFinishBlock)success
            errorBlock:(RequestErrorBlock)error;

/**
 *  文件下载
 *
 *  @param url      下载地址
 *  @param progress 下载进度
 *  @param success  下载成功处理
 *  @param error    下载失败处理
 */
- (void)downloadWithURL:(NSURL*)url
          progressBlock:(RequestProgressBlock)progress
            finishBlock:(RequestFinishBlock)success
             errorBlock:(RequestErrorBlock)error;


/**
 *  文件上传
 *
 *  @param url      上传地址
 *  @param filename 文件名
 *  @param params   上传参数
 *  @param filepath 文件路径
 *  @param progress 上传进度
 *  @param success  上传成功处理
 *  @param error    上传失败处理
 */
- (void)uploadWithURL:(NSURL*)url
             filename:(NSString*)filename
               params:(NSDictionary*)params
             filePath:(NSString*)filepath
             progress:(RequestProgressBlock)progress
               finish:(RequestFinishBlock)success
                error:(RequestErrorBlock)error;

@end
