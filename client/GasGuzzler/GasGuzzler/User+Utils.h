//
//  User+Utils.h
//  photoquest
//
//  Created by Raymond Kennedy on 7/14/13.
//  Copyright (c) 2013 Randomay Designs. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "DataManager.h"

@interface User (Utils)

+ (User *)createOrUpdateUser:(PFUser *)currentUser;
+ (User *)getCurrentUser;

@end
