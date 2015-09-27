//
//  TimeStamp.m
//  K-Stamp
//
//  Created by Kamen Tsvetkov on 7/24/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

#import "TimeStamp.h"

@implementation TimeStamp

-(instancetype)init {
    self = [super init];
    
    if (self) {
        NSTimeInterval timeSince1970Interval = [[NSDate date] timeIntervalSince1970];
        self.stampDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeSince1970Interval];
        self.timeSince1970 = timeSince1970Interval;
        
        NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *calender = [NSCalendar currentCalendar];
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        
        [yearFormatter setDateFormat:@"yyyy"];
        NSDateComponents *dateComponents = [calender components: NSCalendarUnitWeekOfYear fromDate: self.stampDate];
        [timeFormatter setDateFormat:@"hh:mm a"];
        [dayFormatter setDateFormat:@"EEEE"];
        
        self.year = [yearFormatter stringFromDate:[NSDate date]];
        self.week = [NSString stringWithFormat:@"%d", (int)[dateComponents weekOfYear]];
        self.day = [dayFormatter stringFromDate:[NSDate date]];
        self.time = [timeFormatter stringFromDate:[NSDate date]];
        
        if ([[self.time substringToIndex:1] isEqualToString:@"0"]){
            self.time = [self.time substringFromIndex:1];
        }
    }
    return self;
}

-(instancetype)initWithTimeSince1970: (NSString*) timeSince1970 {
    self = [super init];
    
    if (self) {
        NSTimeInterval timeSince1970Interval = [timeSince1970 doubleValue];
        self.stampDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeSince1970Interval];
        self.timeSince1970 = timeSince1970Interval;
        
        NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
        NSCalendar *calender = [NSCalendar currentCalendar];
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        
        [yearFormatter setDateFormat:@"yyyy"];
        NSDateComponents *dateComponents = [calender components: NSCalendarUnitWeekOfYear fromDate: self.stampDate];
        [timeFormatter setDateFormat:@"hh:mm a"];
        [dayFormatter setDateFormat:@"EEEE"];
        
        self.year = [yearFormatter stringFromDate:self.stampDate];
        self.week = [NSString stringWithFormat:@"%d", (int)[dateComponents weekOfYear]];
        self.day = [dayFormatter stringFromDate:self.stampDate];
        self.time = [timeFormatter stringFromDate:self.stampDate];
        
        if ([[self.time substringToIndex:1] isEqualToString:@"0"]){
            self.time = [self.time substringFromIndex:1];
        }
    }
    return self;
}

@end
