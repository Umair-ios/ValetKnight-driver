//
//  PickMeUpMapVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "PickMeUpMapVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "RegexKitLite.h"
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "ContactVC.h"
#import "ArrivedMapVC.h"
#import "RatingBar.h"
#import "UIView+Utils.h"

@interface PickMeUpMapVC () <SWRevealViewControllerDelegate> {
    CLLocationManager *locationManager;
    
    NSMutableArray *arrRequest;
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strRequsetId;
    NSMutableDictionary *dict;
    BOOL flag,isTo;
    int time;
    float totalDist;
    UIButton *btn;
}
@end

@implementation PickMeUpMapVC
@synthesize lblBlue,lblGrey,btnProfile,btnAccept,btnReject,lblDetails,lblName,lblRate,imgStar,ProfileView,imgUserProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //internet=[APPDELEGATE connected];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:PREF_IS_NEW_REQ_PUSH];
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:PREF_IS_CANCEL_REQ_PUSH];
    
    self.arrivedMap.pickMeUp=self;
    self.revealViewController.delegate = self;
    
    [self.imgUserProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    
    // Get User location
    [self getUserLocation];
    
    isTo=NO;
    progressView = [[LDProgressView alloc] initWithFrame:CGRectMake(-50,-50, 320,20)];
    progressView.color = [UIColor colorWithRed:0.0f/255.0f green:193.0f/255.0f blue:63.0f/255.0f alpha:1.0];
    progressView.progress = 1.0;
    progressView.showText = @NO;
    progressView.animate = @NO;
    progressView.borderRadius = @NO;
    [self.ProfileView addSubview:progressView];
    [self.ProfileView bringSubviewToFront:self.lblTime];
    
    [self customSetup];
    self.etaView.hidden=YES;
    
    
    [self.ratingView initRateBar];
    [self.ratingView setUserInteractionEnabled:NO];
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    [self updateLocation];
    [self getPagesData];
    [self customFont];
    
    
    time=0;
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:current.latitude
                                                            longitude:current.longitude
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,0,320,505) camera:camera];
    mapView_.myLocationEnabled = NO;
    [self.viewForMap addSubview:mapView_];
    
    [self hide];
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    if(position == FrontViewPositionLeft) {
        [btn removeFromSuperview];
    } else {
        btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [btn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:btn];
        [self.view bringSubviewToFront:btn];
    }
}


- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    
    [self hide];
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    [self updateLocation];
    
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
    [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
    
    self.navigationItem.hidesBackButton=YES;
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showUserLoc) userInfo:nil repeats:NO];
    [self getRequestId];
    
    strowner_lati=nil;
    strowner_longi=nil;
}

-(void)gotPushForNewReq {
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:PREF_IS_NEW_REQ_PUSH];
    
    [self.time invalidate];
    [self.progtime invalidate];
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    lblName.text=[NSString stringWithFormat:@"%@",[pref objectForKey:PREF_USER_NAME]];
    lblRate.text=[NSString stringWithFormat:@"%@",[pref objectForKey:PREF_USER_RATING]];
    lblDetails.text=[NSString stringWithFormat:@"%@",[pref objectForKey:PREF_USER_PHONE]];
    [self.imgUserProfile downloadFromURL:[pref objectForKey:PREF_USER_PIC] withPlaceholder:nil];
    
    RBRatings rate=([[pref objectForKey:PREF_USER_RATING]floatValue]*2);
    [self.ratingView setRatings:rate];
    
    [mapView_ clear];
    
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    CLLocationCoordinate2D currentOwner;
    currentOwner.latitude=[strowner_lati doubleValue];
    currentOwner.longitude=[strowner_longi doubleValue];
    
    
    ownerMarker = [[GMSMarker alloc] init];
    ownerMarker.position = currentOwner;
    ownerMarker.icon = [UIImage imageNamed:@"pin_client_org"];
    ownerMarker.title = [self getAddressForLat:strowner_lati andLong:strowner_longi];
    ownerMarker.map = mapView_;
    
    CLLocationCoordinate2D ownerDrop;
    ownerDrop.latitude=[strDrop_lati doubleValue];
    ownerDrop.longitude=[strDrop_longi doubleValue];
    
    dropMarker = [[GMSMarker alloc] init];
    dropMarker.position = ownerDrop;
    //dropMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    dropMarker.title = [self getAddressForLat:strDrop_lati andLong:strDrop_longi];
    dropMarker.map = mapView_;
    
    
    NSString *respondTime=[pref objectForKey:PREF_TIME_TO_RESPOND];
    time=[respondTime intValue];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.progtime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(customProgressBar) userInfo:nil repeats:YES];
    [runloop addTimer:self.progtime forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.progtime forMode:UITrackingRunLoopMode];
    
    [self show];
}

