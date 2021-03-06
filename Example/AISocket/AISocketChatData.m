//
//  AISocketChatData.m
//  Playground
//
//  Created by An Nguyen on 1/12/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AISocketChatData.h"

@implementation AISocketChatData
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)init{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    self = [super init];
    if (self) {
        self.ackTime = 0;
    }
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setMessage:(NSString *)message senderName:(NSString*)senderName{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    self.message = message;
    self.senderName = senderName;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)eventName{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    return @"chatmessage";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)notificationKey{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    return @"AISocketChatDataNotificationKey";
}
@end
