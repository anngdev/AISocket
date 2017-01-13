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
        self.key = [NSString stringWithFormat:@"%ld",(unsigned long)self.hash];
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
+ (BOOL)propertyIsIgnored:(NSString *)propertyName{
    if ([propertyName isEqualToString:@"isSending"]) {
        return true;
    }
    if ([propertyName isEqualToString:@"isNeedACK"]) {
        return true;
    }
    return [super propertyIsIgnored:propertyName];
}
@end
