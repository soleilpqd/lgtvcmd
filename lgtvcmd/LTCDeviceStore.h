//
//  LTCDeviceStore.h
//  lgtvcmd
//
//  Created by DươngPQ on 22/01/2018.
//  Copyright © 2018 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
@import ConnectSDK_Mac;

@interface LTCDeviceStore : NSObject <ConnectableDeviceStore>

@property ( nonatomic, readonly ) NSDictionary *storedDevices;

@end
