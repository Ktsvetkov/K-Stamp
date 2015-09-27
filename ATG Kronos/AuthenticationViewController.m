//
//  AuthenticationViewController.m
//  ATG Kronos
//
//  Created by Kamen Tsvetkov on 7/8/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

@import GoogleMobileAds;
#import "JsonHandler.h"
#import "TimeStamp.h"
#import "StampsViewController.h"
#import "AuthenticationViewController.h"

@interface AuthenticationViewController ()

/* UI Elements */
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *submit;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *stampLogsButton;
@property (weak, nonatomic) IBOutlet UITextField *pickerTextField;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) ADBannerView *adBanner;
@property (nonatomic, strong) GADBannerView *admobBannerView;
@property BOOL bannerIsVisible;


/* Constraints */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceToTopForm;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formSpacing1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formSpacing2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *formHeight;


/* File Paths */
@property (strong, nonatomic) NSString *filePathUsername;
@property (strong, nonatomic) NSString *filePathPassword;
@property (strong, nonatomic) NSString *filePathLog;
@property (strong, nonatomic) NSString *filePathLogBackup;
@property (strong, nonatomic) NSString *filePathPicker;
@property (strong, nonatomic) NSString *filePathDisclaimer;
@property (strong, nonatomic) NSString *filePathCompanyPickerInfo;


/* Stamp Request Variables */
@property (strong, nonatomic) NSString *companyURL;
@property (strong, nonatomic) NSString *suffixURL;
@property (strong, nonatomic) NSString *runningClock;
@property (strong, nonatomic) NSString *requestReply;
@property (strong, nonatomic) NSString *stampLog;
@property (strong, nonatomic) NSArray *companyNames;
@property (strong, nonatomic) NSArray *companyURLs;
@property (strong, nonatomic) NSData *companyListData;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setFilePaths]; /* dependency */
    [self setPostValues];
    [self setUpAppUI];
    [self setButtonMethods];
    [self displayDisclaimer];
    //[self saveLogData];
    //[self restoreLogData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setUpCompanyPicker];
    [self fetchCompanyInfo];
    [self displayIAdBanner];
}

-(void) setFilePaths {
    NSString *baseFilePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    self.filePathUsername = [baseFilePath stringByAppendingPathComponent:@"/username.txt"];
    self.filePathPassword = [baseFilePath stringByAppendingPathComponent:@"/password.txt"];
    self.filePathPicker = [baseFilePath stringByAppendingPathComponent:@"/picker.txt"];
    self.filePathLog = [baseFilePath stringByAppendingPathComponent:@"/log.txt"];
    self.filePathLogBackup = [baseFilePath stringByAppendingPathComponent:@"/logbackup.txt"];
    self.filePathDisclaimer = [baseFilePath stringByAppendingPathComponent:@"/disclaimer.txt"];
    self.filePathCompanyPickerInfo = [baseFilePath stringByAppendingString:@"/companyPickerInfo.txt"];
}

-(void) setPostValues {
    self.suffixURL = @"/wfc/applications/wtk/html/ess/quick-ts-record.jsp";
    self.companyURL = @"";
    self.runningClock = @"";
    self.requestReply = @"-1";
}

-(void) setUpAppUI {
    NSError *error;
    
    /* Status Message */
    self.message.hidden = YES;
    self.message.layer.cornerRadius = 8;
    self.message.layer.masksToBounds = YES;
    self.message.backgroundColor = [UIColor whiteColor];
    self.message.layer.borderWidth = 1.0;
    self.message.layer.borderColor = [[UIColor blackColor] CGColor];
    
    /* Loading Indicator */
    self.loadingIndicator.hidesWhenStopped = YES;
    
    /* Username */
    self.username.delegate = self;
    [self.username setReturnKeyType:UIReturnKeyDone];
    self.username.text = [NSString stringWithContentsOfFile:self.filePathUsername
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    /* Password */
    self.password.delegate = self;
    self.password.secureTextEntry = YES;
    [self.password setReturnKeyType:UIReturnKeyDone];
    self.password.text = [NSString stringWithContentsOfFile:self.filePathPassword
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    
    /* Submit button */
    self.submit.layer.cornerRadius = 25;
    self.submit.layer.masksToBounds = NO;
    self.submit.layer.shadowColor = [UIColor orangeColor].CGColor;
    self.submit.layer.shadowOpacity = 1;
    self.submit.layer.shadowRadius = 12;
    self.submit.layer.shadowOffset = CGSizeMake(0, 0);
    self.submit.layer.borderWidth = 1.0;
    self.submit.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self setLayoutConstraints];
}

-(void) setLayoutConstraints {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            /* Do iPhone 5 stuff here. */
        } else {
            /* Legacy iPhone */
            self.spaceToTopForm.constant = 120;
            self.formSpacing1.constant = 10;
            self.formSpacing2.constant = 10;
            self.formHeight.constant = 180;
        }
    } else {
        /* Do iPad stuff here. */
    }
}

