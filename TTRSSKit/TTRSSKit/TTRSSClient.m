//
//  TTRSSClient.m
//  TTRSSClient
//
//  Created by Mitchell Rysavy on 1/22/14.
//  Copyright (c) 2014 Mitchell Rysavy. All rights reserved.
//

#import "TTRSSClient.h"
#import "AFNetworking/AFNetworking.h"

@interface TTRSSClient ()

@property (nonatomic, strong) AFHTTPSessionManager* afclient;

@property (nonatomic, strong) NSString* instance_url;

@property (nonatomic, strong) NSString* session_id;

- (void)makeApiRequestWithArgs:(NSDictionary*)args success:(void (^)(id response))success failure:(void (^)(NSError* error))failure;

@end

@implementation TTRSSClient

@synthesize instance_url;
@synthesize session_id;
@synthesize afclient;
@synthesize isLoggedIn = _isLoggedIn;

- (id)initWithURL:(NSString*)instance andUser:(NSString*)user andPassword:(NSString*)password success:(void (^)(NSDictionary* response))success failure:(void (^)(NSError* error))failure {
    
    self = [super init];
    if (self) {
        self.instance_url = instance;
        
        NSMutableDictionary* arguments = [[NSMutableDictionary alloc] init];
        [arguments setObject:@"login" forKey:@"op"];
        [arguments setObject:user forKey:@"user"];
        [arguments setObject:password forKey:@"password"];
        
        afclient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:instance_url]];
        afclient.responseSerializer = [AFJSONResponseSerializer serializer];
        afclient.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [self makeApiRequestWithArgs:arguments success:^(NSDictionary *response) {
            self.session_id = [response objectForKey:@"session_id"];
            _isLoggedIn = true;
            success(response);
        } failure:^(NSError *error) {
            failure(error);
        }];
    }
    
    return self;
}

- (void)makeApiRequestWithArgs:(NSMutableDictionary*)args success:(void (^)(id response))success failure:(void (^)(NSError* error))failure {
    
    if (self.isLoggedIn) {
        [args setObject:self.session_id forKey:@"sid"];
    }
    else {
        NSLog(@"WARNING: You are not authenticated. Some API methods may fail.");
    }
    
    [afclient POST:@"api/" parameters:args success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSDictionary* response = (NSDictionary*)responseObject;
        
        NSNumber* status = [response objectForKey:@"status"];
        
        if ([status integerValue] == 1) {
            NSString* msg = [[response objectForKey:@"content"] objectForKey:@"error"];
            NSMutableDictionary* details = [[NSMutableDictionary alloc] init];
            [details setObject:msg forKey:NSLocalizedDescriptionKey];
            failure([NSError errorWithDomain:@"ttrsskit" code:500 userInfo:details]);
        }
        else {
            success([response objectForKey:@"content"]);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)getApiLevelWithSuccess:(void (^)(NSNumber* level))success failure:(void (^)(NSError* error))failure {
    
    NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
    [args setObject:@"getApiLevel" forKey:@"op"];
    
    [self makeApiRequestWithArgs:args success:^(NSDictionary *response) {
        NSNumber* level = [response objectForKey:@"level"];
        success(level);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getVersionWithSuccess:(void (^)(NSString* version))success failure:(void (^)(NSError* error))failure {
    
    NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
    [args setObject:@"getVersion" forKey:@"op"];
    
    [self makeApiRequestWithArgs:args success:^(NSDictionary *response) {
        NSString* version = [response objectForKey:@"version"];
        success(version);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getUnreadCountWithSuccess:(void (^)(NSNumber* unread))success failure:(void (^)(NSError* error))failure {
    
    NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
    [args setObject:@"getUnread" forKey:@"op"];
    
    [self makeApiRequestWithArgs:args success:^(NSDictionary *response) {
        // this is stupid, the docs say it returns an int but it returns a string
        NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
        NSNumber* unread =  [formatter numberFromString:[response objectForKey:@"unread"]];
        success(unread);
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getFeedsWithSuccess:(void (^)(NSArray* feeds))success failure:(void (^)(NSError* error))failure {
    NSMutableDictionary* args = [[NSMutableDictionary alloc] init];
    [args setObject:@"getFeeds" forKey:@"op"];
    // optional parameters
    
    [self makeApiRequestWithArgs:args success:^(NSArray *response) {
        success(response);
    } failure:^(NSError *error) {
        failure(error);
    }];
}



@end
