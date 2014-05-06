//
//  NSDate+Utils.h
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/5/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

// Returns the milliseconds for the current second (number is < 1000)
- (NSInteger)getMillisecondsForCurrentSecond;

// Returns the date in timer form
- (NSString *)getTimerString;

@end
