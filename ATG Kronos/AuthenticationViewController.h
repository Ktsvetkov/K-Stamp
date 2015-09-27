//
//  AuthenticationViewController.h
//  ATG Kronos
//
//  Created by Kamen Tsvetkov on 7/8/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

@import GoogleMobileAds;
#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface AuthenticationViewController : UIViewController <UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate,ADBannerViewDelegate,GADBannerViewDelegate>

@property BOOL hasAds;

@end
