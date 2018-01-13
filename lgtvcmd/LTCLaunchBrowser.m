//
//  LTCLaunchBrowser.m
//  lgtvcmd
//
//  Created by DươngPQ on 30/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCLaunchBrowser.h"
#import "LTCDeviceConnector.h"
#import "LTCConstant.h"

@implementation LTCLaunchBrowser

+( void )initialize {
    [ super registTaskClass:[ LTCLaunchBrowser class ] forName:@"Browser" ];
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC: @"Launch Web Browser with given URL.",
              LTC_TASK_URL:  @"Required. Url to open on web browser." };
}

-( instancetype )initWithDictionary:( NSDictionary<NSString*,id>* )info workingFolder:( NSString* )path {
    if ( self = [ super initWithDictionary:info workingFolder:path ]) {
        _url = [ NSURL URLWithString:[ LTCTask handleUrlString:info[LTC_TASK_URL] ]];
        if ( _url == nil ) return nil;
    }
    return self;
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p> %@", self.className, self, self.url ];
}

#pragma mark - Perform

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    [ connector.device.launcher launchBrowser:self.url success:successAction failure:failAction ];
}

@end
