//
//  LocalCache.h
//  Pods
//
//  Created by Balazs Perlaki-Horvath on 10/04/2015.
//
//

//set some default values:
#ifndef USE_CACHE
#   define USE_CACHE true
#endif

#ifndef CACHE_FOR_DAYS
#   define CACHE_FOR_DAYS 7
#endif

#ifndef CACHE_PREFIX
#   define CACHE_PREFIX @"General"
#endif


#import <Foundation/Foundation.h>

@interface LocalCache : NSObject {
    NSString *_prefix;
}

@property (strong, nonatomic) NSString *diskCachePath;
@property (nonatomic, readonly) NSInteger cacheTime;

- (id) initWith: (NSString*) prefix;
- (BOOL) isDataFor: (NSString* ) key;
- (void) clearDataFor: (NSString*) key;
- (void) writeData: (NSData *) data withKey: (NSString*) key;
- (NSData *) getDataFor: (NSString*) key;
- (NSString*) getFileNameForKey: (NSString *) key;
- (NSString*) getURLForKey: (NSString *) key;
- (void) setCacheTimeInDays: (int) days;

- (void) clearCache;

@end