-(void) gotPushForCancelReq {
    
    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:PREF_IS_CANCEL_REQ_PUSH];
    
    self.navigationItem.hidesBackButton=YES;
    
    [self.time invalidate];
    [self.progtime invalidate];
    
    [mapView_ clear];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.time = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
    [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    [[AppDelegate sharedAppDelegate]showToastMessage:@"Previous Request has been Cancelled"];
    
    [self hide];
}

-(void)viewDidDisappear:(BOOL)animated {
    [self.mapView_ clear];
    // [self.mapView removeAnnotations:self.mapView.annotations];
}

-(void)showUserLoc
{
    if ([CLLocationManager locationServicesEnabled])
    {
        //        MKCoordinateRegion region;
        //        region.center.latitude     = [struser_lati doubleValue];
        //        region.center.longitude    = [struser_longi doubleValue];
        //        region.span.latitudeDelta = 1.5;
        //        region.span.longitudeDelta = 1.5;
        
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude=[struser_lati doubleValue];
        coordinate.longitude=[struser_longi doubleValue];
        
        
        /*
         GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
         longitude:coordinate.longitude
         zoom:10];
         [self.mapView_ animateToCameraPosition:[GMSCameraPosition
         cameraWithLatitude:coordinate.latitude
         longitude:coordinate.longitude
         zoom:10]];
         
         */
        
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:14];
        
        [mapView_ animateWithCameraUpdate:updatedCamera];
        
        //mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,65,320,505) camera:camera];
        
        //[mapView_ setCamera:camera];
        //[self.mapView_ setRegion:region animated:YES];
    }
    else {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- Custom Font

-(void)customFont {
    btnAccept=[APPDELEGATE setBoldFontDiscriptor:btnAccept];
    btnReject=[APPDELEGATE setBoldFontDiscriptor:btnReject];
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    self.lblName.font=[UberStyleGuide fontRegular];
    self.lblTime.font=[UberStyleGuide fontRegular:48.0f];
}


#pragma mark-
#pragma mark- Profile View Hide/Show Method

-(void)hide {
    self.lblTime.hidden=YES;
    self.lblWhite.hidden=YES;
    self.imgTimeBg.hidden=YES;
    [ProfileView setHidden:YES];
    [btnAccept setHidden:YES];
    [btnReject setHidden:YES];
}

-(void)show {
    self.lblTime.hidden=NO;
    self.lblWhite.hidden=NO;
    self.imgTimeBg.hidden=NO;
    [ProfileView setHidden:NO];
    [btnAccept setHidden:NO];
    [btnReject setHidden:NO];
}

#pragma mark-
#pragma mark- If-Else Methods

-(void)getRequestId {
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    strRequsetId = [pref objectForKey:PREF_REQUEST_ID];
    
    if (strRequsetId!=nil) {
        [self checkRequest];
    }
    else {
        [self requsetProgress];
    }
}

-(void)getRequestIdSecond {
    if (strRequsetId!=nil) {
        [self checkRequest];
    }
    else {
        flag=YES;
        [self getAllRequests];
    }
}

-(void)requestThird {
    //    if(strRequsetId!=nil) {
    //        [self respondToRequestfor:@"1"];
    //    }
    //    else {
    flag=NO;
    [self getAllRequests];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.time = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
    [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
    self.navigationItem.hidesBackButton=YES;
    //    }
}

#pragma mark-
#pragma mark- API Methods

-(void)checkRequest
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_GET_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error) {
            
            //NSLog(@"Check Request= %@",response);
            if (response)
            {
                if([[response valueForKey:@"success"] boolValue]==TRUE)
                {
                    NSMutableDictionary *dictRequest=[response valueForKey:@"request"];
                    
                    is_completed=[[dictRequest valueForKey:@"is_completed"]intValue];
                    is_dog_rated=[[dictRequest valueForKey:@"is_dog_rated"]intValue];
                    is_started=[[dictRequest valueForKey:@"is_started" ]intValue];
                    is_walker_arrived=[[dictRequest valueForKey:@"is_walker_arrived"]intValue];
                    is_walker_started=[[dictRequest valueForKey:@"is_walker_started"]intValue];
                    
                    dictOwner=[dictRequest valueForKey:@"owner"];;//[arrOwner objectAtIndex:0];
                    strowner_lati=[dictOwner valueForKey:@"latitude"];
                    strowner_longi=[dictOwner valueForKey:@"longitude"];
                    
                    strDrop_lati = [dictOwner valueForKey:@"d_latitude"];
                    strDrop_longi = [dictOwner valueForKey:@"d_longitude"];
                    
                    NSString *gmtDateString = [dictRequest valueForKey:@"start_time"];
                    NSDateFormatter *df = [NSDateFormatter new];
                    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
                    NSDate *datee = [df dateFromString:gmtDateString];
                    df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
                    
                    NSString *startTime=[NSString stringWithFormat:@"%f",[datee timeIntervalSince1970] * 1000];
                    
                    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                    [pref setObject:startTime forKey:PREF_START_TIME];
                    [pref synchronize];
                    
                    [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
                    [pref setObject:[dictOwner valueForKey:@"num_rating"] forKey:PREF_USER_RATING];
                    [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
                    [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PICTURE];
                    [pref synchronize];
                    
                    [mapView_ clear];
                    [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
                }
                else {
                    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                    [pref removeObjectForKey:PREF_REQUEST_ID];
                    [self getRequestId];
                }
            }
            //            else
            //            {
            //                [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
            //            }
            
        }];
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}


-(void)requsetProgress
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_PROGRESS withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             //NSLog(@"Request in Progress= %@",response);
             
             if (response)
             {
                 if([[response valueForKey:@"success"]intValue]==1)
                 {
                     
                     if ([[response valueForKey:@"request_id"] intValue]!=-1)
                     {
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref setObject:[response valueForKey:@"request_id"] forKey:PREF_REQUEST_ID];
                         [pref synchronize];
                         strRequsetId=[response valueForKey:@"request_id"];
                     }
                     
                     [self getRequestIdSecond];
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

-(void)getAllRequests
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:PREF_IS_NEW_REQ_PUSH]) {
            [self gotPushForNewReq];
        }
        else {
            [self getAPIforNewReq];
        }
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getAPIforNewReq {
    
    NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
    [dictparam setObject:strUserId forKey:PARAM_ID];
    [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
    
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:FILE_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
     {
         //NSLog(@"Get All API Request= %@",response);
         
         if (response)
         {
             [APPDELEGATE hideLoadingView];
             
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 NSMutableArray *arrRespone=[response valueForKey:@"incoming_requests"];
                 if(arrRespone.count!=0)
                 {
                     [self.time invalidate];
                     [self.progtime invalidate];
                     
                     NSMutableDictionary *dictRequestData=[arrRespone valueForKey:@"request_data"];
                     NSMutableArray *arrOwner=[dictRequestData valueForKey:@"owner"];
                     dictOwner=[arrOwner objectAtIndex:0];
                     
                     NSMutableArray *arrRequest_Id=[arrRespone valueForKey:@"request_id"];
                     strRequsetId=[NSMutableString stringWithFormat:@"%@",[arrRequest_Id objectAtIndex:0]];
                     
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     [pref setObject:strRequsetId forKey:PREF_REQUEST_ID];
                     [pref synchronize];
                     
                     lblName.text=[dictOwner valueForKey:@"name"];
                     lblRate.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"rating"]];
                     lblDetails.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
                     [self.imgUserProfile downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
                     
                     strowner_lati=[dictOwner valueForKey:@"latitude"];
                     strowner_longi=[dictOwner valueForKey:@"longitude"];
                     
                     strDrop_lati = [dictOwner valueForKey:@"d_latitude"];
                     strDrop_longi = [dictOwner valueForKey:@"d_longitude"];
                     
                     RBRatings rate=([[dictOwner valueForKey:@"rating"]floatValue]*2);
                     [self.ratingView setRatings:rate];
                     
                     [mapView_ clear];
                     
                     
                     CLLocationCoordinate2D current;
                     current.latitude=[struser_lati doubleValue];
                     current.longitude=[struser_longi doubleValue];
                     
                     marker = [[GMSMarker alloc] init];
                     marker.position = current;
                     marker.icon = [UIImage imageNamed:@"pin_driver"];
                     marker.map = mapView_;
                     
                     CLLocationCoordinate2D currentOwner;
                     currentOwner.latitude=[strowner_lati doubleValue];
                     currentOwner.longitude=[strowner_longi doubleValue];
                     
                     
                     ownerMarker = [[GMSMarker alloc] init];
                     ownerMarker.position = currentOwner;
                     ownerMarker.icon = [UIImage imageNamed:@"pin_client_org"];
                     ownerMarker.title = [self getAddressForLat:strowner_lati andLong:strowner_longi];
                     ownerMarker.map = mapView_;
                     
                     CLLocationCoordinate2D ownerDrop;
                     ownerDrop.latitude=[strDrop_lati doubleValue];
                     ownerDrop.longitude=[strDrop_longi doubleValue];
                     
                     dropMarker = [[GMSMarker alloc] init];
                     dropMarker.position = ownerDrop;
                     //dropMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
                     dropMarker.title = [self getAddressForLat:strDrop_lati andLong:strDrop_longi];
                     dropMarker.map = mapView_;
                     
                     
                     NSMutableArray *arrTime=[arrRespone valueForKey:@"time_left_to_respond"];
                     time=[[arrTime objectAtIndex:0]intValue];
                     
                     
                     NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                     self.progtime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(customProgressBar) userInfo:nil repeats:YES];
                     [runloop addTimer:self.progtime forMode:NSRunLoopCommonModes];
                     [runloop addTimer:self.progtime forMode:UITrackingRunLoopMode];
                     
                     [self show];
                 }
                 
                 else if (flag==YES) {
                     [self requestThird];
                 }
             }
         }
         else
         {
             [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
         }
         
     }];
}