-(void) setButtonMethods {
    [self.submit addTarget:self action:@selector(submitForm) forControlEvents:UIControlEventTouchUpInside];
    [self.stampLogsButton addTarget:self action:@selector(goToLogs) forControlEvents:UIControlEventTouchUpInside];
}

-(void) fetchCompanyInfo {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURL *membersURL = [NSURL URLWithString:
        @"https://docs.google.com/spreadsheets/d/1FCLEfY9LEV9bUNUUaDeQJODBPnXXoSoNJwZe6Hc5lWk/export?format=csv&id=1vCxruEpLacVnikpK4gFpIpqoVFVFQ9KWCCJyqAlbyQc&gid=0"];
        
        self.companyListData = [NSData dataWithContentsOfURL:membersURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;

            NSData *companyData = self.companyListData;
            NSString *fileContentsOld = [NSString stringWithContentsOfFile:self.filePathCompanyPickerInfo
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
            if (companyData != nil) {
                NSString *fileContents = [[NSString alloc] initWithData:companyData encoding:NSASCIIStringEncoding];
                if (![fileContents isEqualToString:fileContentsOld]) {
                    [fileContents writeToFile:self.filePathCompanyPickerInfo atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    [self setUpCompanyPicker];
                }
            }
        });
    });
}

-(void) displayDisclaimer {
    NSError *error;
    NSString *hasDisclaimer = [NSString stringWithContentsOfFile:self.filePathDisclaimer
                                                        encoding:NSUTF8StringEncoding
                                                           error:&error];
    if ([hasDisclaimer isEqualToString:@""]) {
        //display disclaimer
    }
}

-(void) setUpCompanyPicker {
    NSError *error;
    
    [self updateCompanyNamesAndURLs];
    
    int pickerRow =[[NSString stringWithContentsOfFile:self.filePathPicker
                                              encoding:NSUTF8StringEncoding
                                                 error:&error]intValue];
    
    int newPickerRow = 0;
    NSString *oldPickerCompany = @"";
    
    if (pickerRow < [self.companyNames count]) {
        oldPickerCompany = self.companyNames[pickerRow];
        newPickerRow = (int)[self.companyNames indexOfObject: oldPickerCompany];
    }
    
    self.companyURL = self.companyURLs[newPickerRow];
    
    /* Picker View */
    if (self.pickerView == nil) {
        self.pickerView = [[UIPickerView alloc] init];
    } else {
        [self.pickerView reloadAllComponents];
    }
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.pickerView selectRow:newPickerRow inComponent:0 animated:YES];
    
    /* Text Field for Picker View */
    self.pickerTextField.delegate = self;
    self.pickerTextField.inputAccessoryView = [self returnDoneToolBar];
    self.pickerTextField.inputView = self.pickerView;
    self.pickerTextField.text = oldPickerCompany;
    [[self.pickerTextField valueForKey:@"textInputTraits"] setValue:[UIColor clearColor] forKey:@"insertionPointColor"];
}

-(void) updateCompanyNamesAndURLs {
    NSError *error;

    if (![[NSFileManager defaultManager] fileExistsAtPath: self.filePathCompanyPickerInfo] ||
        [[NSString stringWithContentsOfFile:self.filePathCompanyPickerInfo
                                  encoding:NSUTF8StringEncoding
                                     error:&error] isEqualToString:@""]) {
        NSArray *localCompanyNames = @[@"Allegisgroup", @"Calacademy", @"Cornell", @"COX",
                                       @"Kohls", @"University of Georgia", @"University of Miami"];
        
        NSArray *localCompanyURLs = @[@"https://timekeeper.allegisgroup.com", @"https://kronos.calacademy.org"
                                      , @"https://www.kronos.cornell.edu", @"https://wfc.coxenterprises.com"
                                      , @"https://kronos-ess.kohls.com", @"https://mytime.uga.edu"
                                      , @"https://timecard.miami.edu"];
        
        NSString *companyPickerInfo = @"";
        
        for (int i = 0; i < [localCompanyNames count]; i++) {
            companyPickerInfo = [[[companyPickerInfo stringByAppendingString:localCompanyNames[i]]
                                  stringByAppendingString:@","]
                                 stringByAppendingString:localCompanyURLs[i]];
            if (i < [localCompanyNames count] - 1) {
                companyPickerInfo = [companyPickerInfo stringByAppendingString:@"\n"];
            }
        }
        
        [companyPickerInfo writeToFile:self.filePathCompanyPickerInfo atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
    }
    
    NSString *fileContents = [NSString stringWithContentsOfFile:self.filePathCompanyPickerInfo
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
    
    NSMutableArray *companyDataArray = [NSMutableArray arrayWithArray:
                                        [fileContents componentsSeparatedByString:@"\n"]];
    NSMutableArray *tempCompanyNames = [[NSMutableArray alloc] init];
    NSMutableArray *tempCompanyURLs = [[NSMutableArray alloc] init];
    [tempCompanyNames addObject:@""];
    [tempCompanyURLs addObject:@""];
    
    for (int i = 0; i < [companyDataArray count]; i++) {
        NSArray *nameURLPair = [companyDataArray[i] componentsSeparatedByString:@","];
        [tempCompanyNames addObject:nameURLPair[0]];
        [tempCompanyURLs addObject:nameURLPair[1]];
    }
   // NSLog(@"%@",tempCompanyNames);
    //NSLog(@"%@",tempCompanyURLs);

    self.companyNames = [NSMutableArray arrayWithArray: tempCompanyNames];
    self.companyURLs = [NSMutableArray arrayWithArray: tempCompanyURLs];
}

-(UIToolbar *) returnDoneToolBar {
    CGRect toolBarFrame= CGRectMake(0, 0, 100, 44);
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:toolBarFrame];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolBar setItems:[NSArray arrayWithObjects:flexibleSpace, doneButton, nil]];
    return toolBar;
}

