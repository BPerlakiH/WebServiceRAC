//
//  WSHelper.h
//  Pods
//
//  Created by Balazs Perlaki-Horvath on 10/04/2015.
//
//

#import <Foundation/Foundation.h>

@interface WSHelper : NSObject

+ (NSString *) getKeyFor:(NSString *)method and:(NSDictionary *)parameters;
+ (NSString *) hashFor:(NSDictionary *) paramaters;

+ (NSURLRequest *) getPostRequest:(NSString*) baseURL and: (NSString *) method and:(NSDictionary *) parameters inmode: (BOOL) isBackgroundMode;
+ (NSURLRequest *) getGetRequest:(NSString*) baseURL and: (NSString *) method and:(NSDictionary *) parameters inmode: (BOOL) isBackgroundMode;

+ (NSData *) toJSONData: (NSDictionary*) parameters;

@end
