//
//  FeedBackVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//
#import "FeedBackVC.h"
#import "UIImageView+Download.h"
#import "UIView+Utils.h"

@interface FeedBackVC ()
{
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strRequsetId;
    
    NSString *strTime;
    NSString *strDistance;
    NSString *strProfilePic;
    NSString *strLastName;
    NSString *strFirstName;
    int rate;
}

@property (weak, nonatomic) IBOutlet UIView *invoiceView;
@property (weak, nonatomic) IBOutlet UILabel *lblBasePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblDistancePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblTimePrice;
@property (weak, nonatomic) IBOutlet UILabel *lblTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminAmt;
@property (weak, nonatomic) IBOutlet UILabel *lblProviderAmt;
@property (weak, nonatomic) IBOutlet UILabel *lblPerDist;
@property (weak, nonatomic) IBOutlet UILabel *lblPerTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscounts;

@end

@implementation FeedBackVC

@synthesize txtComment,dictWalkInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customFont];
    
    [self getWalkPrices];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strDistance=[pref objectForKey:PREF_WALK_DISTANCE];
    strTime=[pref objectForKey:PREF_WALK_TIME];
    strProfilePic=[pref objectForKey:PREF_USER_PICTURE];
    strLastName=[pref objectForKey:PREF_USER_NAME];
    
    
    NSArray *myWords = [strLastName componentsSeparatedByString:@" "];
    
    self.lblFirstName.text=[myWords objectAtIndex:0];
    self.lblLastName.text=[myWords objectAtIndex:1];
    [self.imgProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    self.lblDistance.text=[NSString stringWithFormat:@"%@ Miles",strDistance];
    self.lblTime.text=[NSString stringWithFormat:@"%@ Mins",strTime];
    self.lblTask1.text=@"0";
    self.lblTask2.text=@"1";
    [self.imgProfile downloadFromURL:strProfilePic withPlaceholder:nil];
    
    [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    ratingView=[[RatingBar alloc] initWithSize:CGSizeMake(120, 20) AndPosition:CGPointMake(158, 152)];
    ratingView.backgroundColor=[UIColor clearColor];
    
    [self.view addSubview:ratingView];
    
    [self.invoiceView setHidden:NO];
    [self.view bringSubviewToFront:self.invoiceView];
    // Do any additional setup after loading the view.
}

-(void)getWalkPrices {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    dictWalkInfo = [pref objectForKey:@"billDetails"];
    
    self.lblBasePrice.text=[NSString stringWithFormat:@"%@ %.2f",[dictWalkInfo valueForKey:@"currency"],[[dictWalkInfo valueForKey:@"base_price"] floatValue]];
    self.lblDistancePrice.text=[NSString stringWithFormat:@"%@ %.2f",[dictWalkInfo valueForKey:@"currency"],[[dictWalkInfo valueForKey:@"distance_cost"] floatValue]];
    self.lblTimePrice.text=[NSString stringWithFormat:@"%@ %.2f",[dictWalkInfo valueForKey:@"currency"],[[dictWalkInfo valueForKey:@"time_cost"] floatValue]];
    
    float totalAmt = [[dictWalkInfo valueForKey:@"actual_total"] floatValue];
    float adminAmt = [[[dictWalkInfo valueForKey:@"admin"] objectForKey:@"amount"] floatValue];
    float providerAmt = [[[dictWalkInfo valueForKey:@"walker"] objectForKey:@"amount"] floatValue];
    
    self.lblTotal.text= [NSString stringWithFormat:@"%@ %.2f",[dictWalkInfo valueForKey:@"currency"],totalAmt];
    
    self.lblAdminAmt.text = [NSString stringWithFormat:@"%@ %.2f",[dictWalkInfo valueForKey:@"currency"],adminAmt];
    self.lblProviderAmt.text = [NSString stringWithFormat:@"%@ %.2f",[dictWalkInfo valueForKey:@"currency"],providerAmt];
    
    float discountsAmt = totalAmt - (adminAmt + providerAmt);
    
    self.lblDiscounts.text = [NSString stringWithFormat:@"%@ %.2f",[dictWalkInfo valueForKey:@"currency"],discountsAmt];
    
    float totalDist=[[dictWalkInfo valueForKey:@"distance_cost"] floatValue];
    float Dist=[[dictWalkInfo valueForKey:@"distance"]floatValue];
    
    if ([[dictWalkInfo valueForKey:@"unit"]isEqualToString:@"kms"])
    {
        totalDist=totalDist*0.621317;
        Dist=Dist*0.621371;
    }
    if(Dist!=0)
    {
        self.lblPerDist.text=[NSString stringWithFormat:@"%@ %.2f per Miles",[dictWalkInfo valueForKey:@"currency"],(totalDist/Dist)];
    }
    else
    {
        self.lblPerDist.text=[NSString stringWithFormat:@"%@ 0.00 per Miles",[dictWalkInfo valueForKey:@"currency"]];
    }
    
    float totalTime=[[dictWalkInfo valueForKey:@"time_cost"] floatValue];
    float Time=[[dictWalkInfo valueForKey:@"time"]floatValue];
    if(Time!=0)
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"%@ %.2f per Mins",[dictWalkInfo valueForKey:@"currency"],(totalTime/Time)];
    }
    else
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"%@ 0.00 per Mins",[dictWalkInfo valueForKey:@"currency"]];
    }
}

