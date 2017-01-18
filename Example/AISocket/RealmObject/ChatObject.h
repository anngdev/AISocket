//
//  ChatObject.h
//  AISocket
//
//  Created by An Nguyen on 1/17/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Realm/Realm.h>
#import "UserObject.h"

@interface ChatObject : RLMObject

@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* message;
@property (strong, nonatomic) NSDate*   date;
@property (strong, nonatomic) NSString* status;
@property (strong, nonatomic) UserObject* user;

@end
RLM_ARRAY_TYPE(ChatObject)
