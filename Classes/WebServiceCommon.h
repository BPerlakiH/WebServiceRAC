//
//  WebServiceCommon.h
//  Pods
//
//  Created by Balazs Perlaki-Horvath on 10/04/2015.
//
//

#ifndef Pods_WebServiceCommon_h

    #define Pods_WebServiceCommon_h

    #ifndef DLog
        #ifdef DEBUG
            #define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
        #else
            #define DLog(...)
        #endif
    #endif

    #ifndef GET_GLOBAL_QUEUE_KEY
        #define GET_GLOBAL_QUEUE_KEY dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    #endif

#endif
