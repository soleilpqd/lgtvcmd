//
//  LTCToast.m
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCToast.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"
#import "LTCDiscover.h"
@import ConnectSDK_Mac;

@interface LTCToast()

@property ( nonatomic, strong ) NSString *iconData;
@property ( nonatomic, strong ) NSString *iconExt;

@end

@implementation LTCToast

+( void )initialize {
    [ super registTaskClass:[ LTCToast class ] forName:@"Toast" ];
}

-( instancetype )initWithDictionary:( NSDictionary<NSString*,id>* )info workingFolder:( NSString* )path{
    if ( self = [ super initWithDictionary:info workingFolder:path ]) {
        _message = [ info[LTC_TASK_MESG] copy ];
        if ( _message == nil ) return nil;
        _icon = [ info[LTC_TASK_ICON] copy ];
        NSString *url = [ LTCTask handleUrlString:info[LTC_TASK_URL] ];
        if ( url != nil && url.length > 0 ) {
            _url = [ NSURL URLWithString:url ];
        }
        if ( self.icon != nil && self.icon.length > 0 ) {
            _iconExt = [ self.icon pathExtension ];
            _iconData = [[ NSData dataWithContentsOfFile:self.icon ] base64EncodedStringWithOptions:0 ];
        }
    }
    return self;
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC:    @"Show toast.",
              LTC_TASK_MESG:    @"Required. Toast content.",
              LTC_TASK_ICON:    @"Optional. Path to image file to use as toast icon.",
              LTC_TASK_URL:     @"Optional. URL to open when user clicks toast." };
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p> \"%@\"", self.className, self, self.message ];
}

#pragma mark - Performing

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    if ( self.iconData != nil && self.iconExt != nil && self.iconExt.length > 0 ) {
        if ( self.url != nil ) {
            [ connector.device.toastControl showClickableToast:self.message URL:self.url
                                                      iconData:self.iconData iconExtension:self.iconExt
                                                       success:successAction failure:failAction ];
        } else {
            [ connector.device.toastControl showToast:self.message iconData:self.iconData
                                        iconExtension:self.iconExt
                                              success:successAction failure:failAction ];
        }
    } else {
        if ( self.url != nil ) {
            [ connector.device.toastControl showClickableToast:self.message URL:self.url
                                                       success:successAction failure:failAction ];
        } else {
            [ connector.device.toastControl showToast:self.message success:successAction failure:failAction ];
        }
    }
}

@end
