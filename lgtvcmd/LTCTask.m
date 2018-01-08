//
//  LTCTask.m
//  lgtvcmd
//
//  Created by DươngPQ on 25/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import "LTCTask.h"
#import "LTCConstant.h"
#import "LTCToast.h"
#import "LTCLaunchBrowser.h"
#import "LTCLaunchYoutube.h"
#import "LTCDelay.h"
#import "LTCPowerOff.h"
#import "LTCPlayMedia.h"
#import "LTCVolume.h"
#import "LTCPlaylist.h"
#import "LTCCloseApp.h"
#import "LTCDeviceConnector.h"
#import "LTCDiscover.h"
#import <ifaddrs.h>
#import <netinet/in.h>
#import <arpa/inet.h>
@import ConnectSDK_Mac;

@interface LTCTask()

@property ( nonatomic, strong ) NSMutableArray<NSString*>* performedDevices;
@property ( nonatomic, strong ) NSMutableDictionary<NSString*, NSArray*>* performingResults;

@end

@implementation LTCTask

#pragma mark - Utils

+( NSString* )getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Get NSString from C String
                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+( NSString* )handleUrlString:( NSString* )urlString {
    if ( urlString != nil && [ urlString hasPrefix:@"http://localhost" ]) {
        return [ urlString stringByReplacingOccurrencesOfString:@"http://localhost"
                                                     withString:[ NSString stringWithFormat:@"http://%@", [ self getIPAddress ]]];
    }
    return urlString;
}

+( NSMutableDictionary* )taskClassInfo {
    static NSMutableDictionary *taskClasses;
    if ( taskClasses == nil ) taskClasses = [ NSMutableDictionary new ];
    return taskClasses;
}

+( void )registAllTaskClasses {
    [ LTCToast initialize ];
    [ LTCLaunchBrowser initialize ];
    [ LTCLaunchYoutube initialize ];
    [ LTCDelay initialize ];
    [ LTCPowerOff initialize ];
    [ LTCVolume initialize ];
    [ LTCPlayMedia initialize ];
    [ LTCPlaylist initialize ];
    [ LTCCloseApp initialize ];
}

+( void )printHelp {
    printf( "USAGE: lgtvcmd [-t discover_timeout] <path to JSON file containing tasks information>\n"
           "\tdiscover_timeout: optional. Time to discover devices. Default 5 minutes.\n\n"
           "Each task is represented by a JSON dictionary with pattern:\n" );
    printf( "{\n\t\"name\":\"Task_Name\",\n"
           "\t\"pre_success\":true/false,\n"
           "\t\"next\":[{<JSON next task 1>},{<JSON next task 2>}],\n"
           "\t\"duration\":<number of seconds to delay before do next tasks>,\n"
           "\t\"param1\":\"value 1\",\n"
           "\t\"param2\":\"value 2\",\n"
           "}\n\n" );
    printf( "Key:\n" );
    printf( "\t\"name\": name of task (below).\n" );
    printf( "\t\"pre_success\": Values: true/false. If true, this task stops if the previous task failed.\n" );
    printf( "\t\"next\": list of next tasks.\n" );
    printf( "\t\"duration\": time to delay to perform next tasks.\n" );
    printf( "\tOthers: paramters of this task (below).\n" );
    printf( "\nJSON file can be a single JSON dictionary for single task or an array of JSON dicitonaries for tasks.\n" );
    printf( "\nList of tasks name with their parameters:\n" );
    NSDictionary *classes = [ self taskClassInfo ];
    for ( NSString *name in classes.allKeys ) {
        Class cls = [ classes objectForKey:name ];
        NSDictionary *desc = [ cls parametersDescription ];
        printf( "\"%s\": %s\n", name.UTF8String, [[ desc objectForKey:LTC_TASK_DESC ] UTF8String ]);
        for ( NSString *param in desc.allKeys ) {
            if ( param.length == 0 ) continue;
            NSString *paramDesc = [ desc objectForKey:param ];
            printf( "\t\"%s\": %s\n", param.UTF8String, paramDesc.UTF8String );
        }
    }
}

