//
//  LTCTask.h
//  lgtvcmd
//
//  Created by DươngPQ on 25/05/2017.
//  Copyright © 2017 GMO-Z.com RunSystem. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LTCDeviceConnector;

@interface LTCTask : NSObject

+( nonnull NSString* )getIPAddress;
+( nullable NSString* )handleUrlString:( nullable NSString* )urlString;

+( void )registTaskClass:( nonnull Class )taskClass forName:( nonnull NSString* )name;
+( void )registAllTaskClasses;

+( nullable instancetype )taskWithDictionary:( nonnull NSDictionary<NSString*, id>* )info;
+( void )printHelp;

@property ( nonatomic, copy, nonnull ) NSString *name;
@property ( nonatomic, assign ) BOOL isRequirePreviousTaskSuccess;
@property ( nonatomic, copy, nullable ) NSArray<LTCTask*>* nextTasks;
@property ( nonatomic, assign ) NSUInteger duration;

-( BOOL )isPerformWithConnector:( nonnull LTCDeviceConnector* )connector;
-( BOOL )performingResultWithConnector:( nonnull LTCDeviceConnector* )connector;
-( nullable id )performingResponseWithConnector:( nonnull LTCDeviceConnector* )connector;
-( void )taskFinished:( BOOL )result response:( nullable id )response
          onConnector:( nonnull LTCDeviceConnector* )connector;

-( nonnull NSArray<LTCDeviceConnector*>* )validatePerformingConnectors:( nonnull NSArray<LTCDeviceConnector*>* )connectors;
-( void )performNextWithConnectors:( nonnull NSArray<LTCDeviceConnector*>* )connectors;
-( void )performWithConnectors:( nonnull NSArray<LTCDeviceConnector*>* )connectors previousTask:( nullable LTCTask* )preTask;

/// For subclass
-( nullable instancetype )initWithDictionary:( nonnull NSDictionary<NSString*, id>* )info;

-( void )performWithConnector:( nonnull LTCDeviceConnector* )connector
                 previousTask:( nullable LTCTask* )preTask
                    onSuccess:( void (^_Nonnull)( id _Nullable responseObject ))successAction
                    onFailure:( void (^_Nonnull)( NSError* _Nullable error ))failAction;

+( nonnull NSDictionary<NSString*, NSString*>* )parametersDescription;

@end
