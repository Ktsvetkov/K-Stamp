//
//  WeekOfStamps.h
//  K-Stamp
//
//  Created by Kamen Tsvetkov on 7/25/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeekOfStamps : NSObject {}

@property (nonatomic) NSMutableArray *TimeStamps;

-(NSString*) getWeek;
-(NSString*) getYear;
-(double) getTimeSince1970;

@end