+( NSDictionary* )parametersDescription {
    [ NSException raise:@"LTCTask" format:@"%@ must override %s", self.className, __FUNCTION__ ];
    return nil;
}

+( void )registTaskClass:( Class )taskClass forName:( NSString* )name {
    if ([ taskClass isSubclassOfClass:[ LTCTask class ]]) {
        NSMutableDictionary *info = [ self taskClassInfo ];
        [ info setObject:taskClass forKey:name ];
    }
}

+( instancetype )taskWithDictionary:( NSDictionary<NSString*, id>* )info {
    if (![ info.allKeys containsObject:LTC_TASK_NAME ]) return nil;
    NSString *name = [ info objectForKey:LTC_TASK_NAME ];
    NSMutableDictionary *taskInfo = [ self taskClassInfo ];
    Class class = [ taskInfo objectForKey:name ];
    if ( class == nil ) return nil;
    LTCTask *task = [[ class alloc ] initWithDictionary:info ];
    return task;
}

-( instancetype )initWithDictionary:( NSDictionary<NSString*, id>* )info {
    if ( self = [ super init ]) {
        _name = [[ info objectForKey:LTC_TASK_NAME ] copy ];
        _isRequirePreviousTaskSuccess = [[ info objectForKey:LTC_TASK_PRE_SUCCESS ] boolValue ];
        _duration = [ info[LTC_TASK_DURATION] unsignedIntegerValue ];
        id object = [ info objectForKey:LTC_TASK_NEXT ];
        if ( object != nil && [ object isKindOfClass:[ NSArray class ]]) {
            NSMutableArray *result = [ NSMutableArray new ];
            for ( id obj in ( NSArray* )object ) {
                if ([ obj isKindOfClass:[ NSDictionary class ]]) {
                    LTCTask *task = [ LTCTask taskWithDictionary:obj ];
                    if ( task != nil ) {
                        [ result addObject:task ];
                    }
                }
            }
            if ( result.count > 0 ) _nextTasks = [ result copy ];
        }
    }
    return self;
}

#pragma mark - Internal functions

-( BOOL )isPerformWithConnector:(LTCDeviceConnector *)connector {
    return [ self.performedDevices containsObject:connector.device.address ];
}

-( BOOL )performingResultWithConnector:( LTCDeviceConnector* )connector {
    if ( self.performingResults != nil ){
        NSArray *array = [ self.performingResults objectForKey:connector.device.address ];
        if ( array != nil && array.count > 0 ) return [[ array objectAtIndex:0 ] boolValue ];
    }
    return NO;
}

-( id )performingResponseWithConnector:( LTCDeviceConnector* )connector {
    if ( self.performingResults != nil ){
        NSArray *array = [ self.performingResults objectForKey:connector.device.address ];
        if ( array != nil && array.count > 1 ) return [ array objectAtIndex:1 ];
    }
    return nil;
}

-( void )taskFinished:( BOOL )result response:( id )response onConnector:( LTCDeviceConnector* )connector {
    LTCLog( @"%@ finishes on %@ with result %d - %@", self.description, connector.device.address, result, response );
    dispatch_async( dispatch_get_main_queue(), ^{
        if ( self.performingResults == nil ) _performingResults = [ NSMutableDictionary new ];
        NSMutableArray *array = [ NSMutableArray new ];
        [ array addObject:@( result )];
        if ( response != nil )[ array addObject:response ];
        [ self.performingResults setObject:array forKey:connector.device.address ];
    });
}

#pragma mark - Perform tasks

