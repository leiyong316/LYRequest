//
//  LYRequest.h
//  testDownload
//
//  Created by Leon on 14-12-12.
//  Copyright (c) 2014年 __FULLNAME__. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@end
