//
//  TimeStamp.h
//  K-Stamp
//
//  Created by Kamen Tsvetkov on 7/24/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeStamp : NSObject {}

@property (copy, nonatomic) NSDate *stampDate;
@property (copy, nonatomic) NSString *year;
@property (copy, nonatomic) NSString *week;
@property (copy, nonatomic) NSString *day;
@property (copy, nonatomic) NSString *time;
@property double timeSince1970;

-(instancetype)initWithTimeSince1970: (NSString*) timeSince1970;

@end
