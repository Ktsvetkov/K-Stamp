//
//  StampsViewController.m
//  ATG Kronos
//
//  Created by Kamen Tsvetkov on 7/10/15.
//  Copyright (c) 2015 Kametechs. All rights reserved.
//

#import "TimeStamp.h"
#import "StampsViewController.h"
#import "WeekOfStamps.h"
#import "AuthenticationViewController.h"

@interface StampsViewController ()

/* UI Elements */
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *currentWeek;
@property (weak, nonatomic) IBOutlet UIButton *backPageButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardPageButton;
@property (weak, nonatomic) IBOutlet UILabel *noStampLabel;

/* AD variables */
@property (nonatomic) NSMutableArray *adArray;
@property(nonatomic, strong) GADInterstitial *admobInterstitial;
@property (nonatomic, strong) ADInterstitialAd *iAdInterstitial;
@property BOOL admobDidLoad;
@property BOOL iAdDidLoad;

/* File Paths */
@property (strong, nonatomic) NSString *filePathAd;
@property (strong, nonatomic) NSString *filePathLog;

/* Table Data */
@property (nonatomic) NSArray *stampLogs;
@property (nonatomic) NSMutableArray *timeStamps;
@property (nonatomic) NSMutableArray *timeStampWeeks;
@property (nonatomic) NSMutableArray *tableViews;
@property int currentPage;


@end

@implementation StampsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hasScrollAds = NO;
    
    [self setImportantValues];
    [self setButtonMethods];
    [self setStampLogs];
    [self setTimeStamps];
    [self divideTimeStampsIntoWeeks];
    
    if ([self.timeStampWeeks count] == 0) {
        self.noStampLabel.hidden = NO;
    } else {
        self.noStampLabel.hidden = YES;
    }
    
    [self sortWeeks];
    [self sortStamps];
    
    [self creatTablesForEachWeek];

    if (self.hasAds) {
        if (self.hasScrollAds) {
            [self createADArray];
            [self addBlankViewsBetweenTables];
        }
        [self loadInterstitialAd];
    }
    
    self.scrollView.hidden = YES;

    [self setScrollView];
    [self setCurrentPage];
    [self reloadTableViews];
    [self hideNeededScrollButtons];
    [self setCurrentWeekLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [self autoScrollToCurrentTable];
    [self hideNeededScrollButtons];
    self.scrollView.hidden = NO;
}

/* Helper Methods */
-(void) setImportantValues {
    [self initArrays];
    [self setFilePaths];
    [self reloadAllValues];
}

-(void) initArrays {
    self.tableViews = [[NSMutableArray alloc] init];
    self.adArray = [[NSMutableArray alloc] init];
    self.timeStamps =[[NSMutableArray alloc] init];
    self.timeStampWeeks = [[NSMutableArray alloc] init];
}

-(void) setFilePaths {
    self.filePathLog = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"log.txt"];
    self.filePathAd = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"ad.txt"];
}

-(void) reloadAllValues {
    self.currentPage = 0;
}

-(void) setButtonMethods {
    [self.backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.clearButton addTarget:self action:@selector(clearLog) forControlEvents:UIControlEventTouchUpInside];
    [self.backPageButton addTarget:self action:@selector(scrollLeft) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardPageButton addTarget:self action:@selector(scrollRight) forControlEvents:UIControlEventTouchUpInside];
}