-( NSArray<LTCDeviceConnector*>* )validatePerformingConnectors:( NSArray<LTCDeviceConnector*>* )connectors {
    NSMutableArray *result = [ NSMutableArray new ];
    for ( LTCDeviceConnector *connector in connectors ) {
        if (![ self isPerformWithConnector:connector ]) {
            [ result addObject:connector ];
        }
    }
    return result;
}

-( void )performWithConnectors:( NSArray<LTCDeviceConnector*>* )connectors previousTask:( LTCTask* )preTask {
    __weak LTCTask *wSelf = self;
    dispatch_async( dispatch_get_main_queue(), ^{
        NSArray *validatedConnectors = [ self validatePerformingConnectors:connectors ];
        if ( validatedConnectors.count == 0 ) return;
        if ( self.performedDevices == nil ) _performedDevices = [ NSMutableArray new ];
        for ( LTCDeviceConnector *connector in connectors ) {
            if (![ self.performedDevices containsObject:connector.device.address ]) {
                [ self.performedDevices addObject:connector.device.address ];
            }
        }
        
        for ( LTCDeviceConnector *connector in connectors ) {
            SuccessBlock successBlk = ^(id responseObject) {
                [ connector decTaskCount ];
                [ wSelf taskFinished:YES response:responseObject onConnector:connector ];
                [ wSelf performNextWithConnectors:connectors ];
            };
            FailureBlock failBlk = ^(NSError *error) {
                [ connector decTaskCount ];
                [ wSelf taskFinished:NO response:error onConnector:connector ];
                [ wSelf performNextWithConnectors:connectors ];
            };
            dispatch_async( connector.connectionQueue, ^{
                LTCLog( @"Perform %@ on %@", self.description, connector.device.address );
                [ connector incTaskCount ];
                [ wSelf performWithConnector:connector previousTask:preTask
                                   onSuccess:successBlk onFailure:failBlk ];
            });
        }
    });
}

-( void )performNextWithConnectors:( NSArray<LTCDeviceConnector*>* )connectors {
    dispatch_async( dispatch_get_main_queue(), ^{
        if ( self.nextTasks == nil || self.nextTasks.count == 0 ||
            self.performingResults == nil || self.performingResults.count == 0 ) return;
        for ( LTCDeviceConnector *connector in connectors ) {
            NSArray *result = [ self.performingResults objectForKey:connector.device.address ];
            if ( result == nil ) return;
        }
        LTCLog( @"%@ begins perform next tasks %ld", self.description, self.nextTasks.count );
        if ( self.duration > 0 ) {
            for ( LTCDeviceConnector *connector in connectors ) {
                [ connector incTaskCount ];
            }
            [ self performSelector:@selector( performNextAfterDelay: )
                        withObject:@[ connectors, @( YES )]
                        afterDelay:self.duration ];
        } else {
            [ self performNextAfterDelay:@[ connectors, @( NO )]];
        }
    });
}

-( void )performNextAfterDelay:( NSArray* )params {
    NSArray<LTCDeviceConnector*> *connectors = params.firstObject;
    BOOL shouldDecTask = [[ params objectAtIndex:1 ] boolValue ];
    for ( LTCTask *task in self.nextTasks ) {
        if ( task.isRequirePreviousTaskSuccess ) {
            NSMutableArray *devices = [ NSMutableArray new ];
            for ( LTCDeviceConnector *connector in connectors ) {
                if ([ self performingResultWithConnector:connector ]) {
                    [ devices addObject:connector ];
                }
            }
            if ( devices.count > 0 )[ task performWithConnectors:devices previousTask:self ];
        } else {
            [ task performWithConnectors:connectors previousTask:self ];
        }
    }
    if ( shouldDecTask ) {
        for ( LTCDeviceConnector* connector in connectors ) {
            [ connector decTaskCount ];
        }
    }
}

-( void )performWithConnector:( LTCDeviceConnector* )connector previousTask:( LTCTask* )preTask
                    onSuccess:( void (^)(id) )successAction onFailure:( void (^)( NSError* ))failAction {
    
}

@end
