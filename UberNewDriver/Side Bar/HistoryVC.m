//
//  HistoryVC.m
//  UberforX Provider
//
//  Created by My Mac on 11/15/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "HistoryVC.h"
#import "HistoryCell.h"
#import "UIImageView+Download.h"
#import "UtilityClass.h"

@interface HistoryVC ()
{
    NSMutableArray *arrHistory;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableArray *arrForDate;
    NSMutableArray *arrForSection;
    
    //BOOL internet;
}


@property (weak, nonatomic) IBOutlet UILabel *lblAdminAmt;
@property (weak, nonatomic) IBOutlet UILabel *lblProviderAmt;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscountsAmt;

@end

@implementation HistoryVC

@synthesize tableHistory;


#pragma mark-
#pragma mark- View Delegate Method

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setBackBarItem];
    arrHistory=[[NSMutableArray alloc]init];
    [self customFont];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    // internet=[APPDELEGATE connected];
    [self.paymentView setHidden:YES];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"LOADING_HISTORY", nil)];
    [self getHistory];
    self.imgNoItems.hidden=YES;
    self.navigationController.navigationBarHidden=NO;
}

#pragma mark-
#pragma mark- customFont

-(void)customFont
{
    self.lblBasePrice.font=[UberStyleGuide fontRegular];
    self.lblDistCost.font=[UberStyleGuide fontRegular];
    self.lblPerDist.font=[UberStyleGuide fontRegular];
    self.lblPerTime.font=[UberStyleGuide fontRegular];
    self.lblTimeCost.font=[UberStyleGuide fontRegular];
    //self.lblTotal.font=[UberStyleGuide fontRegular:30.0f];
    
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnClose=[APPDELEGATE setBoldFontDiscriptor:self.btnClose];
}
#pragma mark-
#pragma mark- Get History API Method



-(void)getHistory
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@",FILE_HISTORY,PARAM_ID,strUserId,PARAM_TOKEN,strUserToken];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             
             //NSLog(@"History Data= %@",response);
             
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     arrHistory=[response valueForKey:@"requests"];
                     if (arrHistory.count==0)
                     {
                         self.imgNoItems.hidden=NO;
                         self.tableHistory.hidden=YES;
                     }
                     else
                     {
                         [self makeSection];
                         self.imgNoItems.hidden=YES;
                         self.tableHistory.hidden=NO;
                         [tableHistory reloadData];
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
        [APPDELEGATE hideLoadingView];
        self.imgNoItems.hidden=NO;
        self.tableHistory.hidden=YES;
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
}


#pragma mark-
#pragma mark- Table View Delegate