-(void) setStampLogs {
    NSError *error;
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePathLog];
    if (!fileExists) {
        [@"" writeToFile:self.filePathLog atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    
    // Test Value //
    //[@"1437761601\n1437661201\n1427761201\n1337596010\n" writeToFile:self.filePathLog atomically:YES encoding:NSUTF8StringEncoding error:&error];

    self.stampLogs = [[NSString stringWithContentsOfFile:self.filePathLog encoding:NSUTF8StringEncoding error:&error] componentsSeparatedByString:@"\n"];
    NSLog(@"Year of 1: %@", [[TimeStamp alloc]initWithTimeSince1970:@"1337596010"].year);
}

-(void) setTimeStamps {
    for (int i = 0; i < [self.stampLogs count] - 1; i++) {
        TimeStamp *stampToAdd = [[TimeStamp alloc] initWithTimeSince1970:self.stampLogs[i]];
        [self.timeStamps addObject:stampToAdd];
    }
}

-(void) divideTimeStampsIntoWeeks {
    NSMutableArray *possibleYears = [[NSMutableArray alloc] init];
    NSMutableArray *possibleWeeks = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.timeStamps count]; i++) {
        TimeStamp *currentTimeStamp = self.timeStamps[i];
        NSString *currentTestYear = currentTimeStamp.year;
        NSString *currentTestWeek = currentTimeStamp.week;

        if (![possibleYears containsObject:currentTestYear]) {
            [possibleYears addObject:currentTestYear];
        }
        if (![possibleWeeks containsObject:currentTestWeek]) {
            [possibleWeeks addObject:currentTestWeek];
        }
    }
    NSLog (@"possible years: %@", possibleYears);
    NSLog (@"possile weeks: %@", possibleWeeks);

    NSMutableArray *arrayOfArraysOfStamps = [[NSMutableArray alloc] init];
    for (int i = 0; i < [possibleYears count]; i++) {
        for (int j = 0; j < [possibleWeeks count]; j++) {
            WeekOfStamps *weekOfStamps = [[WeekOfStamps alloc] init];
            for (int k = 0; k < [self.timeStamps count]; k++) {
                TimeStamp *currentTimeStamp = self.timeStamps[k];
                if ([currentTimeStamp.year isEqualToString:possibleYears[i]] &&
                    [currentTimeStamp.week isEqualToString:possibleWeeks[j]]) {
                    [weekOfStamps.TimeStamps addObject:currentTimeStamp];
                }
            }
            if ([weekOfStamps.TimeStamps count] > 0) {
                [arrayOfArraysOfStamps addObject: weekOfStamps];
            }
        }
    }
    self.timeStampWeeks = arrayOfArraysOfStamps;
}

-(void) sortWeeks {
    TimeStamp *lowestPossible = [[TimeStamp alloc] initWithTimeSince1970:@"0"];
    NSMutableArray *newTimeStampWeeks = [[NSMutableArray alloc] init];
    int numberOfElements = (int)[self.timeStampWeeks count];
    for (int i = 0; i < numberOfElements; i++) {
        WeekOfStamps *greatestValue = [[WeekOfStamps alloc] init];
        [greatestValue.TimeStamps addObject:lowestPossible];
        for (int j = 0; j < [self.timeStampWeeks count]; j++) {
            WeekOfStamps *currentTimeStamp = self.timeStampWeeks[j];
            if ([currentTimeStamp getTimeSince1970] > [greatestValue getTimeSince1970]) {
                greatestValue = currentTimeStamp;
            }
        }
        [self.timeStampWeeks removeObject:greatestValue];
        [newTimeStampWeeks addObject:greatestValue];
    }
    NSMutableArray *newNewTimeStampWeeks = [[NSMutableArray alloc] init];
    for (int i = numberOfElements - 1; i > -1; i--) {
        WeekOfStamps *currentSwitcher = [newTimeStampWeeks objectAtIndex:i];
        [newNewTimeStampWeeks addObject:currentSwitcher];
    }
    self.timeStampWeeks = newNewTimeStampWeeks;
}

-(void) sortStamps {
    for (int i = 0; i< [self.timeStampWeeks count]; i++) {
        
        WeekOfStamps *currentWeek = self.timeStampWeeks[i];
        NSMutableArray *newCurrentStamps = [[NSMutableArray alloc] init];
        int numberOfTimeStamps = (int)[currentWeek.TimeStamps count];
        for (int j = 0; j < numberOfTimeStamps; j++) {
            TimeStamp *greatestPossible = [[TimeStamp alloc] initWithTimeSince1970:@"0"];
            for (int k = 0; k < [currentWeek.TimeStamps count]; k++) {
                TimeStamp *currentTimeStamp = currentWeek.TimeStamps[k];
                if (currentTimeStamp.timeSince1970 > greatestPossible.timeSince1970) {
                    greatestPossible = currentTimeStamp;
                }
            }
            [currentWeek.TimeStamps removeObject:greatestPossible];
            [newCurrentStamps addObject:greatestPossible];
        }
        
        NSMutableArray *newNewCurrentStamps = [[NSMutableArray alloc] init];
        for (int j = (int)[newCurrentStamps count] - 1; j > -1; j--) {
            TimeStamp *currentSwitcher = [newCurrentStamps objectAtIndex:j];
            [newNewCurrentStamps addObject:currentSwitcher];
        }
        
        currentWeek.TimeStamps = newNewCurrentStamps;
        self.timeStampWeeks[i] = currentWeek;
    }
}

-(void) creatTablesForEachWeek {
    for (int i = 0; i < [self.timeStampWeeks count]; i++) {
        UITableView *primaryTableView = [[UITableView alloc] init];
        primaryTableView.backgroundColor = self.view.backgroundColor;
        [primaryTableView setSeparatorInset:UIEdgeInsetsZero];
        [primaryTableView setLayoutMargins:UIEdgeInsetsZero];
        primaryTableView.delegate = self;
        primaryTableView.dataSource = self;
        [self.tableViews addObject:primaryTableView];
    }
}

