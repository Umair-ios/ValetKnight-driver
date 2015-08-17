//
//  ArrivedMapVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "ArrivedMapVC.h"
#import "RegexKitLite.h"
#import <MapKit/MapKit.h>
#import "sbMapAnnotation.h"
#import "UIImageView+Download.h"
#import "PickMeUpMapVC.h"
#import "RatingBar.h"
#import "UIView+Utils.h"
#import "FeedBackVC.h"

@interface ArrivedMapVC ()
{
    CLLocationManager *locationManager;
    
    NSMutableString *strUserId;
    NSMutableString *strUserToken;
    NSMutableString *strRequsetId;
    NSString *startTime;
    NSString *endTime;
    BOOL flag,isTo;
    int time;
    float totalDist;
    
    NSMutableString *strOwnerName;
    NSMutableString *strOwnerPhone;
    NSMutableString *strOwnerRate;
    NSMutableString *strOwnerPicture;
    
    CLLocation *locA,*locB, *walkOldLocation;
    NSString * strStart_lati;
    NSString * strStart_longi;
    NSMutableArray *arrPath;
    
    GMSMutablePath *pathUpdates;
    
}

@end

@implementation ArrivedMapVC

@synthesize btnArrived,btnJob,btnWalk,btnWalker,btnTime,pickMeUp;

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
    
    [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
    [self.imgProfile applyRoundedCornersFullWithColor:[UIColor whiteColor]];
    
    [btnWalker setHidden:NO];
    [btnWalk setHidden:YES];
    [btnJob setHidden:YES];
    [btnArrived setHidden:YES];
    
    CLLocationCoordinate2D current;
    current.latitude=[struser_lati doubleValue];
    current.longitude=[struser_longi doubleValue];
    
    /*
     SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
     curLoc.yTag=1001;
     
     [self.mapView addAnnotation:curLoc];
     */
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:current.latitude
                                                            longitude:current.longitude
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:self.mapView_.bounds camera:camera];
    mapView_.myLocationEnabled = NO;
    [self.mapView_ addSubview:mapView_];
    mapView_.delegate=self;
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = current;
    marker.icon = [UIImage imageNamed:@"pin_driver"];
    marker.map = mapView_;
    
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(showUserLoc) userInfo:nil repeats:NO];
    
    
    isTo=NO;
    
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
    
    GMSMarker *dropMarker = [[GMSMarker alloc] init];
    dropMarker.position = ownerDrop;
    //dropMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    dropMarker.title = [self getAddressForLat:strDrop_lati andLong:strDrop_longi];
    dropMarker.map = mapView_;
    
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref synchronize];
    strOwnerName=[pref objectForKey:PREF_USER_NAME];
    strOwnerPhone=[pref objectForKey:PREF_USER_PHONE];
    strOwnerRate=[pref objectForKey:PREF_USER_RATING];
    strOwnerPicture=[pref objectForKey:PREF_USER_PICTURE];
    strUserId=[pref objectForKey:PREF_USER_ID];
    strUserToken=[pref objectForKey:PREF_USER_TOKEN];
    strRequsetId=[pref objectForKey:PREF_REQUEST_ID];
    
    
    
    self.lblUserName.text=strOwnerName;
    self.lblUserPhone.text=strOwnerPhone;
    self.lblUserRate.text=[NSString stringWithFormat:@"%.1f",[strOwnerRate floatValue]];;
    [self.imgProfile downloadFromURL:strOwnerPicture withPlaceholder:nil];
    
    [self.ratingView initRateBar];
    [self.ratingView setRatings:([strOwnerRate floatValue]*2)];
    [self.ratingView setUserInteractionEnabled:NO];
    
    [self.btnDistance setTitle:@"0" forState:UIControlStateNormal];
    [self.btnTime setTitle:@"0 Min" forState:UIControlStateNormal];
    [self checkRequest];
    [self customFont];
    
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    totalDist=0;
    //  Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    walkOldLocation =[[CLLocation alloc]initWithLatitude:0.0000000 longitude:0.00000];
    [self checkRequestStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark-

-(void)customFont
{
    btnWalker=[APPDELEGATE setBoldFontDiscriptor:btnWalker];
    btnArrived=[APPDELEGATE setBoldFontDiscriptor:btnArrived];
    btnWalk=[APPDELEGATE setBoldFontDiscriptor:btnWalk];
    btnJob=[APPDELEGATE setBoldFontDiscriptor:btnJob];
    self.btnCall.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnDistance.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnTime.titleLabel.font=[UberStyleGuide fontRegular];
    self.btnMenu.titleLabel.font=[UberStyleGuide fontRegular];
    self.lblUserName.font=[UberStyleGuide fontRegular];
    self.btnCall.titleLabel.textColor=[UberStyleGuide colorDefault];
}


#pragma mark-
#pragma mark- User Location


-(void)showUserLoc
{
    MKCoordinateRegion region;
    region.center.latitude     = [struser_lati doubleValue];
    region.center.longitude    = [struser_longi doubleValue];
    region.span.latitudeDelta = 1.5;
    region.span.longitudeDelta = 1.5;
    
    //[self.mapView setRegion:region animated:YES];
}

#pragma mark-
#pragma mark- Check request Status


-(void)checkRequest
{
    if(is_walker_started==1)
    {
        if (is_walker_arrived==1)
        {
            if (is_started==1)
            {
                if (is_completed==1)
                {
                    if (is_dog_rated==1)
                    {
                        
                    }
                    else
                    {
                        [self performSegueWithIdentifier:@"jobToFeedback" sender:self];
                    }
                }
                else
                {
                    
                    [btnWalker setHidden:YES];
                    [btnArrived setHidden:YES];
                    [btnWalk setHidden:YES];
                    [btnJob setHidden:NO];
                    
                    arrPath=[[NSMutableArray alloc]init];
                    [self requestPath];
                    [self.pickMeUp.timer invalidate];
                    self.pickMeUp.timer=nil;
                    
                    
                    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                    [pref synchronize];
                    startTime=[pref objectForKey:PREF_START_TIME];
                    [self updateTime];
                    
                    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                    self.timeForUpdateWalkLoc = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateWalkLocation) userInfo:nil repeats:YES];
                    [runloop addTimer:self.timeForUpdateWalkLoc forMode:NSRunLoopCommonModes];
                    [runloop addTimer:self.timeForUpdateWalkLoc forMode:UITrackingRunLoopMode];
                    
                    NSRunLoop *runloop1 = [NSRunLoop currentRunLoop];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                    [runloop1 addTimer:self.timer forMode:NSRunLoopCommonModes];
                    [runloop1 addTimer:self.timer forMode:UITrackingRunLoopMode];
                    
                    [self getUserLocation];
                    
                }
            }
            else
            {
                [btnWalker setHidden:YES];
                [btnArrived setHidden:YES];
                [btnWalk setHidden:NO];
            }
        }
        else
        {
            [btnWalker setHidden:YES];
            [btnArrived setHidden:NO];
        }
    }
}
#pragma mark-
#pragma mark- API Method

