//
//  WeekOfStamps.m
//  K-Stamp
//
//  Created by Kamen Tsvetkov on 7/25/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

#import "TimeStamp.h"
#import "WeekOfStamps.h"

@implementation WeekOfStamps

-(instancetype)init {
    self = [super init];
    
    if (self) {
        self.TimeStamps = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSString*) getWeek {
    NSString *toReturn = @"-1";
    if ([self.TimeStamps count] > 0) {
        TimeStamp *currentTimeStamp = self.TimeStamps[0];
        toReturn = currentTimeStamp.week;
    }
    return toReturn;
}

-(NSString*) getYear {
    NSString *toReturn = @"-1";
    if ([self.TimeStamps count] > 0) {
        TimeStamp *currentTimeStamp = self.TimeStamps[0];
        toReturn = currentTimeStamp.year;
    }
    return toReturn;
}

-(double) getTimeSince1970 {
    double toReturn = -1;
    if ([self.TimeStamps count] > 0) {
        TimeStamp *currentTimeStamp = self.TimeStamps[0];
        toReturn = currentTimeStamp.timeSince1970;
    }
    return toReturn;
}


@end