-(void)makeSection
{
    arrForDate=[[NSMutableArray alloc]init];
    arrForSection=[[NSMutableArray alloc]init];
    NSMutableArray *arrtemp=[[NSMutableArray alloc]init];
    [arrtemp addObjectsFromArray:arrHistory];
    NSSortDescriptor *distanceSortDiscriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO
                                                                              selector:@selector(localizedStandardCompare:)];
    
    [arrtemp sortUsingDescriptors:@[distanceSortDiscriptor]];
    
    for (int i=0; i<arrtemp.count; i++)
    {
        NSMutableDictionary *dictDate=[[NSMutableDictionary alloc]init];
        dictDate=[arrtemp objectAtIndex:i];
        
        NSString *temp=[dictDate valueForKey:@"date"];
        NSArray *arrDate=[temp componentsSeparatedByString:@" "];
        NSString *strdate=[arrDate objectAtIndex:0];
        if(![arrForDate containsObject:strdate])
        {
            [arrForDate addObject:strdate];
        }
        
    }
    
    for (int j=0; j<arrForDate.count; j++)
    {
        NSMutableArray *a=[[NSMutableArray alloc]init];
        [arrForSection addObject:a];
    }
    for (int j=0; j<arrForDate.count; j++)
    {
        NSString *strTempDate=[arrForDate objectAtIndex:j];
        
        for (int i=0; i<arrtemp.count; i++)
        {
            NSMutableDictionary *dictSection=[[NSMutableDictionary alloc]init];
            dictSection=[arrtemp objectAtIndex:i];
            NSArray *arrDate=[[dictSection valueForKey:@"date"] componentsSeparatedByString:@" "];
            NSString *strdate=[arrDate objectAtIndex:0];
            if ([strdate isEqualToString:strTempDate])
            {
                [[arrForSection objectAtIndex:j] addObject:dictSection];
                
            }
        }
        
    }
    
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [[arrForSection objectAtIndex:section] count];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0f;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arrForSection.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 25)];
    UILabel *lblDate=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 20)];
    lblDate.font=[UberStyleGuide fontRegular];
    lblDate.textColor=[UberStyleGuide colorDefault];
    NSString *strDate=[arrForDate objectAtIndex:section];
    NSString *current=[[UtilityClass sharedObject] DateToString:[NSDate date] withFormate:@"yyyy-MM-dd"];
    
    
    ///   YesterDay Date Calulation
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -1;
    NSDate *yesterday = [gregorian dateByAddingComponents:dayComponent
                                                   toDate:[NSDate date]
                                                  options:0];
    NSString *strYesterday=[[UtilityClass sharedObject] DateToString:yesterday withFormate:@"yyyy-MM-dd"];
    
    
    if([strDate isEqualToString:current])
    {
        lblDate.text=@"Today";
        headerView.backgroundColor=[UberStyleGuide colorDefault];
        lblDate.textColor=[UIColor whiteColor];
        lblDate.font=[UberStyleGuide fontRegular];
    }
    else if ([strDate isEqualToString:strYesterday])
    {
        lblDate.text=@"Yesterday";
        lblDate.font=[UberStyleGuide fontRegular];
    }
    else
    {
        NSDate *date=[[UtilityClass sharedObject]stringToDate:strDate withFormate:@"yyyy-MM-dd"];
        NSString *text=[[UtilityClass sharedObject]DateToString:date withFormate:@"dd MMMM yyyy"];//2nd Jan 2015
        lblDate.text=text;
        lblDate.font=[UberStyleGuide fontRegular];
    }
    
    [headerView addSubview:lblDate];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *pastDict=[[arrForSection objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    NSMutableDictionary *dictOwner=[pastDict valueForKey:@"owner"];
    
    static NSString *CellIdentifier = @"Cell";
    
    HistoryCell *cell = [tableHistory dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell==nil)
    {
        cell=[[HistoryCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.lblName.font=[UberStyleGuide fontRegularBold:12.0f];
    cell.lblCost.font=[UberStyleGuide fontRegular:20.0f];
    cell.lblType.font=[UberStyleGuide fontRegular];
    
    
    NSDate *dateTemp=[[UtilityClass sharedObject]stringToDate:[pastDict valueForKey:@"date"]];
    NSString *strDate=[[UtilityClass sharedObject]DateToString:dateTemp withFormate:@"hh:mm a"];
    cell.lblDateTime.text=[NSString stringWithFormat:@"%@",strDate];
    //cell.lblDateTime.font=[UberStyleGuide fontRegular];
    cell.lblName.text=[NSString stringWithFormat:@"%@ %@",[dictOwner valueForKey:@"first_name"],[dictOwner valueForKey:@"last_name"]];
    cell.lblType.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
    cell.lblCost.text=[NSString stringWithFormat:@"%@ %.2f ",[pastDict valueForKey:@"currency"],[[pastDict valueForKey:@"total"] floatValue]];
    
    [cell.imgOwner downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
    cell.imgOwner.contentMode = UIViewContentModeScaleAspectFill;
    
    return cell;
    
    
    
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationController.navigationBarHidden=YES;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSMutableDictionary *pastDict=[[arrForSection objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    
    self.lblBasePrice.text=[NSString stringWithFormat:@"%@ %.2f",[pastDict valueForKey:@"currency"],[[pastDict valueForKey:@"base_price"]floatValue]];
    self.lblDistCost.text=[NSString stringWithFormat:@"%@ %.2f",[pastDict valueForKey:@"currency"],[[pastDict valueForKey:@"distance_cost"] floatValue]];
    self.lblTimeCost.text=[NSString stringWithFormat:@"%@ %.2f",[pastDict valueForKey:@"currency"],[[pastDict valueForKey:@"time_cost"] floatValue]];
    
    float totalAmt = [[pastDict valueForKey:@"total"] floatValue];
    float adminAmt = [[[pastDict valueForKey:@"admin"] objectForKey:@"amount"] floatValue];
    float providerAmt = [[[pastDict valueForKey:@"walker"] objectForKey:@"amount"] floatValue];
    
    self.lblTotal.text= [NSString stringWithFormat:@"%@ %.2f",[pastDict valueForKey:@"currency"],totalAmt];
    
    self.lblAdminAmt.text = [NSString stringWithFormat:@"%@ %.2f",[pastDict valueForKey:@"currency"],adminAmt];
    self.lblProviderAmt.text = [NSString stringWithFormat:@"%@ %.2f",[pastDict valueForKey:@"currency"],providerAmt];
    
    float discountsAmt = totalAmt - (adminAmt + providerAmt);
    
    self.lblDiscountsAmt.text = [NSString stringWithFormat:@"%@ %.2f",[pastDict valueForKey:@"currency"],discountsAmt];
    
    float totalDist=[[pastDict valueForKey:@"distance_cost"] floatValue];
    float Dist=[[pastDict valueForKey:@"distance"]floatValue];
    
    if ([[pastDict valueForKey:@"unit"]isEqualToString:@"kms"])
    {
        totalDist=totalDist*0.621317;
        Dist=Dist*0.621371;
    }
    if(Dist!=0)
    {
        self.lblPerDist.text=[NSString stringWithFormat:@"%@ %.2f per Miles",[pastDict valueForKey:@"currency"],(totalDist/Dist)];
    }
    else
    {
        self.lblPerDist.text=[NSString stringWithFormat:@"%@ 0.00 per Miles",[pastDict valueForKey:@"currency"]];
    }
    
    float totalTime=[[pastDict valueForKey:@"time_cost"] floatValue];
    float Time=[[pastDict valueForKey:@"time"]floatValue];
    if(Time!=0)
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"%@ %.2f per Mins",[pastDict valueForKey:@"currency"],(totalTime/Time)];
    }
    else
    {
        self.lblPerTime.text=[NSString stringWithFormat:@"%@ 0.00 per Mins",[pastDict valueForKey:@"currency"]];
    }
    
    
    
    
    [self.paymentView setHidden:NO];
    
}



#pragma mark-
#pragma mark- Button Method


- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)closeBtnPressed:(id)sender
{
    self.navigationController.navigationBarHidden=NO;
    [self.paymentView setHidden:YES];
}
@end
