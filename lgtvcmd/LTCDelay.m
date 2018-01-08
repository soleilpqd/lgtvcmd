//
//  LTCDelay.m
//  lgtvcmd
//
//  Created by DươngPQ on 30/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCDelay.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"

@implementation LTCDelay

+( void )initialize {
    [ super registTaskClass:[ LTCDelay class ] forName:@"Delay" ];
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC: @"Just do nothing, use to delay. Ignore pre_success (pass it to next tasks). "
              "Unlike \"duration\" of other tasks which delays from received response from TV, this task delays from its starting." };
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p> %ld", self.className, self, self.duration ];
}

#pragma mark - Perform

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    id response = [ preTask performingResponseWithConnector:connector ];
    if ([ preTask performingResultWithConnector:connector ]) {
        successAction( response );
    } else {
        failAction([ response isKindOfClass:[ NSError class ]] ? response : nil );
    }
}

@end
