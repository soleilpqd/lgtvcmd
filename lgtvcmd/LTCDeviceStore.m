//
//  LTCDeviceStore.m
//  lgtvcmd
//
//  Created by DươngPQ on 22/01/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCDeviceStore.h"
#import "LTCStoreExtension.h"

/*
 Defaults Data: @{Device_UDID: @{"udid": UDID, "address": address, @"services": @[@{@"class": Class, "udid": UDID, "address": address,@"pair": Number, }]}}
 */

#define LTC_STORE_DEFAULTS  @"LTC_STORE"

@interface LTCDeviceStore()

@property ( nonatomic, strong ) NSMutableDictionary<NSString*, ConnectableDevice*> *allDevices;

@end

@implementation LTCDeviceStore

-( NSDictionary* )storedDevices {
    return [ self.allDevices copy ];
}

-( instancetype )init {
    if ( self = [ super init ]) {
//        [[ NSUserDefaults standardUserDefaults ] removeObjectForKey:LTC_STORE_DEFAULTS ];
        _allDevices = [ NSMutableDictionary new ];
        NSDictionary *savedDic = [[ NSUserDefaults standardUserDefaults ] objectForKey:LTC_STORE_DEFAULTS ];
        if ( savedDic != nil && savedDic.count > 0 ) {
            for ( NSString *key in savedDic ) {
                ConnectableDevice *device = [ ConnectableDevice connectableDeviceFromDictionary:savedDic ];
                if ( device != nil )[ _allDevices setObject:device forKey:key ];
            }
        }
    }
    return self;
}

-( void )saveDevices {
    if ( self.allDevices.count == 0 ) {
        [[ NSUserDefaults standardUserDefaults ] removeObjectForKey:LTC_STORE_DEFAULTS ];
        return;
    }
    NSMutableDictionary *result = [ NSMutableDictionary new ];
    for ( NSString *key in self.allDevices ) {
        ConnectableDevice *device = [ self.allDevices objectForKey:key ];
        NSDictionary *dic = [ device toDictionary ];
        [ result setObject:dic forKey:key ];
    }
    [[ NSUserDefaults standardUserDefaults ] setObject:result forKey:LTC_STORE_DEFAULTS ];
}

-( void )addDevice:( ConnectableDevice* )device {
    [ self.allDevices setObject:device forKey:device.serviceDescription.UUID ];
    [ self saveDevices ];
}

-( void )updateDevice:( ConnectableDevice* )device {
    [ self.allDevices setObject:device forKey:device.serviceDescription.UUID ];
    [ self saveDevices ];
}

-( void )removeDevice:( ConnectableDevice* )device {
    [ self.allDevices removeObjectForKey:device.serviceDescription.UUID ];
    [ self saveDevices ];
}

-( ConnectableDevice* )deviceForId:( NSString* )identifier {
    return [ self.allDevices objectForKey:identifier ];
}

-( ServiceConfig* )serviceConfigForUUID:( NSString* )UUID {
    for ( ConnectableDevice *device in self.allDevices.allValues ) {
        for ( DeviceService *devSer in device.services ) {
            if ([ devSer.serviceConfig.UUID isEqualToString:UUID ]) {
                return devSer.serviceConfig;
            }
        }
    }
    return nil;
}

-( void )removeAll {
    [ self.allDevices removeAllObjects ];
    [ self saveDevices ];
}

@end
