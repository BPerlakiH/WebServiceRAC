//
//  WebServiceRAC.m
//  Pods
//
//  Created by Balazs Perlaki-Horvath on 10/04/2015.
//
//

#import "WebServiceRAC.h"
#import "LocalCache.h"
#import "WSHelper.h"
#import "WebServiceCommon.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation WebServiceRAC

@synthesize isBackgroundMode, useCache;

- (id)initWithUrl: (NSString *)url {
    if(self = [super init]) {
        _baseUrl = url;
        _cache = [[LocalCache alloc] initWith: [NSString stringWithFormat:@"webservice.%@", CACHE_PREFIX]];
        useCache = true;
        isBackgroundMode = false;
    }
    return self;
}

- (NSString *)getLastCallID {
    return _callID;
}

- (LocalCache *) getCache {
    return _cache;
}


- (RACSignal *) callGet:(NSString *)method {
    return [self callGet:method with:nil];
}

- (RACSignal *) callPost:(NSString *)method {
    return [self callPost:method with:nil];
}

- (RACSignal *) callGet:(NSString *)method with:(NSDictionary *)parameters {
    return [self _call:method with:parameters and:false];
}

- (RACSignal *) callPost:(NSString *)method with:(NSDictionary *)parameters {
    return [self _call:method with:parameters and:true];
}

- (RACSignal *) _call:(NSString *) method with:(NSDictionary *) parameters and:(BOOL) isPost {
    if(_baseUrl == nil) {
        [NSException raise:@"WebServiceRAC._baseUrl not set" format:@"use [[WebServiceRAC alloc] initWithUrl:]"];
    }
    if(parameters == nil) {
        parameters = [[NSDictionary alloc] init];
    }
     _callID = [WSHelper getKeyFor:method and:parameters];
    DLog(@"%@", [method stringByAppendingString:[NSString stringWithFormat:@"(%@)", [WSHelper hashFor:parameters] ]]);
    //currently should not cache POST requests!
    if(!isPost && useCache && [_cache isDataFor:_callID]) {
        return [self _getSignalCachedData: _callID];
    }
    

    NSURLRequest *request = [self _getRequestFor:method and:parameters with:isPost];
    return [self _getSignalRequestCall:request];
}

- (RACSignal *) _getSignalCachedData:(NSString *) callID {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [_cache getDataFor:_callID];
        [[self _getJSONFrom:data] subscribeNext:^(NSDictionary *jsonDict) {
            [subscriber sendNext:jsonDict];
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (RACSignal* ) _getSignalRequestCall: (NSURLRequest *) request {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(error != nil) {
                [self _debugResponse:data];
                DLog(@"%@", error);
                [subscriber sendError:error];
            } else if (data == nil) {
                [subscriber sendError:[NSError errorWithDomain:@"WebserviceRAC" code:1 userInfo:@{NSLocalizedDescriptionKey: @"data nil"}]];
            } else {
                if(![request.HTTPMethod isEqualToString:@"POST"] && useCache && ![_cache isDataFor:_callID]) {
                    [_cache writeData:data withKey:_callID];
                }
                
                [[self _getJSONFrom:data] subscribeNext:^(NSDictionary *jsonDict) {
                    [subscriber sendNext:jsonDict];
                } error:^(NSError *error) {
                    [subscriber sendError:error];
                }];
            }
        }];
        [task resume];
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal*) _getJSONFrom: (NSData*) data {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSError* error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error != nil) {
            [subscriber sendNext:jsonDict];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:error];
        }
        return nil;
    }];
}

- (NSURLRequest *) _getRequestFor:(NSString *) method and: (NSDictionary*) parameters with: (BOOL) isPost {
    NSURLRequest *request;
    if (isPost) {
        request = [WSHelper getPostRequest:_baseUrl and: method and: parameters inmode:isBackgroundMode];
    } else {
        request = [WSHelper getGetRequest: _baseUrl and: method and: parameters inmode:isBackgroundMode];
    }
    return request;
}

- (void) _debugResponse: (NSData*) data {
    #ifdef DEBUG_WS
        @try {
            NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            DLog(@"%@", s);
        }
        @catch (NSException *exception) {
            DLog(@"%@", exception.description);
        }
    #endif
}

@end