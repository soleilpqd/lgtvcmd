//
//  LTCStoreExtension.m
//  lgtvcmd
//
//  Created by DươngPQ on 23/01/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCStoreExtension.h"

#define LTC_SERVICE_DESCRIPTION_KEYS @[ @"serviceId", @"port", @"type", @"version", \
@"friendlyName", @"manufacturer", @"modelName", @"modelDescription", @"modelNumber", \
@"locationXML", @"serviceList", @"locationResponseHeaders", @"lastDetection" ]

#define LTC_SERVICE_DESCRIPTION_ADDRESS @"address"
#define LTC_SERVICE_DESCRIPTION_UUID    @"uuid"
#define LTC_SERVICE_DESCRIPTION_CMD_URL @"commandURL"

#define LTC_SERVICE_CONFIG_UUID @"uuid"
#define LTC_SERVICE_CONFIG_LAST_DETECTION @"last"

#define LTC_DEVICE_SERVICE_CLASS @"class"
#define LTC_DEVICE_SERVICE_DESCRIPTION @"description"
#define LTC_DEVICE_SERVICE_CONFIG @"config"
#define LTC_DEVICE_SERVICE_CAPABILITIES @"capabilities"
#define LTC_DEVICE_SERVICE_PAIR @"pair"
#define LTC_DEVICE_SERVICE_PERMISSIONS @"permissions" // WebOS service

#define LTC_DEVICE_DESCRIPTION @"description"
#define LTC_DEVICE_IP @"ip"
#define LTC_DEVICE_WIFI @"wifi"
#define LTC_DEVICE_SERVICES @"services"

@implementation ServiceDescription (Store)

+( instancetype )serviceDescriptionFromDictionary:( NSDictionary<NSString*, id>* )dictionary {
    NSString *addr = [ dictionary objectForKey:LTC_SERVICE_DESCRIPTION_ADDRESS ];
    NSString *uuid = [ dictionary objectForKey:LTC_SERVICE_DESCRIPTION_UUID ];
    if ( addr != nil && uuid != nil ) {
        ServiceDescription *desc = [[ ServiceDescription alloc ] initWithAddress:addr UUID:uuid ];
        NSString *url = [ dictionary objectForKey:LTC_SERVICE_DESCRIPTION_CMD_URL ];
        if ( url != nil ) {
            desc.commandURL = [ NSURL URLWithString:url ];
        }
        NSArray *keys = LTC_SERVICE_DESCRIPTION_KEYS;
        for ( NSString *key in keys ) {
            id value = [ dictionary objectForKey:key ];
            if ( value != nil ) {
                [ desc setValue:value forKey:key ];
            }
        }
        return desc;
    }
    return nil;
}

-( NSDictionary<NSString*, id>* )toDictionary {
    NSMutableDictionary *result = [ NSMutableDictionary new ];
    NSArray *keys = LTC_SERVICE_DESCRIPTION_KEYS;
    for ( NSString *key in keys ) {
        id value = [ self valueForKey:key ];
        if ( value != nil ) {
            [ result setObject:value forKey:key ];
        }
    }
    [ result setObject:self.address forKey:LTC_SERVICE_DESCRIPTION_ADDRESS ];
    [ result setObject:self.UUID forKey:LTC_SERVICE_DESCRIPTION_UUID ];
    if ( self.commandURL != nil ) {
        [ result setObject:[ self.commandURL absoluteString ] forKey:LTC_SERVICE_DESCRIPTION_CMD_URL ];
    }
    return result;
}

@end

@implementation ServiceConfig (Store)

+( instancetype )serviceConfigWithDescription:( ServiceDescription* )description
                                andDictionary:( NSDictionary<NSString*, id>* )dictionary {
    ServiceConfig *cfg = [[ ServiceConfig alloc ] initWithServiceDescription:description ];
    NSString *uuid = [ dictionary objectForKey:LTC_SERVICE_CONFIG_UUID ];
    if ( uuid != nil ) cfg.UUID = uuid;
    NSNumber *last = [ dictionary objectForKey:LTC_SERVICE_CONFIG_LAST_DETECTION ];
    if ( last != nil ) cfg.lastDetection = [ last doubleValue ];
    return cfg;
}

-( NSDictionary<NSString*, id>* )toDictionary {
    NSMutableDictionary *result = [ NSMutableDictionary new ];
    [ result setObject:self.UUID forKey:LTC_SERVICE_CONFIG_UUID ];
    [ result setObject:@( self.lastDetection ) forKey:LTC_SERVICE_CONFIG_LAST_DETECTION ];
    return result;
}

@end

@implementation DeviceService (Store)

