//
//  AISocketManager.m
//  AISocket
//
//  Created by An Nguyen on 1/12/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AISocketManager.h"


@interface AISocketManager()

@property (strong, nonatomic) SocketIOClient *socket;
@property (strong, nonatomic) NSMutableArray<AISocketData*>* senderQueue;
@property (assign, nonatomic) AISocketManagerStatus socketStatus;
@property (strong, nonatomic) NSMapTable *eventObservers;

@end

@implementation AISocketManager
static AISocketManager * _AISocketManagerInstance = nil;

#pragma mark - API

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (AISocketManager*)sharedInstance{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _AISocketManagerInstance = [[AISocketManager alloc]init];
    });
    return _AISocketManagerInstance;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString*)statusNameFromCode:(AISocketManagerStatus)status{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    switch (status) {
        case AISocketManagerNotConnect:
        return @"Not connect";
        case AISocketManagerConnecting:
        return @"Connecting";
        case AISocketManagerConnected:
        return @"Connected";
        case AISocketManagerDisconnected:
        return @"Disconnected";
        case AISocketManagerReconnecting:
        return @"Reconnecting";
        
        default:
        break;
    }
    return @"Undefined";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setSocketStatus:(AISocketManagerStatus)socketStatus{
    NSMutableSet * obrs = [self.eventObservers objectForKey:kAISocketManagerEventStatus];
    if (socketStatus != _socketStatus && socketStatus != AISocketManagerNotConnect) {
        for(id<AISocketManagerObserver> obr in obrs){
            [obr dlgAISocketManager:self status:socketStatus];
        }
    }
    _socketStatus = socketStatus;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (AISocketManagerStatus)status{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    return  self.status;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)connectHost:(NSString*)host delegate:(id<AISocketManagerObserver>)delegate{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    if (self.socket) {
        [self.socket removeAllHandlers];
        [self disconnect];
    }
    [self addObserver:delegate onEvent:kAISocketManagerEventStatus];
    NSAssert(host, @"HOST must not be nil!");
    NSURL* url = [[NSURL alloc] initWithString:host];
    self.socket =  [[SocketIOClient alloc] initWithSocketURL:url config:@{@"log": @NO, @"forceNew":@YES, @"reconnectWait":@1}];
    self.senderQueue  = [NSMutableArray new];
    [self.socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        self.socketStatus = AISocketManagerConnected;
        NSLog(@"socket connected: %@", self.socket);
        if (self.senderQueue.count>0) {
            NSLog(@"resend message");
        }
        for(AISocketData *obj in self.senderQueue){
            [self emitData:obj addQueue:false];
        }
        
    }];
    
    [self.socket on:@"reconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
        NSLog(@"socket disconnected: %@", self.socket);
        self.socketStatus = AISocketManagerReconnecting;
    }];
    self.socketStatus = AISocketManagerConnecting;
    [self.socket connect];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addObserver:(id<AISocketManagerObserver>)observer onEvent:(NSString*)eventName{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    NSMutableSet * obrs = [self.eventObservers objectForKey:eventName];
    if (!obrs) {
        obrs = [NSMutableSet new];
        [self.eventObservers setObject:obrs forKey:eventName];
    }
    [obrs addObject:observer];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)removeObserver:(id<AISocketManagerObserver>)observer onEvent:(NSString*)eventName{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    if ([eventName isEqualToString:kAISocketManagerEventAll]) {
        NSArray* keys =  [[self.eventObservers keyEnumerator] allObjects];
        for(NSString * key in keys){
            if (![key isEqualToString:kAISocketManagerEventAll]) {
                [self removeObserver:observer onEvent:key];
            }
        }
        
    }else{
        NSMutableSet * obrs = [self.eventObservers objectForKey:eventName];
        if (obrs) {
            [obrs removeObject:observer];
        }
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)emitData:(AISocketData*)data addQueue:(BOOL)isAdd{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    if (data.isSending) {
        return;
    }
    if(data.ackTime>=0 && isAdd && ![self.senderQueue containsObject:data]){
        [self.senderQueue addObject:data];
    }
    if (self.socket.status == SocketIOClientStatusConnected) {
        if (data.ackTime>=0) {
            OnAckCallback* callback = [self.socket emitWithAck:[[data class] eventName]  with:@[[data toJSONString]]];
            data.isSending = true;
            [callback timingOutAfter:data.ackTime callback:^(NSArray * datas) {
                if ([datas[0] isEqualToString:@"NO ACK"]) {
                    NSLog(@"Timeout :%@",datas[0]);
                    data.isSending = false;
                    [self notifySocketAckData:data ackData:nil];
                }else{
                    
                    NSLog(@"Received :%@",datas[0]);
                    [self.senderQueue removeObject:data];
                    [self notifySocketAckData:data ackData:datas];
                }
            }];
        }else{
            [self.socket emit:[[data class] eventName]  with:@[[data toJSONString]]];
        }
        
        NSLog(@"%@:%@",[[data class] eventName],[data toJSONString]);
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)emitData:(AISocketData*)data{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    [self emitData:data addQueue:true];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)listenOnEvent:(NSString*)eventName dataCallback:(AISocketManagerDataParseCallback)dataCallback{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    [self.socket off:eventName];
    [self.socket on:eventName callback:^(NSArray * datas, SocketAckEmitter * ack) {
        if (datas && datas.count>0) {
            AISocketData *obj = dataCallback(datas[0]);
            [self notifySocketData:obj];
        }
    }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)clearQueue{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    [self.senderQueue removeAllObjects];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)disconnect{
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    if (self.socket && self.socket.status != SocketIOClientStatusNotConnected ) {
        [self.socket disconnect];
        [self clearQueue];
    }
}

#pragma mark - Private API

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)notifySocketData:(AISocketData*)objs{
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    if (!objs) {
        return;
    }
    
    NSMutableSet * obrs = [self.eventObservers objectForKey:[[objs class] eventName]];
    if (!obrs) {
        return;
    }
    for(id<AISocketManagerObserver> obr in obrs){
        [obr dlgAISocketManager:self withData:objs];
    }
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)notifySocketAckData:(AISocketData*)objs ackData:(NSArray*)ackData{
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    if (!objs) {
        return;
    }
    
    NSMutableSet * obrs = [self.eventObservers objectForKey:[[objs class] eventName]];
    if (!obrs) {
        return;
    }
    for(id<AISocketManagerObserver> obr in obrs){
        [obr dlgAISocketManager:self withData:objs ackData:ackData];
    }
}

- (void)dealloc{
    
}

#pragma mark - Initial

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)init{
    //-------------------------------------------------------------------------------------------------------------------------------------------------
    self = [super init];
    if (self) {
        self.socketStatus = AISocketManagerNotConnect;
        //        self.statusObsevers = [NSMutableSet new];
        self.eventObservers = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                                    valueOptions:NSMapTableStrongMemory];
        [self.eventObservers setObject:[NSMutableSet new] forKey:kAISocketManagerEventStatus];
    }
    return self;
}

@end
