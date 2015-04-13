//
//  LocalCache.m
//  Pods
//
//  Created by Balazs Perlaki-Horvath on 10/04/2015.
//
//

#import "WebServiceCommon.h"
#import "LocalCache.h"
#import <CommonCrypto/CommonDigest.h>


@implementation LocalCache

//static const NSInteger CACHE_MAX_AGE = 60 * 60 * 24 * CACHE_FOR_DAYS; // days

@synthesize diskCachePath = _diskCachePath, cacheTime = _cacheTime;

- (id)initWith:(NSString *)prefix {
    if ((self = [super init])) {
        _prefix = prefix;
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:prefix];
        
        if(USE_CACHE == false) {
            [self clearCache];
        }
    }
    return self;
}

- (void)setCacheTimeInDays:(int)days {
    _cacheTime = 60 * 60 * 24 * days;
}

- (NSString*) getFileNameForKey: (NSString *) key {
    if(!self.diskCachePath) return nil;
    
    NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:[self _getFileBaseNameForKey:key]];
    //    DLog(@"%@", filePath);
    return filePath;
}

- (NSString *) _getFileBaseNameForKey: (NSString*) key {
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    if(str == NULL) return nil;
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

- (NSString*) getURLForKey: (NSString *) key {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *p = paths[0];
    NSString *fullPath = [[p.relativePath stringByAppendingPathComponent:_prefix] stringByAppendingPathComponent:[self _getFileBaseNameForKey:key]];
    return fullPath;
}

- (BOOL)isDataFor:(NSString *)key {
    if(USE_CACHE == false) {
        return false;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [self getFileNameForKey:key];
    if(!filePath || filePath == nil || ![fm fileExistsAtPath:filePath]) {
        return false;
    } else {
        if(!_cacheTime || _cacheTime == 0) {
            if(self && [self respondsToSelector:@selector(setCacheTimeInDays:)]) {
                [self setCacheTimeInDays:CACHE_FOR_DAYS];
            } else {
                return false;
            }
        }
        //check if not expired:
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-_cacheTime];
        NSDictionary *attribs = [fm attributesOfItemAtPath:filePath error:nil];
        //        DLog("attribs: %@", attribs);
        NSDate *modDate = [attribs valueForKey:NSFileModificationDate];
        //        DLog(@"filePath: %@", filePath);
        //        DLog(@"mod: %@, expire: %@", modDate, expirationDate);
        if([expirationDate compare:modDate] == NSOrderedDescending) {
            //            DLog(@"expired");
            return false;
        } else {
            //            DLog(@"existing cache: %@", filePath);
            return true;
        }
    }
}

- (void) clearDataFor: (NSString*) key {
    //    DLog(@"key: %@", key);
    NSString *filePath = [self getFileNameForKey:key];
    DLog(@"cache for path: %@ cleared", filePath);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if(!filePath || ![fm fileExistsAtPath:filePath]) {
        //already cleared:
        //        DLog(@"already cleared: %@", key);
        return;
    }
    
    NSError *error;
    [fm removeItemAtPath:filePath error:&error];
    if(error) {
        //        DLog(@"%@", error.description);
    }
}

- (void)writeData:(NSData *)data withKey:(NSString *)key {
    //    dispatch_async(GET_GLOBAL_QUEUE_KEY, ^{
    NSString *filePath = [self getFileNameForKey:key];
    if(!filePath) return;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    if([fm fileExistsAtPath:filePath]) {
        [fm removeItemAtPath:filePath error:nil];
    }
    if(data == nil || data == NULL) return;
    
    if (![fm fileExistsAtPath:_diskCachePath]){
        [fm createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if(![fm createFileAtPath:filePath contents:data attributes:nil]) {
        DLog(@"Error was code: %d - message: %s", errno, strerror(errno));
    }
    //    });
}

- (NSData *)getDataFor:(NSString *)key {
    @try {
        if(![self isDataFor:key]) return nil;
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *filePath = [self getFileNameForKey:key];
        if(!filePath) return nil;
        return [fm contentsAtPath:[self getFileNameForKey:key]];
    }
    @catch (NSException *exception) {
        DLog(@"%@", exception.description);
    }
    @try {
        [self clearDataFor:key];
    } @catch (NSException *clearException) {
        DLog(@"%@", clearException.description);
    }
    return nil;
}

- (void)clearCache {
    NSError *error;
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:self.diskCachePath]) {
        [fm removeItemAtPath:self.diskCachePath error:&error];
    }
}



@end