#pragma mark-
#pragma mark- API Methods

-(void)checkRequestStatus
{
    if([APPDELEGATE connected])
    {
        NSMutableDictionary *dictparam=[[NSMutableDictionary alloc]init];
        
        [dictparam setObject:strUserId forKey:PARAM_ID];
        [dictparam setObject:strUserToken forKey:PARAM_TOKEN];
        [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_GET_REQUEST withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             //NSLog(@"Check Request= %@",response);
             if (response) {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     NSMutableDictionary *dictRequest=[response valueForKey:@"request"];
                     
                     is_completed=[[dictRequest valueForKey:@"is_completed"]intValue];
                     is_dog_rated=[[dictRequest valueForKey:@"is_dog_rated"]intValue];
                     is_started=[[dictRequest valueForKey:@"is_started" ]intValue];
                     is_walker_arrived=[[dictRequest valueForKey:@"is_walker_arrived"]intValue];
                     is_walker_started=[[dictRequest valueForKey:@"is_walker_started"]intValue];
                     // [self respondToRequset];
                     if (is_completed==0)
                     {
                         totalDist=[[dictRequest valueForKey:@"distance"]floatValue];
                         if ([dictRequest valueForKey:@"unit"]==nil)
                         {
                             self.btnDistance.titleLabel.text=[dictRequest valueForKey:@"distance"];
                         }
                         else
                         {
                             [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[dictRequest valueForKey:@"distance"] floatValue],[dictRequest valueForKey:@"unit"]] forState:UIControlStateNormal];
                         }
                     }
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


-(void)walkerStarted
{
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
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WLKER_STARTED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     [btnWalker setHidden:YES];
                     [btnArrived setHidden:NO];
                 }
             }
             else
             {
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
             
         }];
    }
}



