//
//  main.m
//  lgtvcmd
//
//  Created by DươngPQ on 25/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LTCConstant.h"
#import "LTCDiscover.h"
#import "LTCTask.h"
@import ConnectSDK_Mac;

#import "LTCVolume.h"
#import "LTCPlayMedia.h"
#import "LTCPlayMedia.h"
#import "LTCDelay.h"
#import "LTCLaunchYoutube.h"
#import "LTCCloseApp.h"

#define DISCOVER_TIMEOUT 60 // 1 minute

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        printf( "LG SmartTV Remote Command v%s\nUsing ConnectSDK v1.6.0 from 'www.svlconnectsdk.com'\nPort to MacOSX by DươngPQ\n\n", LTC_TASK_VERSION );
        [ LTCTask registAllTaskClasses ];
        
        if ( argc <= 1 ) {
            [ LTCTask printHelp ];
            return 0;
        }
        
        if ( strcmp( "-h", argv[1] ) == 0 || strcmp( "--help", argv[1] ) == 0 || strcmp( "help", argv[1] ) == 0 ){
            [ LTCTask printHelp ];
            return 0;
        }
        
        if ( strcmp( "-v", argv[1] ) == 0 || strcmp( "--version", argv[1] ) == 0 || strcmp( "version", argv[1] ) == 0 ){
            return 0;
        }
        
        NSString *file = nil;
        NSUInteger timeout = DISCOVER_TIMEOUT;
        
        
        if ( strcmp( "-t", argv[1] ) == 0 ){
            if ( argc < 4 ) {
                printf( "Invalid parameter(s).\n" );
                return 3;
            }
            NSString *inputTimeout = [ NSString stringWithUTF8String:argv[2] ];
            file = [ NSString stringWithUTF8String:argv[3] ];
            NSInteger numTimeout = [ inputTimeout integerValue ];
            if ( numTimeout <= 0 ) {
                printf( "Invalid discover timeout.\n" );
                return 4;
            }
            timeout = numTimeout;
        } else {
            file = [ NSString stringWithUTF8String:argv[1] ];
        }
        
        if ( file == nil ) {
            printf( "Invalid parameter(s).\n" );
            return 3;
        }
        
        if ([ file hasPrefix:@"~/" ])
            file = [ NSString stringWithFormat:@"%@/%@", NSHomeDirectory(), [ file substringFromIndex:2 ]];
        
        NSData *sampleData = [ NSData dataWithContentsOfFile:file ];
        if ( sampleData == nil ) {
            printf( "Fail to read JSON file: %s.\n", file.UTF8String );
            return 5;
        }
        
        NSMutableArray<LTCTask*> *tasks = [ NSMutableArray new ];
        file = [ file stringByDeletingLastPathComponent ];
        
        NSError *error = nil;
        id json = [ NSJSONSerialization JSONObjectWithData:sampleData options:0 error:&error ];
        if ( json != nil ) {
            if ([ json isKindOfClass:[ NSDictionary class ]]) {
                LTCTask *task = [ LTCTask taskWithDictionary:json workingFolder:file ];
                if ( task != nil )[ tasks addObject:task ];
            } else if ([ json isKindOfClass:[ NSArray class ]]) {
                for ( id obj in json ) {
                    if ([ obj isKindOfClass:[ NSDictionary class ]]) {
                        LTCTask *task = [ LTCTask taskWithDictionary:obj workingFolder:file ];
                        if ( task != nil )[ tasks addObject:task ];
                    }
                }
            }
        } else {
            printf( "Parsing JSON Failed:\n%s.\n", error.description.UTF8String );
            return 1;
        }
        
        if ( tasks.count == 0 ) {
            printf( "No task to do.\n" );
            return 2;
        }

        GCDWebServerLogLevel = kGCDWebServerLoggingLevel_Warning;
        LTCDiscover *discover = [ LTCDiscover shared ];
        discover.tasks = tasks;
        discover.numberOfSynchDevices = 2;
        [ discover start:timeout ];
        
        while ( !discover.isStoppable ) {
            [[ NSRunLoop currentRunLoop ] runUntilDate:[ NSDate dateWithTimeIntervalSinceNow:1 ]];
        }
    }
    return 0;
}
