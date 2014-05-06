//
//  NSDate+Utils.m
//  GasGuzzler
//
//  Created by Raymond kennedy on 5/5/14.
//  Copyright (c) 2014 Raymond kennedy. All rights reserved.
//

#import "NSDate+Utils.h"

@implementation NSDate (Utils)

/*
 * Returns the number of milliseconds for the given second
 */
- (NSInteger)getMillisecondsForCurrentSecond
{
    // Set the date format to SSS to get the milliseconds for the current date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"SSS"];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    return [[df stringFromDate:self] integerValue];
}

/*
 * Returns the date as a timer string mm.ss.SS
 */
- (NSString *)getTimerString
{
    // Set the date format to SSS to get the milliseconds for the current date
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"mm.ss.SS"];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    return [df stringFromDate:self];
}

@end
