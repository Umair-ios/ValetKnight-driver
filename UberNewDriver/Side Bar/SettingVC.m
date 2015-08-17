//
//  SettingVC.m
//  UberforX Provider
//
//  Created by My Mac on 11/15/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "SettingVC.h"

@interface SettingVC ()
{
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    
    
}

@end

@implementation SettingVC
@synthesize swAvailable;

- (void)viewDidLoad
{
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    [super viewDidLoad];
    [self checkState];
    [super setBackBarItem];
    [self customFont];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- customFont

-(void)customFont
{
    self.lblAvailable.font=[UberStyleGuide fontRegular];
    self.lblYes.font=[UberStyleGuide fontRegular];
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    
}

-(void)checkState
{
    if([APPDELEGATE connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_CHECKSTATUS,PARAM_ID,strUserId,PARAM_TOKEN,strUserToken];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             //NSLog(@"History Data= %@",response);
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     if([[response valueForKey:@"is_active"] intValue]==1)
                     {
                         swAvailable.on=YES;
                         self.lblYes.text=@"YES";
                     }
                     else
                     {
                         swAvailable.on=NO;
                         self.lblYes.text=@"NO";
                     }
                 }
             }
             else
             {
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
         }];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)setStatus
{
    if([APPDELEGATE connected])
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_TOGGLE withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             //NSLog(@"Request in Progress= %@",response);
             if (response)
             {
                 if([[response valueForKey:@"success"]intValue]==1)
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"AVAILABILITY_UODATE", nil)];
                 }
             }
             else
             {
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
             
         }];
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)setState:(id)sender
{
    if ([swAvailable isOn]==NO)
    {
        self.lblYes.text=@"NO";
        
    }
    else
    {
        self.lblYes.text=@"YES";
    }
    [self setStatus];
    
}
@end
