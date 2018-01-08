//
//  LTCPlayMedia.h
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCTask.h"

@class ImageInfo;
@interface LTCPlayMedia : LTCTask

@property ( nonatomic, copy ) NSString *mimetype;
@property ( nonatomic, copy ) NSString *title;
@property ( nonatomic, copy ) NSURL *url;
@property ( nonatomic, assign ) BOOL isLoop;
@property ( nonatomic, copy ) NSArray<ImageInfo*> *additionImages;

@end
