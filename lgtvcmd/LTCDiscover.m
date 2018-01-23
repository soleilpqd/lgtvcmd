//
//  LTCDiscover.m
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCDiscover.h"
#import "LTCDeviceConnector.h"
#import "LTCTask.h"
#import <pthread.h>
#import "LTCDeviceStore.h"

@import ConnectSDK_Mac;

void LTCLogFunc( const char *funcName, NSString *format, ... ) {
    va_list args;
    va_start( args, format );
    NSString *content = [[ NSString alloc ] initWithFormat:format arguments:args ];
    va_end( args );
    printf("[%s - %d%s] %s:\n%s\n", [ NSDate date ].description.UTF8String,
           pthread_mach_thread_np(pthread_self()),
           [ NSThread isMainThread ] ? "-m" : "",
           funcName, content.UTF8String);
}

@interface LTCDiscover() <DiscoveryManagerDelegate>

@property ( nonatomic, strong ) NSMutableArray<LTCDeviceConnector*>* connectors;
@property ( nonatomic, assign ) BOOL isTimeout;
@property ( nonatomic, strong ) LTCDeviceStore *store;

@end

@implementation LTCDiscover

+( instancetype )shared {
    static LTCDiscover *_defaultDiscover;
    if ( _defaultDiscover == nil ) _defaultDiscover = [ LTCDiscover new ];
    return _defaultDiscover;
}

-( void )start:( NSUInteger )timeoutSeconds {
    if ( self.tasks == nil || self.tasks.count == 0 ) {
        [ NSException raise:@"LTCDiscover" format:@"No task specified" ];
        exit(1);
    }
    LTCLog( @"%ld", timeoutSeconds );
    if ( self.connectors == nil ) _connectors = [ NSMutableArray new ];
    if ( self.store == nil ) _store = [ LTCDeviceStore new ];
    DiscoveryManager *manager = [ DiscoveryManager sharedManagerWithDeviceStore:self.store ];
    manager.pairingLevel = DeviceServicePairingLevelOn;
    manager.delegate = self;
    [ manager startDiscovery ];
    [ self performSelector:@selector( timeout ) withObject:nil afterDelay:timeoutSeconds ];
}

-( void )stop {
    dispatch_async( dispatch_get_main_queue(), ^{
        [[ DiscoveryManager sharedManager ] stopDiscovery ];
        _isTimeout = YES;
    });
}

-( void )refreshListDevices {
    NSArray<ConnectableDevice*> *devices = [[[ DiscoveryManager sharedManager ] compatibleDevices ] allValues ];
    // Remove unfound devices
    NSArray *tempDevices = [ self.connectors copy ];
    for ( LTCDeviceConnector *connector in tempDevices ) {
        if (![ devices containsObject:connector.device ]) {
            [ connector disconnect ];
            [ self.connectors removeObject:connector ];
        }
    }
    // Create new connector or retry connect (because new update)
    for ( ConnectableDevice *device in devices ) {
        LTCDeviceConnector *devConnector = nil;
        for ( LTCDeviceConnector *connector in self.connectors ) {
            if ( connector.device == device ) {
                devConnector = connector;
                break;
            }
        }
        if ( devConnector == nil ) {
            devConnector = [[ LTCDeviceConnector alloc ] initWithDevice:device ];
            [ self.connectors addObject:devConnector ];
            [ devConnector connect ];
        } else {
            if ( devConnector.status == kLTCStatusDisconnected || devConnector.status == kLTCStatusConnecting ) {
                [ devConnector reconnect ];
            }
        }
    }
}

-( void )timeout {
    if ( self.isTimeout ) return;
    LTCLog(@"");
    _isTimeout = YES;
    [ self finishIfNeeded ];
    if ( self.numberOfSynchDevices > 0 ) {
        NSUInteger count = 0;
        for ( LTCDeviceConnector *conn in self.connectors ) {
            if ( conn.status == kLTCStatusConnected ) count += 1;
        }
        if ( count == self.connectors.count ) {
            [ self performTaskWithConnectors:self.connectors ];
        }
    }
}

-( void )performTaskWithConnectors:( NSArray<LTCDeviceConnector*>* )connectors {
    LTCLog( @"Start tasks with connectors:\n%@", connectors );
    for ( LTCTask *task in self.tasks) {
        [ task performWithConnectors:self.connectors previousTask:nil ];
    }
}

-( void )finishIfNeeded {
    if ( !self.isTimeout ) return;
    [ self stop ];
    for ( LTCDeviceConnector *connector in self.connectors ) {
        if ( !connector.isFinished && connector.status == kLTCStatusConnected ) {
            // There's connector which is still working
            return;
        }
    }
    LTCLog(@"");
    _isStoppable = YES;
    for ( LTCDeviceConnector *connector in self.connectors ) {
        [ connector disconnect ];
    }
}


#pragma mark - Connector delegate

-( void )deviceReady:( LTCDeviceConnector* )connector {
    LTCLog( @"Device ready %@", connector );
    dispatch_async( dispatch_get_main_queue(), ^{
        if ( self.numberOfSynchDevices > 0 ) {
            NSUInteger count = 0;
            for ( LTCDeviceConnector *conn in self.connectors ) {
                if ( conn.status == kLTCStatusConnected ) count += 1;
            }
            if ( count >= self.numberOfSynchDevices || self.isTimeout ){
                [ self performTaskWithConnectors:self.connectors ];
                [ self stop ];
            }
        } else {
            [ self performTaskWithConnectors:@[ connector ]];
        }
    });
}

-( void )deviceDidFinishTasks:( LTCDeviceConnector* )connector {
    LTCLog( @"Device finished tasks %@", connector );
    dispatch_async( dispatch_get_main_queue(), ^{
        [ self finishIfNeeded ];
    });
}

#pragma mark - Discover delegate

-( void )discoveryManager:( DiscoveryManager* )manager didFindDevice:( ConnectableDevice* )device {
    [ self refreshListDevices ];
}

-( void )discoveryManager:( DiscoveryManager* )manager didLoseDevice:( ConnectableDevice* )device {
    [ self refreshListDevices ];
}

-( void )discoveryManager:( DiscoveryManager* )manager didUpdateDevice:( ConnectableDevice* )device {
    [ self refreshListDevices ];
}

-( void )discoveryManager:( DiscoveryManager* )manager didFailWithError:( NSError* )error {
    LTCLog( @"%@", error );
}

@end
