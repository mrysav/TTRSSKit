//
//  TTRSSClient.h
//  TTRSSClient
//
//  Created by Mitchell Rysavy on 1/22/14.
//  Copyright (c) 2014 Mitchell Rysavy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTRSSClient : NSObject

@property (nonatomic, readonly) bool isLoggedIn;

- (id)initWithURL:(NSString*)instance andUser:(NSString*)user andPassword:(NSString*)password success:(void (^)(NSDictionary* response))success failure:(void (^)(NSError* error))failure;

- (void)getApiLevelWithSuccess:(void (^)(NSNumber* level))success failure:(void (^)(NSError* error))failure;

- (void)getVersionWithSuccess:(void (^)(NSString* version))success failure:(void (^)(NSError* error))failure;

- (void)getUnreadCountWithSuccess:(void (^)(NSNumber* unread))success failure:(void (^)(NSError* error))failure;

//TODO: getCounters

- (void)getFeedsWithSuccess:(void (^)(NSArray* feeds))success failure:(void (^)(NSError* error))failure;

@end
