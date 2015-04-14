//
//  WSHelper.m
//  Pods
//
//  Created by Balazs Perlaki-Horvath on 10/04/2015.
//
//


#import "WSHelper.h"

@implementation WSHelper

+ (NSString *)getKeyFor:(NSString *)method and:(NSDictionary *)parameters {
    if(parameters == nil) {
        parameters = [[NSDictionary alloc] init];
    }
    NSString* key = [method stringByAppendingString: [WSHelper hashFor:parameters]];
    return key;
}

+ (NSString *)hashFor:(NSDictionary*) paramaters {
    NSString* keys = [[paramaters allKeys] componentsJoinedByString:@"_"];
    NSString* values = [[paramaters allValues] componentsJoinedByString:@"_"];
    return [NSString stringWithFormat:@"_%@_%@", keys, values];
}

+ (NSURLRequest *)getPostRequest:(NSString *)baseURL and:(NSString *)method and:(NSDictionary *)parameters inmode:(BOOL)isBackgroundMode {
    if(method == nil) {
        return nil;
    }
    NSURL *fullURL = [[NSURL URLWithString:baseURL] URLByAppendingPathComponent:method];
//    NSURL *fullURL = [WSHelper getFullURL:baseURL and:parameters];
//    fullURL = [fullURL URLByAppendingPathComponent:method];
    NSLog(@"Webservice call to POST: %@", fullURL.absoluteString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: fullURL];
    [request setHTTPMethod: @"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: [WSHelper toJSONData:parameters]];
    [request setTimeoutInterval:20];
    if(isBackgroundMode) {
        [request setNetworkServiceType:NSURLNetworkServiceTypeBackground];
    }
    return request;
}

+ (NSURLRequest *) getGetRequest:(NSString *)baseURL and:(NSString *)method and:(NSDictionary *)parameters inmode:(BOOL)isBackgroundMode {
    if(method == nil) {
        return nil;
    }
    NSURL *fullURL = [WSHelper getFullURL:baseURL and:parameters];
    fullURL = [fullURL URLByAppendingPathComponent:method];
    NSLog(@"Webservice call to GET: %@", fullURL.absoluteString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: fullURL];
    [request setHTTPMethod: @"GET"];
    [request setTimeoutInterval:20];
    if(isBackgroundMode) {
        [request setNetworkServiceType:NSURLNetworkServiceTypeBackground];
    }
    return request;
}

+ (NSData*) toJSONData: (NSDictionary*) parameters {
    if([NSJSONSerialization isValidJSONObject:parameters]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        return jsonData;
    } else {
        NSLog(@"WebService toJsonData invalid request (params: %@)",parameters);
        return nil;
    }
}

+ (NSURL*) getFullURL: (NSString *) baseURL and: (NSDictionary *) parameters {
    NSURLComponents *components = [NSURLComponents componentsWithString:baseURL];
    NSMutableArray *queryItems = [NSMutableArray array];
    if(parameters != nil) {
        for (NSString *key in parameters) {
            NSString *valueString;
            id valueObj = [parameters objectForKey:key];
            if ([valueObj  isKindOfClass:[NSString class]]) {
                valueString = valueObj;
            } else if ([valueObj respondsToSelector:@selector(stringValue)]) {
                valueString = [valueObj stringValue];
            }
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:valueString]];
        }
    }
    components.queryItems = queryItems;
    NSURL *url = components.URL;
    return url;
}


@end
