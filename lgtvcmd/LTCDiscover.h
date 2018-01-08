//
//  LTCDiscover.h
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LTCLog(format, ...) LTCLogFunc(__FUNCTION__, (format),  ##__VA_ARGS__)

extern void LTCLogFunc(const char * _Nonnull funcName, NSString * _Nonnull format, ...);

@class LTCTask;
@class LTCDeviceConnector;

@interface LTCDiscover : NSObject

+( nonnull instancetype )shared;

@property ( nonatomic, copy, nonnull ) NSArray<LTCTask*>* tasks;
@property ( nonatomic, readonly ) BOOL isStoppable;
@property ( nonatomic, assign ) NSUInteger numberOfSynchDevices;

-( void )deviceReady:( nonnull LTCDeviceConnector* )connector;
-( void )start:( NSUInteger )timeoutSeconds;
-( void )stop;
-( void )deviceDidFinishTasks:( nonnull LTCDeviceConnector* )connector;

@end