-(void) createADArray {
    if ([self.timeStampWeeks count] > 0) {
        for (int i =0; i < [self.timeStampWeeks count] - 1; i++) {
            ADInterstitialAd *currentAd = [[ADInterstitialAd alloc] init];
            currentAd.delegate = self;
            [self.adArray addObject:currentAd];
        }
    }
}

-(void) addBlankViewsBetweenTables {
    for (int i = 0; i < [self.tableViews count]; i+=2) {
        if (i < [self.tableViews count] - 1) {
            UIView *sampleAd = [[UIView alloc] init];
            [self.tableViews insertObject:sampleAd atIndex:i+1];
        }
    }
}

-(void) setScrollView {
    for (int i = 0; i < [self.tableViews count]; i++) {
        CGRect frame = CGRectMake(0, 0, 0, 0);
        frame.origin.x = [UIScreen mainScreen].applicationFrame.size.width * i;
        frame.origin.y = 0;
        frame.size.width = [UIScreen mainScreen].applicationFrame.size.width;
        frame.size.height = [UIScreen mainScreen].bounds.size.height - 126;
        
        UIView *subview = [self.tableViews objectAtIndex:i];
        subview.frame = frame;
        
        [self.scrollView addSubview:subview];
    }
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width * [self.tableViews count],
                                             [UIScreen mainScreen].applicationFrame.size.height- 126);
    self.scrollView.showsHorizontalScrollIndicator = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.delegate = self;
}

-(void) setCurrentPage {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentPage = page;
}

-(void) autoScrollToCurrentTable {
    int amountToOffset = [UIScreen mainScreen].applicationFrame.size.width * ([self.tableViews count] - 1);
    if ([self currentPage] != 0) {
        amountToOffset = [UIScreen mainScreen].applicationFrame.size.width * ([self currentPage]);
    }
    if ([self.tableViews count] > 0) {
        self.scrollView.contentOffset = CGPointMake(amountToOffset, 0);
    }
}

-(void) hideNeededScrollButtons {
    if (!(self.currentPage > 0)) {
        self.backPageButton.hidden = YES;
    } else {
        self.backPageButton.hidden = NO;
    }
    if (!(self.currentPage < [self.tableViews count]-1)) {
        self.forwardPageButton.hidden = YES;
    } else {
        self.forwardPageButton.hidden = NO;
    }
    if ([self.timeStampWeeks count] < 2) {
        self.forwardPageButton.hidden = YES;
        self.backPageButton.hidden = YES;
    }
}


