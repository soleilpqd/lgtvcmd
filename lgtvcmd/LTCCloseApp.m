//
//  LTCToast.m
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCCloseApp.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"
#import "LTCDiscover.h"
@import ConnectSDK_Mac;

@implementation LTCCloseApp

+( void )initialize {
    [ super registTaskClass:[ LTCCloseApp class ] forName:@"Close" ];
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC:@"Close previous launched app." };
}

-( NSString* )description {
    return  [ NSString stringWithFormat:@"%@<%p>", self.className, self ];
}

#pragma mark - Perform

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    id preResponse = [ preTask performingResponseWithConnector:connector ];
    BOOL found = NO;
    if ( preResponse != nil ) {
        if ([ preResponse isKindOfClass:[ LaunchSession class ]]) {
            found = YES;
            LTCLog( @"Closing \"%@\"\n", [( LaunchSession* )preResponse name ]);
            [ connector.device.launcher closeApp:preResponse success:successAction failure:failAction ];
        } else if ([ preResponse isKindOfClass:[ MediaLaunchObject class ]]) {
            found = YES;
            LTCLog( @"Closing \"%s\"\n", [[( MediaLaunchObject* )preResponse session ] name ]);
            [ connector.device.mediaPlayer closeMedia:[( MediaLaunchObject* )preResponse session ] success:successAction failure:failAction ];
        }
    }
    if ( !found ){
        failAction( nil );
    }
}

@end
