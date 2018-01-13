//
//  LTCPlaylist.m
//  lgtvcmd
//
//  Created by DươngPQ on 02/06/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCPlaylist.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"
#import "LTCDiscover.h"
@import ConnectSDK_Mac;

@interface LTCPlaylist()

@property ( nonatomic, strong ) NSMutableDictionary *loopIndices;
@property ( nonatomic, strong ) NSMutableDictionary *mediaIndices;
@property ( nonatomic, strong ) NSMutableDictionary *responseObjects;
@property ( nonatomic ) void (^nextBlock)( id response );

@end

@implementation LTCPlaylist

+( void )initialize {
    [ super registTaskClass:[ LTCPlaylist class ] forName:@"Playlist" ];
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC: @"Play a list of media url with same Mime type.",
              LTC_TASK_MIME: @"Required. Mime type of media to play.",
              LTC_TASK_TIME: @"Required. Time (seconds) delay between media.",
              LTC_TASK_URL:  @"Required. Array of media urls to play.",
              LTC_TASK_LOOP: @"Optional. Number of time to loop playing media. -1 to loop forever (not-recommended)." };
}

-( instancetype )initWithDictionary:( NSDictionary<NSString*,id>* )info workingFolder:( NSString* )path {
    if ( self = [ super initWithDictionary:info workingFolder:path ]) {
        _mimetype = info[LTC_TASK_MIME];
        _delay = [ info[LTC_TASK_TIME] unsignedIntegerValue ];
        _loopCount = [ info[LTC_TASK_LOOP] integerValue ];
        if ( _loopCount == 0 ) _loopCount = 1;
        NSMutableArray *urls = [ NSMutableArray new ];
        NSArray *array = info[LTC_TASK_URL];
        if ( array != nil && [ array isKindOfClass:[ NSArray class ]]) {
            for ( NSString *s in array ) {
                NSURL *url = [ NSURL URLWithString:[ LTCTask handleUrlString:s ]];
                if ( url != nil )[ urls addObject:url ];
            }
        }
        if ( urls.count > 0 ) _urls = [ urls copy ];
        if ( _mimetype == nil || _delay <= 0 || _urls == nil ) return nil;
        _loopIndices = [ NSMutableDictionary new ];
        _mediaIndices = [ NSMutableDictionary new ];
        _responseObjects = [ NSMutableDictionary new ];
    }
    return self;
}

-( NSString* )description {
    return [ NSString stringWithFormat:@"%@<%p> %@ delay=%ld loop=%ld\n%@", self.className, self, self.mimetype, self.delay, self.loopCount, self.urls.description ];
}

#pragma mark - Storage

-( NSUInteger )loopIndexForConnector:( LTCDeviceConnector* )connector {
    return [[ self.loopIndices objectForKey:connector.device.address ] unsignedIntegerValue ];
}

-( void )setLoopIndex:( NSUInteger )index forConnector:( LTCDeviceConnector* )connector {
    [ self.loopIndices setObject:@( index ) forKey:connector.device.address ];
}

-( NSUInteger )mediaIndexForConnector:( LTCDeviceConnector* )connector {
    return [[ self.mediaIndices objectForKey:connector.device.address ] unsignedIntegerValue ];
}

-( void )setMediaIndex:( NSUInteger )index forConnector:( LTCDeviceConnector* )connector {
    [ self.mediaIndices setObject:@( index ) forKey:connector.device.address ];
}

-( id )responseObjectOfConnector:( LTCDeviceConnector* )connector {
    return [ self.responseObjects objectForKey:connector.device.address ];
}

-( void )setResponseObject:( id )response forConnector:( LTCDeviceConnector* )connector {
    if ( response != nil )[ self.responseObjects setObject:response forKey:connector.device.address ];
}

#pragma mark - Perform

-( void )playWithConnector:( LTCDeviceConnector* )connector {
    NSUInteger mediaIndex = [ self mediaIndexForConnector:connector ];
    NSURL *url = [ self.urls objectAtIndex:mediaIndex ];
    LTCLog( @"Play %@ %@ on %@", self.mimetype, url, connector.device.address );
    
    MediaInfo *medInfo = [[ MediaInfo alloc ] initWithURL:url mimeType:self.mimetype ];
    
    __weak LTCPlaylist *wSelf = self;
    
    if ([ self.mimetype hasPrefix:@"image/" ]) {
        [ connector.device.mediaPlayer displayImageWithMediaInfo:medInfo success:^(MediaLaunchObject *mediaLaunchObject) {
            [ wSelf setResponseObject:mediaLaunchObject forConnector:connector ];
        } failure:nil ];
    } else {
        [ connector.device.mediaPlayer playMediaWithMediaInfo:medInfo shouldLoop:false success:^(MediaLaunchObject *mediaLaunchObject) {
            [ wSelf setResponseObject:mediaLaunchObject forConnector:connector ];
        } failure:nil ];
    }
    
    mediaIndex += 1;
    [ self setMediaIndex:mediaIndex forConnector:connector ];
    
    [ self playNextWithConnector:connector ];
}

-( void )playNextWithConnector:( LTCDeviceConnector* )connector {
    NSUInteger mediaIndex = [ self mediaIndexForConnector:connector ];
    NSUInteger loopIndex = [ self loopIndexForConnector:connector ];
    
    if ( mediaIndex == self.urls.count ) {
        mediaIndex = 0;
        [ self setMediaIndex:0 forConnector:connector ];
        loopIndex += 1;
        [ self setLoopIndex:loopIndex forConnector:connector ];
        
        if ( self.loopCount >= 0 && loopIndex >= self.loopCount ) {
            self.nextBlock([ self responseObjectOfConnector:connector ]);
            return;
        }
    }
    __weak LTCPlaylist *wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), connector.connectionQueue, ^{
        [ wSelf playWithConnector:connector ];
    });
}

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    self.nextBlock = successAction;
    [ self setLoopIndex:0 forConnector:connector ];
    [ self setMediaIndex:0 forConnector:connector ];
    [ self playWithConnector:connector ];
}

@end
