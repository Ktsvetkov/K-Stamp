//
//  StampsViewController.h
//  ATG Kronos
//
//  Created by Kamen Tsvetkov on 7/10/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

@import GoogleMobileAds;
#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface StampsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, GADInterstitialDelegate,UIAlertViewDelegate, ADInterstitialAdDelegate>

@property BOOL hasAds;
@property BOOL hasScrollAds;

@end