-(NSString *) getAddressForLat:(NSString *)latitude andLong:(NSString *)longitude {
    
    NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=false",[latitude floatValue], [longitude floatValue], [latitude floatValue], [longitude floatValue]];
    
    NSString *str = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: nil];
    
    NSDictionary *getRoutes = [JSON valueForKey:@"routes"];
    NSDictionary *getLegs = [getRoutes valueForKey:@"legs"];
    NSArray *getAddress = [getLegs valueForKey:@"end_address"];
    NSString *currentAdd;
    if (getAddress.count!=0)
    {
        currentAdd=[[getAddress objectAtIndex:0]objectAtIndex:0];
    }
    return currentAdd;
}

-(void)updateLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([[AppDelegate sharedAppDelegate]connected])
        {
            
            if(((struser_lati==nil)&&(struser_longi==nil))
               ||(([struser_longi doubleValue]==0.00)&&([struser_lati doubleValue]==0)))
            {
            }
            else
            {
                NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
                [dictparam setObject:strUserId forKey:PARAM_ID];
                [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
                [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
                [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
                
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_USERLOCATION withParamData:dictparam withBlock:^(id response, NSError *error)
                 {
                     
                     //NSLog(@"Update Location = %@",response);
                     if (response)
                     {
                         if([[response valueForKey:@"success"] intValue]==1)
                         {
                             
                         }
                     }
                     
                 }];
                
            }
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
}

-(void)respondToRequestfor:(NSString *)acceptedVal
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
        strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
        
        if (strRequsetId!=nil)
        {
            NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
            
            [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
            [dictparam setObject:strUserId forKey:PARAM_ID];
            [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
            [dictparam setObject:acceptedVal forKey:PARAM_ACCEPTED];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
             {
                 
                 //NSLog(@"Respond to Request= %@",response);
                 [APPDELEGATE hideLoadingView];
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1 && [acceptedVal isEqualToString:@"0"]) {
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_REJECTED", nil)];
                         
                         //NSLog(@"Req Rejected");
                     }
                     else if ([[response valueForKey:@"success"] intValue]==0 && [acceptedVal isEqualToString:@"1"]) {
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         [pref removeObjectForKey:PREF_REQUEST_ID];
                         
                         [self getRequestId];
                     }
                     else {
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_ACCEPTED", nil)];
                         //                         if ([[pref objectForKey:PREF_LATER] isEqualToString:@"0"]) {
                         NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                         
                         [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
                         [pref setObject:[dictOwner valueForKey:@"rating"] forKey:PREF_USER_RATING];
                         [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
                         [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PICTURE];
                         [pref synchronize];
                         
                         
                         lblName.text=[dictOwner valueForKey:@"name"];
                         lblRate.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"rating"]];
                         lblDetails.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
                         [self.imgUserProfile downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
                         
                         [self.time invalidate];
                         [self.progtime invalidate];
                         
                         [self hide];
                         
                         [mapView_ clear];
                         [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
                         
                     }
                 }
                 
             }];
        }
        else
        {
            
        }
    }
    else
    {
        [APPDELEGATE hideLoadingView];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

/*
 -(void)respondToRequset
 {
 if(internet)
 {
 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
 strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
 
 if (strRequsetId!=nil)
 {
 NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
 
 [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
 [dictparam setObject:strUserId forKey:PARAM_ID];
 [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
 [dictparam setObject:@"1" forKey:PARAM_ACCEPTED];
 
 AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
 [afn getDataFromPath:FILE_RESPOND_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
 {
 
 //NSLog(@"Respond to Request= %@",response);
 [APPDELEGATE hideLoadingView];
 if (response)
 {
 if([[response valueForKey:@"success"] intValue]==1)
 {
 [APPDELEGATE showToastMessage:NSLocalizedString(@"REQUEST_ACCEPTED", nil)];
 NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
 
 [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
 [pref setObject:[dictOwner valueForKey:@"rating"] forKey:PREF_USER_RATING];
 [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
 [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PICTURE];
 [pref synchronize];
 
 
 lblName.text=[dictOwner valueForKey:@"name"];
 lblRate.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"rating"]];
 lblDetails.text=[NSString stringWithFormat:@"%@",[dictOwner valueForKey:@"phone"]];
 [self.imgUserProfile downloadFromURL:[dictOwner valueForKey:@"picture"] withPlaceholder:nil];
 
 [self.time invalidate];
 [self hide];
 
 [mapView_ clear];
 [self performSegueWithIdentifier:@"segurtoarrived" sender:self];
 }
 }
 
 }];
 }
 else
 {
 
 }
 }
 else
 {
 UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
 [alert show];
 }
 }
 */

-(void)getPagesData
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@",FILE_PAGES,PARAM_ID,strUserId];
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
         {
             
             //NSLog(@"Page Data= %@",response);
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     arrPage=[response valueForKey:@"informations"];
                 }
             }
             
         }];
        
        
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
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

