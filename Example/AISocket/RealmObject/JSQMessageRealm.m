//
//  JSQMessageRealm.m
//  AISocket
//
//  Created by An Nguyen on 1/17/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import "JSQMessageRealm.h"
#import "AISocketChatDatasources.h"

@implementation JSQMessage (RealmChatObject)

+ (JSQMessage*)createFromChatObject:(ChatObject*)obj{
    JSQMessage* msg = [[JSQMessage alloc]initWithSenderId:obj.user.userID senderDisplayName:obj.user.userName date:obj.date text:obj.message];
    msg.status = obj.status;
    msg.msgKey = obj.key;
    
    return msg;
}
- (void)writeRealm{
    RLMRealm *realm = [RLMRealm defaultRealm];
    UserObject *user    = [[UserObject objectsWhere:@"userID = %@",self.senderId] firstObject];
    if (user == nil) {
        user = [[UserObject alloc]init];
        user.userName   = self.senderDisplayName;
        user.userID     = self.senderId;
        [realm beginWriteTransaction];
        [realm addOrUpdateObject:user];
        [realm commitWriteTransaction];
    }
    ChatObject* obj     = [[ChatObject alloc]init];//addOrUpdateObject not use query
    obj.message         = self.text;
    obj.date            = self.date;
    obj.key             = self.msgKey;
    obj.user = user;
    [realm beginWriteTransaction];
    [realm addOrUpdateObject:obj];
    [realm commitWriteTransaction];
}

- (void)deleteRealm{
    RLMRealm *realm = [RLMRealm defaultRealm];
    ChatObject *obj    = [[ChatObject objectsWhere:@"key = %@",self.msgKey] firstObject];
    if (obj) {
        [realm beginWriteTransaction];
        [realm deleteObject:obj];
        [realm commitWriteTransaction];
    }
    
}
@end
