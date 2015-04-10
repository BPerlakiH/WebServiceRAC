//
//  WebServiceRAC.h
//  Pods
//
//  Created by Balazs Perlaki-Horvath on 10/04/2015.
//
//

#import <Foundation/Foundation.h>
@class LocalCache;
@class RACSignal;

@interface WebServiceRAC : NSObject {
    NSString *_baseUrl;
    NSString *_callID;
    LocalCache __strong *_cache;
}

@property BOOL useCache, isBackgroundMode;

- (id) initWithUrl: (NSString *) url;
- (NSString *) getLastCallID;
- (LocalCache*) getCache;

- (RACSignal *) callGet:(NSString *)method;
- (RACSignal *) callGet:(NSString *)method with:(NSDictionary *)parameters;

- (RACSignal *) callPost:(NSString *)method;
- (RACSignal *) callPost:(NSString *)method with:(NSDictionary *)parameters;


@end
