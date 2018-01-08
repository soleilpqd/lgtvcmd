//
//  LTCDeviceConnector.h
//  lgtvcmd
//
//  Created by DươngPQ on 25/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ConnectSDK_Mac;

typedef NS_ENUM( NSUInteger, LTCDeviceConnectorStatus ) {
    kLTCStatusDisconnected, kLTCStatusConnecting, kLTCStatusPairing, kLTCStatusConnected
};

@class LTCTask;

@interface LTCDeviceConnector : NSObject

@property ( nonatomic, readonly ) LTCDeviceConnectorStatus status;
@property ( nonatomic, readonly, nonnull ) ConnectableDevice *device;
@property ( nonatomic, readonly ) BOOL isFinished;
@property ( nonatomic, readonly, nonnull ) dispatch_queue_t connectionQueue;

-( nonnull instancetype )initWithDevice:( nonnull ConnectableDevice* )device;

-( void )connect;
-( void )reconnect;
-( void )disconnect;
-( void )incTaskCount;
-( void )decTaskCount;

@end