-(void)arrivedRequest
{
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
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WLKER_ARRIVED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     [btnArrived setHidden:YES];
                     [btnWalk setHidden:NO];
                     //[APPDELEGATE showToastMessage:NSLocalizedString(@"WALKER_ARRIVED", nil)];
                 }
             }
             else
             {
                 [APPDELEGATE hideLoadingView];
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
             
         }];
    }
}

-(void)walkStarted
{
    pathUpdates = [GMSMutablePath path];
    pathUpdates = [[GMSMutablePath alloc]init];
    
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
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WALK_STARTED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             [APPDELEGATE hideLoadingView];
             if (response)
             {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     ownerMarker.map = nil;
                     
                     [self.pickMeUp.timer invalidate];
                     self.pickMeUp.timer=nil;
                     
                     NSRunLoop *runloop = [NSRunLoop currentRunLoop];
                     self.timeForUpdateWalkLoc = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateWalkLocation) userInfo:nil repeats:YES];
                     [runloop addTimer:self.timeForUpdateWalkLoc forMode:NSRunLoopCommonModes];
                     [runloop addTimer:self.timeForUpdateWalkLoc forMode:UITrackingRunLoopMode];
                     [self getUserLocation];
                     [btnWalk setHidden:YES];
                     [btnJob setHidden:NO];
                     //strStart_lati=struser_lati;
                     // strStart_longi=struser_longi;
                     //[APPDELEGATE showToastMessage:NSLocalizedString(@"WALK_STARTED", nil)];
                 }
             }
             else
             {
                 [APPDELEGATE hideLoadingView];
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
         }];
    }
}

