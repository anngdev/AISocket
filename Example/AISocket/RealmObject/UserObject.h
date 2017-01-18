//
//  UserObject.h
//  AISocket
//
//  Created by An Nguyen on 1/17/17.
//  Copyright © 2017 An Nguyen. All rights reserved.
//

#import <Realm/Realm.h>

@interface UserObject : RLMObject
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) NSString* userID;
@end
RLM_ARRAY_TYPE(UserObject)