/*- (IBAction)onClickMenu:(id)sender{
 [self.revealViewController revealToggle:sender];
 }*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)giveFeedback
{
    RBRatings rating=[ratingView getcurrentRatings];
    rate=rating/2.0;
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    if (strRequsetId!=nil)
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        
        [dictparam setObject:[NSString stringWithFormat:@"%d",rate] forKey:PARAM_RATING];
        [dictparam setObject:txtComment.text forKey:PARAM_COMMENT];
        
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_RATING withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             [APPDELEGATE hideLoadingView];
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"RATING_COMPLETED", nil)];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_REQUEST_ID];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_NAME];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PHONE];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PICTURE];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_RATING];
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_START_TIME];
                 is_completed=0;
                 is_dog_rated=0;
                 is_started=0;
                 is_walker_arrived=0;
                 is_walker_started=0;
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
             else
             {
                 [APPDELEGATE hideLoadingView];
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
             
         }];
    }
}

#pragma mark-
#pragma mark-

-(void)customFont
{
    self.lblTime.font=[UberStyleGuide fontRegular];
    self.lblDistance.font=[UberStyleGuide fontRegular];
    self.lblTask1.font=[UberStyleGuide fontRegular];
    self.lblTask2.font=[UberStyleGuide fontRegular];
    self.lblFirstName.font=[UberStyleGuide fontRegular];
    self.lblLastName.font=[UberStyleGuide fontRegular];
    
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnSubmit=[APPDELEGATE setBoldFontDiscriptor:self.btnSubmit];
    self.btnSkip=[APPDELEGATE setBoldFontDiscriptor:self.btnSkip];
    
}
#pragma mark-
#pragma mark- Bytton Methods
- (IBAction)submitBtnPressed:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"WAITING_FOR_FEEDBACK", nil)];
    [txtComment resignFirstResponder];
    [self giveFeedback];
}

- (IBAction)skipBtnPressed:(id)sender {
    [txtComment resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_REQUEST_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_NAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PHONE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_PICTURE];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_USER_RATING];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREF_START_TIME];
    is_completed=0;
    is_dog_rated=0;
    is_started=0;
    is_walker_arrived=0;
    is_walker_started=0;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark-
#pragma mark- Text Field Delegate

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtComment resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField     //Hide the keypad when we pressed return
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    self.txtComment.text=@"";
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComment)
            {
                UITextPosition *beginning = [self.txtComment beginningOfDocument];
                [self.txtComment setSelectedTextRange:[self.txtComment textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, -210, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComment)
            {
                UITextPosition *beginning = [self.txtComment beginningOfDocument];
                [self.txtComment setSelectedTextRange:[self.txtComment textRangeFromPosition:beginning
                                                                                  toPosition:beginning]];
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, -210, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
        }
    }
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 568)
        {
            if(textView == self.txtComment)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 568);
                    
                } completion:^(BOOL finished) { }];
            }
        }
        else
        {
            if(textView == self.txtComment)
            {
                [UIView animateWithDuration:0.3 animations:^{
                    
                    self.view.frame = CGRectMake(0, 0, 320, 480);
                    
                } completion:^(BOOL finished) { }];
            }
        }
    }
    if ([txtComment.text isEqualToString:@""])
    {
        txtComment.text=@"Comments";
    }
    
}

/*- (void)textFieldDidBeginEditing:(UITextField *)textField
 
 {
 if(textField == self.txtComment)
 {
 UITextPosition *beginning = [self.txtComment beginningOfDocument];
 [self.txtComment setSelectedTextRange:[self.txtComment textRangeFromPosition:beginning
 toPosition:beginning]];
 [UIView animateWithDuration:0.3 animations:^{
 
 self.view.frame = CGRectMake(0, -120, 320, 480);
 
 } completion:^(BOOL finished) { }];
 }
 }
 
 - (void)textFieldDidEndEditing:(UITextField *)textField
 {
 UIDevice *thisDevice=[UIDevice currentDevice];
 if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
 {
 CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
 
 if (iOSDeviceScreenSize.height == 568)
 {
 if(textField == self.txtComment)
 {
 [UIView animateWithDuration:0.3 animations:^{
 
 self.view.frame = CGRectMake(0, 0, 320, 568);
 
 } completion:^(BOOL finished) { }];
 }
 }
 else
 {
 if(textField == self.txtComment)
 {
 [UIView animateWithDuration:0.3 animations:^{
 
 self.view.frame = CGRectMake(0, 0, 320, 480);
 
 } completion:^(BOOL finished) { }];
 }
 }
 }
 }
 */

- (IBAction)closeBtnEvent:(id)sender {
    [self.invoiceView setHidden:YES];
}


@end
