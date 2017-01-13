//
//  AISocketManager.h
//  AISocket
//
//  Created by An Nguyen on 1/12/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AISocketData.h"

#define kAISocketManagerEventStatus @"kEventStatus"
#define kAISocketManagerEventAll    @"kAllEvent"

@import SocketIO;
typedef enum : NSUInteger {
    AISocketManagerNotConnect,
    AISocketManagerConnecting,
    AISocketManagerConnected,
    AISocketManagerDisconnected,
    AISocketManagerReconnecting,
} AISocketManagerStatus;

@class AISocketManager;

typedef AISocketData* (^AISocketManagerDataParseCallback)(id datas);


@protocol AISocketManagerObserver <NSObject>

- (void)dlgAISocketManager:(AISocketManager*)manager withData:(AISocketData*)data;
- (void)dlgAISocketManager:(AISocketManager*)manager status:(AISocketManagerStatus)status;

@end


@interface AISocketManager : NSObject
+ (AISocketManager*)sharedInstance;
+ (NSString*)statusNameFromCode:(AISocketManagerStatus)status;
- (AISocketManagerStatus)status;
- (void)connectHost:(NSString*)host delegate:(id<AISocketManagerObserver>)delegate;
- (void)addObserver:(id<AISocketManagerObserver>)observer onEvent:(NSString*)eventName;
- (void)removeObserver:(id<AISocketManagerObserver>)observer onEvent:(NSString*)eventName;
- (void)emitData:(AISocketData*)data addQueue:(BOOL)isAdd;
- (void)emitData:(AISocketData*)data;
- (void)listenOnEvent:(NSString*)eventName dataCallback:(AISocketManagerDataParseCallback)dataCallback;
- (void)clearQueue;
- (void)disconnect;

@end
