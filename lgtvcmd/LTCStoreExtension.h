//
//  LTCStoreExtension.h
//  lgtvcmd
//
//  Created by DươngPQ on 23/01/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ConnectSDK_Mac;

/*
 Store structure:
 {
    "LTC_STORE":
    [{
        uuid: {
            "description": {<ServiceDescription>}
            "ip": lastKnownIPAddress
            "wifi": lastSeenOnWifi
            "service": [{<DeviceService>}]
        }
    }]
 }

 <DeviceService>
 {
    "class": Class
    "description": {<ServiceDescription>}
    "config": {<ServiceConfig>}
    "capabilitities": [String]
    "pair": Number pairing type
 }

 <ServiceConfig>
 {
    "uuid": UUID
    "last": Number lastDetection
 }

 <ServiceDescription>
 {
    "address": Address
    "uuid": UUID
    "serviceId": String
    "port": UInt
    "type": String
    "version": String
    "friendlyName": String
    "manufacturer":
    "modelName": String
    "modelDescription": String
    "modelNumber": String
    "commandURL": NSURL
    "locationXML": String
    "serviceList": [String]
    "locationResponseHeaders": {String: String}
    "lastDetection": Number
 }
 */

@interface ServiceDescription (Store)

+( nullable instancetype )serviceDescriptionFromDictionary:( nonnull NSDictionary<NSString*, id>* )dictionary;
-( nonnull NSDictionary<NSString*, id>* )toDictionary;

@end

@interface ServiceConfig (Store)

+( nonnull instancetype )serviceConfigWithDescription:( nonnull ServiceDescription* )description
                                        andDictionary:( nonnull NSDictionary<NSString*, id>* )dictionary;
-( nonnull NSDictionary<NSString*, id>* )toDictionary;

@end

@interface DeviceService (Store)

+( nullable instancetype )deviceServiceFromDictionary:( nonnull NSDictionary<NSString*, id>* )dictionary;
-( nonnull NSDictionary<NSString*, id>* )toDictionary;

@end

@interface ConnectableDevice (Store)

+( nullable instancetype )connectableDeviceFromDictionary:( nonnull NSDictionary<NSString*, id>* )dictionary;
-( nonnull NSDictionary<NSString*, id>* )toDictionary;

@end

