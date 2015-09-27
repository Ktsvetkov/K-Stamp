//
//  ExperimentalCode.m
//  K-Stamp
//
//  Created by Kamen Tsvetkov on 7/23/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

#import <Foundation/Foundation.h>



/* CODE FOR FETCHING DATA FROM SUCCESSFUL STAMP */
/*
 } else if ([self.requestReply containsString:@"Recorded Time"]){
 NSRange outputRange = [self.requestReply rangeOfString:@"Recorded Time"];
 double startIndex = outputRange.location + outputRange.length;
 self.message.text = [@"SUCCESS\n" stringByAppendingString: [self.requestReply substringWithRange: NSMakeRange(startIndex + 47, 7)]];
 self.message.backgroundColor = [UIColor greenColor];
 
 NSLog(@"%@", [self.requestReply substringWithRange: NSMakeRange(startIndex + 47, 7)]);
 
 } else {
 self.message.text = @"UNKNOWN ERROR";
 self.message.backgroundColor = [UIColor grayColor];
 }
 */


/*
 NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
 NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
 NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
 NSCalendar *weekCalender = [NSCalendar currentCalendar];
 
 [timeFormatter setDateFormat:@"hh:mm a"];
 [yearFormatter setDateFormat:@"yyyy"];
 [dayFormatter setDateFormat:@"EEEE"];
 int weekInt = (int)[[weekCalender components: NSCalendarUnitWeekOfYear fromDate:[NSDate date]]weekOfYear];
 
 NSString *timeString = [timeFormatter stringFromDate:[NSDate date]];
 NSString *yearString = [yearFormatter stringFromDate:[NSDate date]];
 NSString *dayString = [dayFormatter stringFromDate:[NSDate date]];
 NSString *weekString = [NSString stringWithFormat:@"%d", weekInt];
 
 if ([[timeString substringToIndex:1] isEqualToString:@"0"]){
 timeString = [timeString substringFromIndex:1];
 }
 */


/*
 Bounds for disabling scroll 
 
 - (void)scrollLeft {
 if (self.currentPage > 0)
 self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x - [UIScreen mainScreen].applicationFrame.size.width, 0);
 }
 
 - (void)scrollRight {
 if (self.currentPage < [self.tableViews count]-1)
 self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x + [UIScreen mainScreen].applicationFrame.size.width, 0);
 }
 
 */

