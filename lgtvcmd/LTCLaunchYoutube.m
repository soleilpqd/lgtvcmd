//
//  LTCLaunchYoutube.m
//  lgtvcmd
//
//  Created by DươngPQ on 30/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCLaunchYoutube.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"

@implementation LTCLaunchYoutube

+( void )initialize {
    [ super registTaskClass:[ LTCLaunchYoutube class ] forName:@"Youtube" ];
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC: @"Launch Youtube with given clip ID.",
              LTC_TASK_ID:   @"Required. Youtube clip ID to open in Youbute.",
              LTC_TASK_OFFSET: @"Optional. Number of seconds to start playing." };
}

-( instancetype )initWithDictionary:( NSDictionary<NSString*,id>* )info {
    if ( self = [ super initWithDictionary:info ]) {
        _contentId = [ info[LTC_TASK_ID] copy ];
        if ( _contentId == nil ) return nil;
        _startTime = [ info[LTC_TASK_OFFSET] unsignedIntegerValue ];
    }
    return self;
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p> %@", self.className, self, self.contentId ];
}

#pragma mark - Perform

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    [ connector.device.launcher launchYouTube:self.contentId startTime:( float )self.startTime
                                      success:successAction failure:failAction ];
}

@end
