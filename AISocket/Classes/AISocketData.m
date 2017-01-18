//
//  AISocketData.m
//  AISocket
//
//  Created by An Nguyen on 1/12/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "AISocketData.h"

@implementation AISocketData
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.key = [AISocketData randomStringWithLength:8];
        self.ackTime = 0;
    }
    return self;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setSenderID:(NSString*)senderID receiverID:(NSString*)receiverID{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    self.senderID = senderID;
    self.receiverID = receiverID;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString*)eventName{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    return @"default";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString*)notificationKey{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    return @"defaultNotificationKey";
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (BOOL)propertyIsIgnored:(NSString *)propertyName{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    if ([propertyName isEqualToString:@"isSending"]) {
        return true;
    }
    if ([propertyName isEqualToString:@"isNeedACK"]) {
        return true;
    }
    return [super propertyIsIgnored:propertyName];
}

static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSString *)randomStringWithLength:(int)len{
//-------------------------------------------------------------------------------------------------------------------------------------------------
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

@end