+( instancetype )deviceServiceFromDictionary:( NSDictionary<NSString*, id>* )dictionary {
    NSString *cls = [ dictionary objectForKey:LTC_DEVICE_SERVICE_CLASS ];
    NSDictionary *desc = [ dictionary objectForKey:LTC_DEVICE_SERVICE_DESCRIPTION ];
    NSDictionary *cfg = [ dictionary objectForKey:LTC_DEVICE_SERVICE_CONFIG ];
    Class class = nil;
    ServiceDescription *description = nil;
    if ( cls != nil ) class = NSClassFromString( cls );
    if ( desc != nil ) description = [ ServiceDescription serviceDescriptionFromDictionary:desc ];
    if ( class != nil && description != nil ) {
        ServiceConfig *config = [ ServiceConfig serviceConfigWithDescription:description andDictionary:cfg ];
        DeviceService *result = [ DeviceService deviceServiceWithClass:class serviceConfig:config ];
        result.serviceDescription = description;
        NSArray *capabilites = [ dictionary objectForKey:LTC_DEVICE_SERVICE_CAPABILITIES ];
        if ( capabilites != nil ) result.capabilities = capabilites;
        NSNumber *pair = [ dictionary objectForKey:LTC_DEVICE_SERVICE_PAIR ];
        if ( pair != nil ) result.pairingType = [ pair intValue ];
        NSArray *permissions = [ dictionary objectForKey:LTC_DEVICE_SERVICE_PERMISSIONS ];
        if ( permissions != nil && class == [ WebOSTVService class ]) {
            [( WebOSTVService* )result setPermissions:permissions ];
        }
        return result;
    }
    return nil;
}

-( NSDictionary<NSString*, id>* )toDictionary {
    NSMutableDictionary *result = [ NSMutableDictionary new ];
    if ([ self isKindOfClass:[ WebOSTVService class ]]) {
        NSArray *permissions = [( WebOSTVService* )self permissions ];
        if ( permissions != nil && permissions.count > 0 ) {
            [ result setObject:permissions forKey:LTC_DEVICE_SERVICE_PERMISSIONS ];
        }
    }
    [ result setObject:@( self.pairingType ) forKey:LTC_DEVICE_SERVICE_PAIR ];
    if ( self.capabilities != nil && self.capabilities.count > 0 ) {
        [ result setObject:self.capabilities forKey:LTC_DEVICE_SERVICE_CAPABILITIES ];
    }
    if ( self.serviceDescription != nil ) {
        NSDictionary *dic = [ self.serviceDescription toDictionary ];
        [ result setObject:dic forKey:LTC_DEVICE_SERVICE_DESCRIPTION ];
    }
    if ( self.serviceConfig != nil ) {
        NSDictionary *dic = [ self.serviceConfig toDictionary ];
        [ result setObject:dic forKey:LTC_DEVICE_SERVICE_CONFIG ];
    }
    [ result setObject:NSStringFromClass([ self class ]) forKey:LTC_DEVICE_SERVICE_CLASS ];
    return result;
}

@end

@implementation ConnectableDevice (Store)

+( instancetype )connectableDeviceFromDictionary:( NSDictionary<NSString*, id>* )dictionary {
    NSDictionary *desc = [ dictionary objectForKey:LTC_DEVICE_DESCRIPTION ];
    if ( desc != nil ) {
        ServiceDescription *description = [ ServiceDescription serviceDescriptionFromDictionary:desc ];
        if ( description != nil ) {
            ConnectableDevice *result = [ ConnectableDevice connectableDeviceWithDescription:description ];
            NSString *ip = [ dictionary objectForKey:LTC_DEVICE_IP ];
            if ( ip != nil ) result.lastKnownIPAddress = ip;
            NSString *wifi = [ dictionary objectForKey:LTC_DEVICE_WIFI ];
            if ( wifi != nil  ) result.lastSeenOnWifi = wifi;
            NSArray *services = [ dictionary objectForKey:LTC_DEVICE_SERVICES ];
            if ( services != nil ) {
                for ( NSDictionary *dic in services ) {
                    DeviceService *service = [ DeviceService deviceServiceFromDictionary:dic ];
                    if ( service != nil ) {
                        [ result addService:service ];
                    }
                }
            }
            return result;
        }
    }
    return nil;
}

-( NSDictionary<NSString*, id>* )toDictionary {
    NSMutableDictionary *result = [ NSMutableDictionary new ];
    if ( self.services != nil && self.services.count > 0 ) {
        NSMutableArray *sers = [ NSMutableArray new ];
        for ( DeviceService *dev in self.services ) {
            NSDictionary *dic = [ dev toDictionary ];
            [ sers addObject:dic ];
        }
        [ result setObject:sers forKey:LTC_DEVICE_SERVICES ];
    }
    if ( self.lastSeenOnWifi != nil )[ result setObject:self.lastKnownIPAddress forKey:LTC_DEVICE_WIFI ];
    if ( self.lastKnownIPAddress != nil )[ result setObject:self.lastKnownIPAddress forKey:LTC_DEVICE_IP ];
    if ( self.serviceDescription != nil ) {
        NSDictionary *dic = [ self.serviceDescription toDictionary ];
        [ result setObject:dic forKey:LTC_DEVICE_DESCRIPTION ];
    }
    return result;
}

@end
