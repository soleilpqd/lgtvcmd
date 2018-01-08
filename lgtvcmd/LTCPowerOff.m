//
//  LTCPowerOff.m
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCPowerOff.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"
@import ConnectSDK_Mac;

@implementation LTCPowerOff

+( void )initialize {
    [ super registTaskClass:[ LTCPowerOff class ] forName:@"Off" ];
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC: @"Power off the Tv." };
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p>", self.className, self ];
}

#pragma mark - Perform

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    [ connector.device.powerControl powerOffWithSuccess:successAction failure:failAction ];
}

@end