-(void)jobDone
{
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
        [dictparam setObject:struser_lati forKey:PARAM_LATITUDE];
        [dictparam setObject:struser_longi forKey:PARAM_LONGITUDE];
        [dictparam setObject:[NSString stringWithFormat:@"%.2f",totalDist] forKey:PARAM_DISTANCE];
        [dictparam setObject:[NSString stringWithFormat:@"%d",time] forKey:PARAM_TIME];
        
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
        [afn getDataFromPath:FILE_WALK_COMPLETED withParamData:dictparam withBlock:^(id response, NSError *error)
         {
             if (response) {
                 
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     //NSLog(@"JOB DONE - %@",response);
                     NSString *distance= self.btnDistance.titleLabel.text;
                     NSArray *arrDistace=[distance componentsSeparatedByString:@" "];
                     float dist;
                     if (arrDistace.count!=0)
                     {
                         
                         dist=[[arrDistace objectAtIndex:0]floatValue];
                         if (arrDistace.count>1)
                         {
                             if ([[arrDistace objectAtIndex:1] isEqualToString:@"kms"])
                             {
                                 dist=dist*0.621371;
                                 
                             }
                         }
                     }
                     NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
                     [pref setObject:[NSString stringWithFormat:@"%.2f",dist] forKey:PREF_WALK_DISTANCE];
                     [pref setObject:[NSString stringWithFormat:@"%d",time] forKey:PREF_WALK_TIME];
                     [pref synchronize];
                     
                     [self.timeForUpdateWalkLoc invalidate];
                     
                     [pref setObject:[response valueForKey:@"bill"] forKey:@"billDetails"];
                     [self performSegueWithIdentifier:@"jobToFeedback" sender:[response valueForKey:@"bill"]];
                 }
             }
             else {
                 [APPDELEGATE hideLoadingView];
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
             
         }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [APPDELEGATE hideLoadingView];
    
    if([segue.identifier isEqualToString:@"jobToFeedback"]) {
        FeedBackVC *obj=[segue destinationViewController];
        obj.dictWalkInfo=sender;
    }
}

-(void)updateWalkLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([APPDELEGATE connected])
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
                [dictparam setObject:strRequsetId forKey:PARAM_REQUEST_ID];
                [dictparam setObject:@"0" forKey:PARAM_DISTANCE];
                AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
                [afn getDataFromPath:FILE_WALK_LOCATION withParamData:dictparam withBlock:^(id response, NSError *error)
                 {
                     
                     //NSLog(@"Update Walk Location = %@",response);
                     if (response)
                     {
                         if([[response valueForKey:@"success"] intValue]==1)
                         {
                             totalDist=[[response valueForKey:@"distance"]floatValue];
                             [self.btnDistance setTitle:[NSString stringWithFormat:@"%.2f %@",[[response valueForKey:@"distance"] floatValue],[response valueForKey:@"unit"]] forState:UIControlStateNormal];
                         }
                     }
                     else
                     {
                         [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
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

-(void)requestPath
{
    NSMutableString *pageUrl=[NSMutableString stringWithFormat:@"%@?%@=%@&%@=%@&%@=%@",FILE_REQUEST_PATH,PARAM_ID,strUserId,PARAM_TOKEN,strUserToken,PARAM_REQUEST_ID,strRequsetId];
    AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
    [afn getDataFromPath:pageUrl withParamData:nil withBlock:^(id response, NSError *error)
     {
         
         //NSLog(@"Page Data= %@",response);
         if (response)
         {
             if([[response valueForKey:@"success"] intValue]==1)
             {
                 [arrPath removeAllObjects];
                 arrPath=[response valueForKey:@"locationdata"];
                 [self drawPath];
             }
         }
         else
         {
             [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
         }
         
     }];
}

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
    region.span.latitudeDelta = 0.01;
    region.span.longitudeDelta = 0.01;
    
    region.span.latitudeDelta  = ((maxLat - minLat)<0.0)?100.0:(maxLat - minLat);
    region.span.longitudeDelta = ((maxLon - minLon)<0.0)?100.0:(maxLon - minLon);
    //[self.mapView setRegion:region animated:YES];
    
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude=region.center.latitude;
    coordinate.longitude=region.center.longitude;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:14];
    mapView_ = [GMSMapView mapWithFrame:mapView_.bounds camera:camera];
}




//-(void) showRouteFrom:(id < MKAnnotation>)f to:(id < MKAnnotation>  )t


-(void) showRouteFrom:(CLLocationCoordinate2D)f to:(CLLocationCoordinate2D)t
{
    if(routes)
    {
        //[self.mapView removeAnnotations:[self.mapView annotations]];
        [self.mapView_ clear];
    }
    
    
    //[self.mapView addAnnotation:f];
    //[self.mapView addAnnotation:t];
    GMSMarker *markerOwner = [[GMSMarker alloc] init];
    markerOwner.position = f;
    markerOwner.icon = [UIImage imageNamed:@"pin_client_org"];
    markerOwner.map = mapView_;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
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

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    
    MKAnnotationView *annot=[[MKAnnotationView alloc] init];
    
    SBMapAnnotation *temp=(SBMapAnnotation*)annotation;
    if (temp.yTag==1001)
    {
        annot.image=[UIImage imageNamed:@"pin_driver"];
    }
    if (temp.yTag==1000)
    {
        annot.image=[UIImage imageNamed:@"pin_client_org"];
    }
    //    if (isTo)
    //    {
    //
    //
    //    }
    //    else
    //    {
    //        isTo=YES;
    //        annot.image=[UIImage imageNamed:@"pin_driver.png"];
    //    }
    return annot;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    
}

#pragma mark-
#pragma mark- DrawPath Method

-(void)drawPath
{
    NSMutableDictionary *dictPath=[[NSMutableDictionary alloc]init];
    NSString *templati,*templongi;
    
    //NSMutableArray *paths=[[NSMutableArray alloc]init];
    GMSMutablePath *path = [GMSMutablePath path];
    for (int i=0; i<arrPath.count; i++)
    {
        dictPath=[arrPath objectAtIndex:i];
        templati=[dictPath valueForKey:@"latitude"];
        templongi=[dictPath valueForKey:@"longitude"];
        
        CLLocationCoordinate2D current;
        current.latitude=[templati doubleValue];
        current.longitude=[templongi doubleValue];
        CLLocation *curLoc=[[CLLocation alloc]initWithLatitude:current.latitude longitude:current.longitude];
        
        //[paths addObject:curLoc];
        [path addCoordinate:current];
        //[self updateMapLocation:curLoc];
    }
    
    
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = [UIColor blueColor];
    polyline.strokeWidth = 5.f;
    polyline.geodesic = YES;
    
    polyline.map = mapView_;
    
}


/*
 - (void)updateMapLocation:(CLLocation *)newLocation
 {
 self.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
 self.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
 
 for (MKAnnotationView *annotation in self.mapView.annotations)
 {
 if ([annotation isKindOfClass:[SBMapAnnotation class]])
 {
 SBMapAnnotation *wAnnotation = (SBMapAnnotation*)annotation;
 if(wAnnotation.yTag==1001)
 [wAnnotation setCoordinate:newLocation.coordinate];
 if (!self.crumbs)
 {
 _crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
 [self.mapView addOverlay:self.crumbs];
 
 MKCoordinateRegion region =
 MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 2000, 2000);
 [self.mapView setRegion:region animated:YES];
 }
 else{
 MKMapRect updateRect = [self.crumbs addCoordinate:newLocation.coordinate];
 
 if (!MKMapRectIsNull(updateRect))
 {
 MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
 // Find out the line width at this zoom scale and outset the updateRect by that amount
 CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
 updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
 // Ask the overlay view to update just the changed area.
 [self.crumbView setNeedsDisplayInMapRect:updateRect];
 
 // [self.mapView setVisibleMapRect:updateRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
 }
 }
 }
 }
 
 }
 */





/*
 
 #pragma mark - MapViewDelegate
 
 - (void)mapView:(MKMapView *)mapView didAddOverlayRenderers:(NSArray *)renderers {
 
 [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:UIEdgeInsetsMake(50, 50, 50, 50) animated:YES];
 
 }
 
 - (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
 {
 if (!self.crumbView)
 {
 _crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
 }
 return self.crumbView;
 }
 
 */

#pragma mark-
#pragma mark- Get Location

-(void)getUserLocation
{
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
#ifdef __IPHONE_8_0
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        // Use one or the other, not both. Depending on what you put in info.plist
        //[self.locationManager requestWhenInUseAuthorization];
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
    if (newLocation != nil) {
        if (newLocation.coordinate.latitude == oldLocation.coordinate.latitude && newLocation.coordinate.longitude == oldLocation.coordinate.longitude)
        {
            
        }
        else
        {
            if(walkOldLocation.coordinate.latitude==0.00)
            {
                walkOldLocation=[walkOldLocation initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
                
                
            }
            
            
            CLLocationDistance distance = [walkOldLocation distanceFromLocation:currentLocation];
            if (distance>=20)
            {
                walkOldLocation=[walkOldLocation initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
                [self updateWalkLocation];
                //[self updateMapLocation:newLocation];
                
                [pathUpdates addCoordinate:newLocation.coordinate];
                
                GMSPolyline *polyline = [GMSPolyline polylineWithPath:pathUpdates];
                polyline.strokeColor = [UIColor blueColor];
                polyline.strokeWidth = 5.f;
                polyline.geodesic = YES;
                
                polyline.map = mapView_;
                
                
            }
            
            
            
        }
    }
    
}

#pragma mark-
#pragma mark- Alert Button Clicked Event

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==100)
    {
        if (buttonIndex == 0)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
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

#pragma mark-
#pragma mark- Calculate Distance

/*-(float)calculateDistanceFrom:(CLLocation *)locC To:(CLLocation *)locD
 {
 CLLocationDistance distance;
 distance=[locC distanceFromLocation:locD];
 float Range=distance;
 return Range;
 }*/



-(void)walkPath
{
    if([CLLocationManager locationServicesEnabled])
    {
        CLLocationCoordinate2D current;
        current.latitude=[struser_lati doubleValue];
        current.longitude=[struser_longi doubleValue];
        
        //SBMapAnnotation *curLoc=[[SBMapAnnotation alloc]initWithCoordinate:current];
        
        CLLocationCoordinate2D currentOwner;
        currentOwner.latitude=[strowner_lati doubleValue];
        currentOwner.longitude=[strowner_longi doubleValue];
        
        //SBMapAnnotation *curLocOwn=[[SBMapAnnotation alloc]initWithCoordinate:currentOwner];
        
        [self showRouteFrom:currentOwner to:current];
        
        
        
        
    }
    else
    {
        UIAlertView *alertLocation=[[UIAlertView alloc]initWithTitle:@"" message:@"Please Enable location access from Setting -> Taxinow Driver -> Privacy -> Location services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertLocation.tag=100;
        [alertLocation show];
    }
    
    
}

#pragma mark-
#pragma mark- Button Method

- (IBAction)onClickArrived:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"WAITING_TRIP_START", nil)];
    [self arrivedRequest];
    //    [btnArrived setHidden:YES];
    //    [btnWalk setHidden:NO];
    
}

- (IBAction)onClickJobDone:(id)sender
{
    
    [self.timer invalidate];
    
    [self.btnMenu addTarget:self.revealViewController action:@selector(revealToggle: ) forControlEvents:UIControlEventTouchUpInside];
    
    endTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    double start = [startTime doubleValue];
    double end=[endTime doubleValue];
    
    NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]];
    
    //NSLog(@"difference: %f", difference);
    
    time=(difference/(1000*60));
    
    if(time==0)
    {
        time=1;
    }
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"WAITING_TRIP_COMPLETE", nil)];
    [self jobDone];
}