#pragma mark -
#pragma mark - Draw Route Methods

- (NSMutableArray *)decodePolyLine: (NSMutableString *)encoded
{
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\" options:NSLiteralSearch range:NSMakeRange(0, [encoded length])];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len)
    {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do
        {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        //printf("[%f,", [latitude doubleValue]);
        //printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    //NSLog(@"api url: %@", apiUrl);
    NSError* error = nil;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSASCIIStringEncoding error:&error];
    NSString *encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap
{
    MKCoordinateRegion region;
    CLLocationDegrees maxLat = -90.0;
    CLLocationDegrees maxLon = -180.0;
    CLLocationDegrees minLat = 90.0;
    CLLocationDegrees minLon = 180.0;
    for(int idx = 0; idx < routes.count; idx++)
    {
        CLLocation* currentLocation = [routes objectAtIndex:idx];
        if(currentLocation.coordinate.latitude > maxLat)
            maxLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.latitude < minLat)
            minLat = currentLocation.coordinate.latitude;
        if(currentLocation.coordinate.longitude > maxLon)
            maxLon = currentLocation.coordinate.longitude;
        if(currentLocation.coordinate.longitude < minLon)
            minLon = currentLocation.coordinate.longitude;
    }
    region.center.latitude     = (maxLat + minLat) / 2.0;
    region.center.longitude    = (maxLon + minLon) / 2.0;
    
    
    
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
    
    region.span.latitudeDelta = 1.5;
    region.span.longitudeDelta = 1.5;
    
    //[self.mapView setRegion:region animated:YES];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=region.center.latitude;
    coordinate.longitude=region.center.longitude;
    
    //GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
    // longitude:coordinate.longitude
    //    zoom:6];
    //mapView_ = [GMSMapView mapWithFrame:CGRectMake(0,65,320,505) camera:camera];
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:coordinate zoom:14];
    
    [mapView_ animateWithCameraUpdate:updatedCamera];
}




