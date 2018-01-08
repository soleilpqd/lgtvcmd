//
//  LTCLTCVolume.m
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCVolume.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"
@import ConnectSDK_Mac;

@implementation LTCVolume

+( void )initialize {
    [ super registTaskClass:[ LTCVolume class ] forName:@"Volume" ];
}

-( instancetype )initWithDictionary:( NSDictionary<NSString*,id>* )info {
    if ( self = [ super initWithDictionary:info ]) {
        _volume = [ info[LTC_TASK_VOLUME] unsignedIntegerValue ];
        if ( _volume <= 0 ) {
            _volume = 0;
        } else if ( _volume > 100 ) {
            _volume = 100;
        }
    }
    return self;
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC:    @"Set volume of Tv. Need at least 1 parameter. Default mute.",
              LTC_TASK_VOLUME:  @"Volume. Value from 0 to 100." };
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p> %ld", self.className, self, self.volume ];
}

#pragma mark - Perform

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    if ( self.volume == 0 ) {
        [ connector.device.volumeControl setVolume:0 success:successAction failure:failAction ];
    } else {
        [ connector.device.volumeControl setMute:NO success:nil failure:nil ];
        [ connector.device.volumeControl setVolume:self.volume / 100.0f success:successAction failure:failAction ];
    }
}

@end