- (IBAction)onClickWalkStart:(id)sender
{
    
    //    [btnWalk setHidden:YES];
    //    [btnJob setHidden:NO];
    startTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:startTime forKey:PREF_START_TIME];
    [pref synchronize];
    
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [runloop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:self.timer forMode:UITrackingRunLoopMode];
    [self walkStarted];
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"WAITING_TRIP_START", nil)];
}

- (IBAction)onClickWalkerStart:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:NSLocalizedString(@"WAITING_WALKER_START", nil)];
    [self walkerStarted];
    //    [btnWalker setHidden:YES];
    //    [btnArrived setHidden:NO];
}

- (IBAction)onClickCall:(id)sender
{
    
    NSString *call=[NSString stringWithFormat:@"tel://%@",strOwnerPhone];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:call]];
}

#pragma mark-
#pragma mark- Calculate Time & Distance

-(void)updateTime
{
    NSString *currentTime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    
    
    double start = [startTime doubleValue];
    double end=[currentTime doubleValue];
    
    NSTimeInterval difference = [[NSDate dateWithTimeIntervalSince1970:end] timeIntervalSinceDate:[NSDate dateWithTimeIntervalSince1970:start]];
    
    //NSLog(@"difference: %f", difference);
    
    time=(difference/(1000*60));
    
    if(time==0)
    {
        time=1;
    }
    
    [btnTime setTitle:[NSString stringWithFormat:@"%d min",time] forState:UIControlStateNormal];
    
    
}

/*
 */

-(void)calculateDistance
{
    CLLocationCoordinate2D current;
    current.latitude=[strStart_lati doubleValue];
    current.longitude=[strStart_longi doubleValue];
    
    CLLocationCoordinate2D currentOwner;
    currentOwner.latitude=[struser_lati doubleValue];
    currentOwner.longitude=[struser_longi doubleValue];
    
    locA=[[CLLocation alloc]initWithLatitude:current.latitude longitude:current.longitude];
    locB=[[CLLocation alloc]initWithLatitude:currentOwner.latitude longitude:currentOwner.longitude];
    
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


@end
