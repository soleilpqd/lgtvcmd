//
//  LTCPlaylist.h
//  lgtvcmd
//
//  Created by DươngPQ on 02/06/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCTask.h"

@interface LTCPlaylist : LTCTask

@property ( nonatomic, copy ) NSString *mimetype;
@property ( nonatomic, assign ) NSUInteger delay;
@property ( nonatomic, assign ) NSInteger loopCount;
@property ( nonatomic, copy ) NSArray<NSURL*> *urls;

@end
