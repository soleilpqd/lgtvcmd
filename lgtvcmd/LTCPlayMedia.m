//
//  LTCPlayMedia.m
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCPlayMedia.h"
#import "LTCConstant.h"
#import "LTCDeviceConnector.h"
@import ConnectSDK_Mac;

@implementation ImageInfo (LGTvCmd)

+( nullable instancetype )imageInfoWithDictonary:( NSDictionary* )info {
    NSURL *url = [ NSURL URLWithString:[ LTCTask handleUrlString:info[LTC_TASK_URL]]];
    NSString *type = info[LTC_TASK_TYPE];
    ImageType imgType = ImageTypeUnknown;
    if ([ type isEqualToString:LTC_TASK_TYPE_THUMB]) {
        imgType = ImageTypeThumb;
    } else if ([ type isEqualToString:LTC_TASK_TYPE_POSTER ]) {
        imgType = ImageTypeVideoPoster;
    } else if ([ type isEqualToString:LTC_TASK_TYPE_ART ]) {
        imgType = ImageTypeAlbumArt;
    }
    if ( url != nil && imgType != ImageTypeUnknown ) {
        return [[ ImageInfo alloc ] initWithURL:url type:imgType ];
    }
    return nil;
}

-( nullable NSString* )typeName {
    switch ( self.type ) {
        case ImageTypeAlbumArt:
            return LTC_TASK_TYPE_ART;
            break;
        case ImageTypeThumb:
            return LTC_TASK_TYPE_THUMB;
            break;
        case ImageTypeVideoPoster:
            return LTC_TASK_TYPE_POSTER;
            break;
        default:
            break;
    }
    return nil;
}

@end

@implementation LTCPlayMedia

+( void )initialize {
    [ super registTaskClass:[ LTCPlayMedia class ] forName:@"Media" ];
}

-( instancetype )initWithDictionary:( NSDictionary<NSString*,id>* )info workingFolder:( NSString* )path {
    if ( self = [ super initWithDictionary:info workingFolder:path ]) {
        NSString *url = [ LTCTask handleUrlString:info[LTC_TASK_URL] ];
        if ( url != nil && url.length > 0 ) {
            _url = [ NSURL URLWithString:url ];
        }
        _mimetype = info[LTC_TASK_MIME];
        if ( _url == nil || _mimetype == nil ) return nil;
        _title = info[LTC_TASK_TITLE];
        _isLoop = [ info[LTC_TASK_LOOP] boolValue ];
        NSArray *meta = info[LTC_TASK_META];
        if ( meta != nil && [ meta isKindOfClass:[ NSArray class ]] && [ meta count ] > 0 ) {
            NSMutableArray *imageInfo = [ NSMutableArray new ];
            for ( NSDictionary *dic in meta ) {
                ImageInfo *info = [ ImageInfo imageInfoWithDictonary:dic ];
                if ( info != nil )[ imageInfo addObject:info ];
            }
            if ( imageInfo.count > 0 ) _additionImages = imageInfo;
        }
    }
    return self;
}

+( NSDictionary* )parametersDescription {
    return @{ LTC_TASK_DESC:    @"Play media from given URL.",
              LTC_TASK_URL:     @"Required. URL of media to play.",
              LTC_TASK_MIME:    @"Required. Mime-type of media.",
              LTC_TASK_TITLE:   @"Optional. Title of media.",
              LTC_TASK_LOOP:    @"Optional. Looping playing media or not.",
              LTC_TASK_META:    [ NSString stringWithFormat:@"Optional. Meta image file to play with media (eg. Album Art, video poster ...). "
                                 "Value must be array of JSON dictonary with keys:\n\t\t[{\n\t\t\t\"%@\": Required. URL of image file.\n\t\t\t\"%@\": Required. Role of image file. "
                                 "Available values:\n\t\t\t\t\"%@\": icon displayed on player.\n\t\t\t\t\"%@\": video poster.\n\t\t\t\t\"%@\": Album Art when play sound.\n\t\t}]",
                                 LTC_TASK_URL, LTC_TASK_TYPE, LTC_TASK_TYPE_THUMB, LTC_TASK_TYPE_POSTER, LTC_TASK_TYPE_ART ]};
}

-( NSString* )description {
    NSMutableString *result = [ NSMutableString stringWithFormat:@"%@<%p> %@ %@", self.className, self, self.mimetype, self.url ];
    if ( self.title != nil )[ result appendFormat:@" title=\"%@\"", self.title ];
    if ( self.isLoop ) [ result appendString:@" looping" ];
    if ( self.additionImages != nil ) {
        [ result appendString:@"\n\tAdditional images:\n" ];
        for ( ImageInfo *imgInfo in self.additionImages ) {
            [ result appendFormat:@"\t\t%@ \"%@\"\n", [ imgInfo typeName ], imgInfo.url ];
        }
    }
    return result;
}

#pragma mark - Perform

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)( id ))successAction onFailure:( void (^)( NSError* ))failAction {
    MediaInfo *medInfo = [[ MediaInfo alloc ] initWithURL:self.url mimeType:self.mimetype ];
    medInfo.title = self.title;
    medInfo.images = [ self.additionImages copy ];
    
    if ([ self.mimetype hasPrefix:@"image/" ]) {
        [ connector.device.mediaPlayer displayImageWithMediaInfo:medInfo success:successAction failure:failAction ];
    } else {
        [ connector.device.mediaPlayer playMediaWithMediaInfo:medInfo shouldLoop:self.isLoop success:successAction failure:failAction ];
    }
}

@end