-(void) displayIAdBanner {
    if (self.hasAds) {
        self.adBanner = [[ADBannerView alloc] initWithFrame: CGRectZero];
        self.adBanner.delegate = self;
        self.adBanner.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        CGRect adFrame = self.adBanner.frame;
        adFrame.origin.y = [[UIScreen mainScreen] bounds].size.height;
        self.adBanner.frame = adFrame;
        [self.view addSubview:self.adBanner];
    }
}

//NEEDS WORK
-(void)submitForm {
    if ([self.companyURL isEqualToString: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please select a company"
                                                        message:@"Cox, Kohls, etc..."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        [self userInteractionEnabled: NO];
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.requestReply = [self postKronosStampWithUsername:self.username.text
                                                    password:self.password.text
                                                runningClock:self.runningClock];
        });
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            NSError *error;
            NSString *currentPickerRow = [NSString stringWithFormat:@"%d", (int)[self.pickerView selectedRowInComponent:0]];
            [self.username.text writeToFile:self.filePathUsername atomically:YES encoding:NSUTF8StringEncoding error:&error];
            [self.password.text writeToFile:self.filePathPassword atomically:YES encoding:NSUTF8StringEncoding error:&error];
            [currentPickerRow writeToFile:self.filePathPicker atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
            NSLog(@"%@", self.requestReply);
        
            NSString *resultFromStamp;
            
            if ([self.requestReply isEqualToString:@"-1"]) {
                self.message.text = @"Timed Out\n Try Again";
                self.message.textColor = [UIColor grayColor];
                resultFromStamp = @"timeout";
            } else if ([self.requestReply isEqualToString:@""] || [self.requestReply containsString:@"exception"]
                                                               || [self.requestReply containsString:@"incorrect"]
                                                               || [self.requestReply containsString:@"duplicate"]) {
                if ([self.requestReply containsString:@"incorrect"]) {
                    self.message.text = @"Incorrect\n User / Password";
                    resultFromStamp = @"invalid";
                } else if ([self.requestReply containsString:@"duplicate"]) {
                    self.message.text = @"Wait 1 min\n between stamps";
                    resultFromStamp = @"failed";
                } else {
                    self.message.text = @"FAILED";
                    resultFromStamp = @"failed";
                }
                self.message.textColor = [UIColor redColor];
            } else {
                if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePathLog]) {
                    [@"" writeToFile:self.filePathLog atomically:YES encoding:NSUTF8StringEncoding error:&error];
                }
                
                self.stampLog = [NSString stringWithContentsOfFile:self.filePathLog
                                                          encoding:NSUTF8StringEncoding
                                                             error:&error];
                
                TimeStamp *currentTimeStamp = [[TimeStamp alloc] init];
                NSString *currentStringTimeSince1970 = [NSString stringWithFormat: @"%f", currentTimeStamp.timeSince1970];
                self.stampLog = [[self.stampLog
                                  stringByAppendingString: currentStringTimeSince1970]
                                stringByAppendingString: @"\n"];
            
                [self.stampLog writeToFile:self.filePathLog atomically:YES encoding:NSUTF8StringEncoding error:&error];
                self.message.text = [@"SUCCESS\n" stringByAppendingString:currentTimeStamp.time];
                self.message.textColor = [UIColor blackColor];
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                 initWithAttributedString: self.message.attributedText];
                [text addAttribute:NSForegroundColorAttributeName
                             value:[UIColor greenColor]
                             range:NSMakeRange(0, 7)];
                [self.message setAttributedText: text];
                resultFromStamp = @"success";
            }
            self.requestReply = @"-1";
            self.message.hidden = NO;
            [JsonHandler postStampWithCompany: self.pickerTextField.text result:resultFromStamp];
            [self userInteractionEnabled: YES];
        });
    }
    
}

