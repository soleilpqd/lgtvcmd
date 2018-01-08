//
//  LTCDeviceConnector.m
//  lgtvcmd
//
//  Created by DươngPQ on 25/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCDeviceConnector.h"
#import "LTCDiscover.h"
#import "LTCTask.h"
@import ConnectSDK_Mac;

@interface LTCDeviceConnector() <ConnectableDeviceDelegate>

@property ( nonatomic, assign ) NSUInteger taskCounter;
@property ( nonatomic, readwrite ) LTCDeviceConnectorStatus status;

@end

@implementation LTCDeviceConnector

-( instancetype )initWithDevice:( ConnectableDevice* )device {
    if ( self = [ super init ]) {
        _device = device;
        _status = kLTCStatusDisconnected;
        _connectionQueue = dispatch_queue_create(device.address.UTF8String, nil);
    }
    return self;
}

-( void )connect {
    dispatch_async( dispatch_get_main_queue(), ^{
        self.device.delegate = self;
        self.status = kLTCStatusConnecting;
        [ self.device setPairingType:DeviceServicePairingTypeFirstScreen ];
        [ self.device connect ];
    });
}

-( void )reconnect {
    self.device.delegate = nil;
    [ self.device disconnect ];
    [ self connect ];
}

-( void )disconnect {
    dispatch_async( dispatch_get_main_queue(), ^{
        self.device.delegate = nil;
        [ self.device disconnect ];
    });
}

-( void )incTaskCount {
    _taskCounter += 1;
    LTCLog( @"%@ %ld", self.description, self.taskCounter );
}

-( void )decTaskCount {
    if ( self.taskCounter > 0 )
        _taskCounter -= 1;
    LTCLog( @"%@ %ld", self.description, self.taskCounter );
    if ( self.taskCounter < 1 ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), self.connectionQueue, ^{
            [ self allTasksFinished ];
        });
    }
}

-( void )allTasksFinished {
    if ( self.taskCounter > 0 ) return;
    LTCLog( @"%@", self.description );
    _isFinished = YES;
    [ self disconnect ];
    [[ LTCDiscover shared ] deviceDidFinishTasks:self ];
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p> %@ %@", self.className, self, self.device.friendlyName, self.device.address ];
}

#pragma mark - Connect Delegate

-( void )connectableDeviceReady:( ConnectableDevice* )device {
    BOOL found = NO;
    for ( DeviceService *service in device.services ) {
        if ([ service.serviceName isEqualToString:@"webOS TV" ] && service.connected ) {
            found = YES;
            break;
        }
    }
    if ( found && _status != kLTCStatusConnected ) {
        LTCLog( @"%@", self.description );
        _status = kLTCStatusConnected;
        [[ LTCDiscover shared ] deviceReady:self ];
    }
}

-( void )connectableDevice:( ConnectableDevice* )device connectionFailedWithError:( NSError* )error {
    LTCLog( @"%@ %@", self.description, error.description );
}

-( void )connectableDeviceDisconnected:( ConnectableDevice* )device withError:( NSError* )error {
//    LTCLog( @"%@ %@", self.description, error.description );
}

-( void )connectableDevice:( ConnectableDevice* )device service:( DeviceService* )service
     pairingRequiredOfType:( int )pairingType withData:( id )pairingData {
    _status = kLTCStatusPairing;
    LTCLog( @"%@ %i %@", self.description, pairingType, pairingData );
}

-( void )connectableDevicePairingSuccess:( ConnectableDevice* )device service:( DeviceService* )service {
    LTCLog( @"%@", self.description );
}

-( void )connectableDevice:( ConnectableDevice* )device service:( DeviceService* )service pairingFailedWithError:( NSError* )error {
    LTCLog( @"%@ %@", self.description, error );
    _status = kLTCStatusConnecting;
}

@end