//-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t
-(void) showRouteFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t

{
    if(routes)
    {
        //[self.mapView removeAnnotations:[self.mapView annotations]];
        [mapView_ clear];
    }
    
    
    //[self.mapView addAnnotation:f];
    //[self.mapView addAnnotation:t];
    GMSMarker *markerOwner = [[GMSMarker alloc] init];
    markerOwner.position = f;
    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
    markerOwner.map = mapView_;
    
    marker = [[GMSMarker alloc] init];
    marker.position = f;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    routes = [self calculateRoutesFrom:f to:t];
    NSInteger numberOfSteps = routes.count;
    
    
    GMSMutablePath *pathpoliline=[GMSMutablePath path];
    
    CLLocationCoordinate2D coordinates[numberOfSteps];
    for (NSInteger index = 0; index < numberOfSteps; index++)
    {
        CLLocation *location = [routes objectAtIndex:index];
        CLLocationCoordinate2D coordinate = location.coordinate;
        coordinates[index] = coordinate;
        [pathpoliline addCoordinate:coordinate];
    }
    //MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
    
    
    
    GMSPolyline *polyLinePath = [GMSPolyline polylineWithPath:pathpoliline];
    
    polyLinePath.strokeColor = [UIColor blueColor];
    polyLinePath.strokeWidth = 5.f;
    polyLinePath.map = mapView_;
    [self centerMap];
}




