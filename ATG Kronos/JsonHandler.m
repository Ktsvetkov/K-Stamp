//
//  JsonHandler.m
//  K-Stamp
//
//  Created by Kamen Tsvetkov on 7/23/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

#import "JsonHandler.h"

@implementation JsonHandler

+(void) postStampWithCompany: (NSString *) company result: (NSString *) result {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSError *error;
        NSDictionary *tmp = [NSDictionary dictionaryWithObjectsAndKeys:
                         company, @"company",
                         result, @"result",
                         nil];
        NSData *postData = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];

        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://applications-kamtechs.rhcloud.com/recordKStampData.php"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
            NSLog(@"requestReply: %@", requestReply);
        }] resume];
        
    });
    
}

@end