-(void)userInteractionEnabled: (BOOL) yes {
    self.submit.enabled = yes;
    self.username.enabled = yes;
    self.password.enabled = yes;
    if (yes) {
        [self.loadingIndicator stopAnimating];
        [self.submit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self.loadingIndicator startAnimating];
        [self.submit setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.message.hidden = YES;
        self.message.text = @"";
    }
}

-(NSString *)postKronosStampWithUsername: (NSString*) userName password: (NSString*) password runningClock: (NSString*) runningClock {
    NSString *post = [[[[[@"username=" stringByAppendingString:self.username.text]
                         stringByAppendingString:@"&password="]
                        stringByAppendingString:self.password.text]
                       stringByAppendingString:@"&qtsAction=&RunningClock="]
                      stringByAppendingString:self.runningClock];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", (int)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[self.companyURL stringByAppendingString: self.suffixURL]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSURLResponse *requestResponse;
    NSData *requestHandler = [NSURLConnection sendSynchronousRequest:request
                                                   returningResponse:&requestResponse
                                                               error:nil];
    NSString *stringResponse = [[NSString alloc] initWithBytes:[requestHandler bytes]
                                    length:[requestHandler length]
                                  encoding:NSASCIIStringEncoding];
    return stringResponse;
}

-(void)goToLogs {
    [self.adBanner removeFromSuperview];
    self.adBanner.delegate = nil;
    self.adBanner = nil;
    [self.admobBannerView removeFromSuperview];
    self.admobBannerView.delegate = nil;
    self.admobBannerView = nil;
    StampsViewController *oView = [[StampsViewController alloc] init];
    oView.hasAds = self.hasAds;
    [self presentViewController:oView animated:NO completion:nil];
}


/* Start Picker Delegate Methods */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSString *toReturn = @"";
    if (row == 0) {
        toReturn = @"--Select--";
    } else {
        toReturn = self.companyNames[row];
    }
    return toReturn;
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.companyNames.count;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.pickerTextField.text = self.companyNames[row];
    self.companyURL = self.companyURLs[row];
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    [self.pickerTextField resignFirstResponder];
}
/* End Picker Delegate Methods */


/* Start Text Field Delegate Methods */
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField: textField up: YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField: textField up: NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    self.message.hidden = YES;
    self.submit.enabled = !up;
    self.submit.hidden = up;

    int movementDistance = 80; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (screenSize.height > 480.0f) {
            /*Do iPhone 5 stuff here.*/
        } else {
            movementDistance = 90;
        }
    } else {
        /*Do iPad stuff here.*/
    }
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}
/* End Text Field Delegate Methods */


/* Start iAD and AdMob Delegate Methods */
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!_bannerIsVisible)
    {
        /* Remove AdMob banner if on screen */
        if (_admobBannerView.superview != nil) {
            [self.admobBannerView removeFromSuperview];
        }
        
        /* Add iAD banner */
        if (_adBanner.superview == nil) {
            [self.view addSubview:_adBanner];
        }
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -banner.frame.size.height);
        [UIView commitAnimations];
        _bannerIsVisible = YES;
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //NSLog(@"Failed to retrieve ad");
    
    if (_bannerIsVisible)
    {
        /* Remove iAD banner */
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        _bannerIsVisible = NO;
        [self.adBanner removeFromSuperview];
        
        /* Add AdMob banner */
        self.admobBannerView = [[GADBannerView alloc]
                        initWithFrame:CGRectMake(0.0,
                                                 [[UIScreen mainScreen] bounds].size.height - 50,
                                                 [[UIScreen mainScreen] bounds].size.width,
                                                 GAD_SIZE_320x50.height)];
        self.admobBannerView.adUnitID = @"ca-app-pub-4690871838608811/1059807681";
        self.admobBannerView.rootViewController = self;
        self.admobBannerView.delegate = self;
        [self.view addSubview:self.admobBannerView];
        [self.admobBannerView loadRequest:[GADRequest request]];
    }
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    /* Remove AdMob banner */
    [self.admobBannerView removeFromSuperview];
}
/* End iAD and AdMob Delegate Methods */


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveLogData {
    NSError *error;
    [[NSString stringWithContentsOfFile:self.filePathLog
                              encoding:NSUTF8StringEncoding
                                 error:&error] writeToFile:self.filePathLogBackup atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (void)restoreLogData {
    NSError *error;
    [[NSString stringWithContentsOfFile:self.filePathLogBackup
                               encoding:NSUTF8StringEncoding
                                  error:&error] writeToFile:self.filePathLog atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

@end