#pragma mark-
#pragma mark MKPolyline delegate functions

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor blueColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
}

#pragma mark-
#pragma mark- MapView delegate
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    
    MKAnnotationView *annot=[[MKAnnotationView alloc] init];
    
    SBMapAnnotation *temp=(SBMapAnnotation*)annotation;
    if (temp.yTag==1000)
    {
        annot.image=[UIImage imageNamed:@"pin_driver"];
    }
    if (temp.yTag==1001)
    {
        annot.image=[UIImage imageNamed:@"pin_client_org"];
        
    }
    
    return annot;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

#pragma mark-
#pragma mark- Get Location

-(void)getUserLocation
{
    //    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[locationManager requestWhenInUseAuthorization];
        [locationManager requestAlwaysAuthorization];
    }
#endif
    
    [locationManager startUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError: %@", error);
    
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        struser_lati=[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.latitude];//[NSString stringWithFormat:@"%.8f",+37.40618700];
        struser_longi=[NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude];//[NSString stringWithFormat:@"%.8f",-122.18845228];
    }
    
    //[self.mapView removeAnnotations:self.mapView.annotations];
    marker.map = nil;
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    /*
     SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
     curLoc.yTag=1000;
     [self.mapView addAnnotation:curLoc];
     */
    
    
    
    mapView_.myLocationEnabled = NO;
    //[self.viewForMap addSubview:mapView_];
    mapView_.delegate=self;
    // Creates a marker in the center of the map.
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    //marker.title = @"Current Location";
    //marker.snippet = @"Australia";
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    
    
}