/* Table View delegate */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger toReturn;
    WeekOfStamps *currentWeekOfStamps = self.timeStampWeeks[[self getCurrentWeekIndex]];
    if ([currentWeekOfStamps.TimeStamps count] == 0) {
        toReturn = 0;
    } else {
        toReturn = [currentWeekOfStamps.TimeStamps count];
    }
    return toReturn;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    if ([self.timeStampWeeks count] == 0) {
        UITableView *currenTableView = [self.tableViews objectAtIndex:self.currentPage];
        currenTableView.hidden = YES;
    } else {
        WeekOfStamps *currentWeekOfStamps = self.timeStampWeeks[[self getCurrentWeekIndex]];
        TimeStamp *toSet = [currentWeekOfStamps.TimeStamps objectAtIndex:indexPath.row];
        cell.textLabel.text = [[toSet.day stringByAppendingString:@" "]
                                            stringByAppendingString:toSet.time];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    [cell setLayoutMargins:UIEdgeInsetsZero];
    cell.backgroundColor = self.view.backgroundColor;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/* Load Ads */
-(void) loadInterstitialAd {
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.filePathAd]) {
        [@"0" writeToFile:self.filePathAd atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    int currentNumber = [[NSString stringWithContentsOfFile:self.filePathAd encoding:NSUTF8StringEncoding error:&error] intValue];
    
    int everyAmountOfPages = 3; // every 3 times
    
    if (currentNumber > everyAmountOfPages - 2) {
        self.iAdDidLoad = NO;
        self.admobDidLoad = NO;
    
        /* Apple */
        self.iAdInterstitial = [[ADInterstitialAd alloc] init];
        self.iAdInterstitial.delegate = self;
    
        /* Google */
        self.admobInterstitial = [[GADInterstitial alloc] initWithAdUnitID: @"ca-app-pub-4690871838608811/7514810486"];
        self.admobInterstitial.delegate = self;
        GADRequest *request = [GADRequest request];
        //request.testDevices = @[@"9a07ec750600137f76965b860e722adb"];
        [self.admobInterstitial loadRequest:request];
    } else {
        currentNumber += 1;
        NSString *toWrite = [NSString stringWithFormat:@"%d", currentNumber];
        [toWrite writeToFile:self.filePathAd atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

/* Apple interstitial Ad Delegate */
- (void) interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd {
    NSError *error;
    self.iAdDidLoad = YES;
    if (!self.admobDidLoad && self.isViewLoaded && self.view.window) {
        [interstitialAd presentFromViewController:self];
        NSLog(@"iAd loaded");
        [@"0" writeToFile:self.filePathAd atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

- (void) interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
    
}

- (void) interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {}

/* Google interstitial Ad Delegate */
- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSError *error;
    self.admobDidLoad = YES;
    if (!self.iAdDidLoad && self.isViewLoaded && self.view.window) {
        [interstitial presentFromRootViewController:self];
        NSLog(@"admob loaded");
        [@"0" writeToFile:self.filePathAd atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {}


/* Scroll View delegate */
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    [self setCurrentPage];
    if (self.hasAds && self.hasScrollAds) {
        [self displayBetweenPageADs];
    }
    [self reloadTableViews];
    [self hideNeededScrollButtons];
    [self setCurrentWeekLabel];
}

/* Alert View Delegate */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSError *error;
        [@"" writeToFile:self.filePathLog atomically:YES encoding:NSUTF8StringEncoding error:&error];
        NSArray *scrollViewSubViews = self.scrollView.subviews;
        for (int i = 0; i < [scrollViewSubViews count]; i++) {
            UIView *currentView = scrollViewSubViews[i];
            [currentView removeFromSuperview];
        }
        self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].applicationFrame.size.width,
                                                 [UIScreen mainScreen].applicationFrame.size.height- 126);
        [self viewDidLoad];
    }
}


/* Button Methods */
-(void)goBack {
    self.iAdInterstitial.delegate = nil;
    self.iAdInterstitial = nil;
    self.admobInterstitial.delegate = nil;
    self.admobInterstitial = nil;
    AuthenticationViewController *oView = [[AuthenticationViewController alloc] init];
    oView.hasAds = self.hasAds;
    [self presentViewController:oView animated:NO completion:nil];
}

-(void)clearLog {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to clear your stamps?"
                                                      message:@""
                                                     delegate:self
                                            cancelButtonTitle:@"Yes"
                                            otherButtonTitles:@"No", nil];
    [message show];
}

- (void)scrollLeft {
    int newScrollPosition = self.scrollView.contentOffset.x - [UIScreen mainScreen].applicationFrame.size.width;
    self.scrollView.contentOffset = CGPointMake(newScrollPosition, 0);
}

- (void)scrollRight {
    int newScrollPosition = self.scrollView.contentOffset.x + [UIScreen mainScreen].applicationFrame.size.width;
    self.scrollView.contentOffset = CGPointMake(newScrollPosition, 0);
}

/* Delegate Helper Methods */
- (int)getCurrentWeekIndex {
    int realCurrentPage = self.currentPage;
    if (self.hasAds && self.hasScrollAds) {
        realCurrentPage = realCurrentPage/2;
    }
    return realCurrentPage;
}

-(void)displayBetweenPageADs {
    if ([self isADPage]) {
        NSArray *scrollViewSubViews = self.scrollView.subviews;
        UIView *viewToDisplayAD = scrollViewSubViews[self.currentPage];
        ADInterstitialAd *currentAd = self.adArray[[self getCurrentWeekIndex]];
        [currentAd presentInView: viewToDisplayAD];
    }
}

-(void)reloadTableViews {
    int incrementor = 0;
    if (self.hasAds && self.hasScrollAds) {
        incrementor = 2;
    } else {
        incrementor = 1;
    }
    for (int i = 0; i < [self.tableViews count]; i = i + incrementor) {
        [self.tableViews[i] reloadData];
    }
}

-(void)setCurrentWeekLabel {
    if ([self.timeStampWeeks count] == 0) {
        self.currentWeek.hidden = YES;
    } else {
        NSString *toSet = @"";
        WeekOfStamps *currentWeekOfStamps = self.timeStampWeeks[[self getCurrentWeekIndex]];
        NSString *currentWeek = [currentWeekOfStamps getWeek];
        NSString *currentYear = [currentWeekOfStamps getYear];
        toSet = [NSString stringWithFormat:@"%@ - Week: %@/52 ", currentYear, currentWeek];
        if (self.hasAds && [self isADPage] && self.hasScrollAds) {
            self.currentWeek.text = @"AD";
        } else {
            self.currentWeek.text = toSet;
        }
    }
    return;
}

-(BOOL) isADPage {
    return self.currentPage %2 != 0;
}


/* Memory */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
