//
//  User.h
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/11/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * gameCenterAlias;
@property (nonatomic, retain) NSString * gameCenterId;
@property (nonatomic, retain) NSString * nickname;

@end