#pragma mark-
#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}



#pragma mark-
#pragma mark- Button Click Events


- (IBAction)onClickSetEta:(id)sender
{
    
    
}

- (IBAction)onClickReject:(id)sender
{
    self.navigationItem.hidesBackButton=YES;
    [self respondToRequestfor:@"0"];
    
    [self.time invalidate];
    [self.progtime invalidate];
    
    [mapView_ clear];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.time = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
    [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    [self hide];
}

- (IBAction)onClickAccept:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"WAITING_ADMIN_APPROVE", nil)];
    [self respondToRequestfor:@"1"];
    
    [mapView_ clear];
}

- (IBAction)onClickNoKey:(id)sender
{
    [self.etaView setHidden:YES];
}

- (IBAction)pickMeBtnPressed:(id)sender
{
    [self showUserLoc];
}


-(void)goToSetting:(NSString *)str
{
    [self performSegueWithIdentifier:str sender:self];
}



#pragma mark-
#pragma mark- Progress Bar Method


-(void)customProgressBar {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:PREF_IS_CANCEL_REQ_PUSH]) {
        [self gotPushForCancelReq];
    }
    
    progressView.hidden=YES;
    float t=(time/60.0f);
    self.lblTime.text=[NSString stringWithFormat:@"%d",time];
    
    if(time<5) {
        progressView.color = [UIColor colorWithRed:245.0f/255.0f green:25.0f/255.0f blue:42.0f/255.0f alpha:1.0];
    }
    else {
        progressView.color = [UIColor colorWithRed:0.0f/255.0f green:186.0f/255.0f blue:214.0f/255.0f alpha:1.0];
    }
    
    progressView.background = [UIColor colorWithRed:122.0f/255.0f green:122.0f/255.0f blue:122.0f/255.0f alpha:1.0];
    progressView.showText = @NO;
    progressView.progress = t;
    progressView.borderRadius = @NO;
    progressView.animate = @NO;
    progressView.type = LDProgressSolid;
    time=time-1;
    
    if(time<=0) {
        [self.progtime invalidate];
        [self.time invalidate];
        
        [mapView_ clear];
        
        CLLocationCoordinate2D current;
        current.latitude=[struser_lati doubleValue];
        current.longitude=[struser_longi doubleValue];
        
        marker = [[GMSMarker alloc] init];
        marker.position = current;
        marker.icon = [UIImage imageNamed:@"pin_driver"];
        marker.map = mapView_;
        
        [self hide];
        
        NSRunLoop *runloop = [NSRunLoop currentRunLoop];
        self.time = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(getAllRequests) userInfo:nil repeats:YES];
        [runloop addTimer:self.time forMode:NSRunLoopCommonModes];
        [runloop addTimer:self.time forMode:UITrackingRunLoopMode];
    }
}

#pragma mark-
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.time invalidate];
    [self.progtime invalidate];
    
    if([segue.identifier isEqualToString:@"contact us"])
    {
        ContactVC *obj=[segue destinationViewController];
        obj.dictContact=sender;
    }
    
}


@end
