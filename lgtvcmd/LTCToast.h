//
//  LTCToast.h
//  lgtvcmd
//
//  Created by DươngPQ on 29/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCTask.h"

@interface LTCToast : LTCTask

@property ( nonatomic, copy ) NSString *message;
@property ( nonatomic, copy ) NSString *icon;
@property ( nonatomic, copy ) NSURL *url;

@end
