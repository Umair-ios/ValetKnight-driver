//
//  AppDelegate.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "AppDelegate.h"
#import "FacebookUtility.h"
#import "SignInVC.h"
#import "PickMeUpMapVC.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleMaps/GoogleMaps.h>
#import <SplunkMint/SplunkMint.h>

@implementation AppDelegate
{
    MBProgressHUD *HUD;
}

@synthesize viewLoading, vcPickMeUp;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //    //For Push Noti Reg.
    //    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
    //     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    //
    //    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //
    device_token=@"111111";
    
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    
    [pref setObject:@"111111" forKey:PREF_DEVICE_TOKEN];
    
    [pref synchronize];
    
    [GMSServices provideAPIKey:Google_Key];
    
    [[FacebookUtility sharedObject]getFBToken];
    
    if ([[FacebookUtility sharedObject]isLogin])
    {
        AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate userLoggedIn];
        SignInVC *obj=[[SignInVC alloc]init];
        UIButton *loginButton = [obj btnFacebook];
        [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    }
    // Override point for customization after application launch.
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        //register to receive notifications
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    NSDictionary *remoteNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(remoteNotif)
    {
        //Handle remote notification
        [self handleRemoteNotification:application userInfo:launchOptions];
    }
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    [[Mint sharedInstance] initAndStartSession:@"670decc3"];
    return YES;
}


- (void)userLoggedIn
{
    // Set the button title as "Log out"
    
    SignInVC *obj=[[SignInVC alloc]init];
    UIButton *loginButton = obj.btnFacebook;
    [loginButton setTitle:@"Log out" forState:UIControlStateNormal];
    
    // Welcome message
    // [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
    
}
#pragma mark -
#pragma mark - GPPDeepLinkDelegate

- (void)didReceiveDeepLink:(GPPDeepLink *)deepLink
{
    // An example to handle the deep link data.
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Deep-link Data"
                          message:[deepLink deepLinkID]
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)application: (UIApplication *)application openURL: (NSURL *)url sourceApplication: (NSString *)sourceApplication annotation: (id)annotation
{
    return [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask = 0;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark - Directory Path Methods

- (NSString *)applicationCacheDirectoryString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return cacheDirectory;
}


#pragma mark-
#pragma mark- Handle Push Method

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

//For interactive notification only
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    //NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    device_token=dt;
    
    if(dt==nil)
    {
        device_token=@"11111";
        
    }
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Token " message:dt delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    // [alert show];
    //NSLog(@"My token is: %@", dt);
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:device_token forKey:PREF_DEVICE_TOKEN];
    [pref synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    //NSLog(@"My token is error: %@", error);
    if (device_token==nil)
    {
        device_token=@"11111";
    }
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    [pref setObject:device_token forKey:PREF_DEVICE_TOKEN];
    [pref synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSMutableDictionary *aps=[userInfo valueForKey:@"aps"];
    NSMutableDictionary *msg=[aps valueForKey:@"message"];
    
    //    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",[aps valueForKey:@"alert"]] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"cancel", nil];
    //
    //    [alert show];
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        if ([[NSString stringWithFormat:@"%@",[msg valueForKey:@"unique_id"]] isEqualToString:@"1"]) {
            NSMutableDictionary *dictRequestData=[msg valueForKey:@"request_data"];
            dictOwner=[dictRequestData valueForKey:@"owner"];
            
            NSString *strRequsetId=[NSString stringWithFormat:@"%@",[msg valueForKey:@"request_id"]];
            
            NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
            [pref setObject:strRequsetId forKey:PREF_REQUEST_ID];
            [pref setObject:[msg valueForKey:@"time_left_to_respond"] forKey:PREF_TIME_TO_RESPOND];
            [pref setObject:[dictOwner valueForKey:@"name"] forKey:PREF_USER_NAME];
            [pref setObject:[dictOwner valueForKey:@"phone"] forKey:PREF_USER_PHONE];
            [pref setObject:[dictOwner valueForKey:@"rating"] forKey:PREF_USER_RATING];
            [pref setObject:[dictOwner valueForKey:@"picture"] forKey:PREF_USER_PIC];
            
            strowner_lati=[dictOwner valueForKey:@"latitude"];
            strowner_longi=[dictOwner valueForKey:@"longitude"];
            
            strDrop_lati = [dictOwner valueForKey:@"d_latitude"];
            strDrop_longi = [dictOwner valueForKey:@"d_longitude"];
            
            [pref setBool:TRUE forKey:PREF_IS_NEW_REQ_PUSH];
            [pref synchronize];
        }
        else if ([[NSString stringWithFormat:@"%@",[msg valueForKey:@"unique_id"]] isEqualToString:@"2"]) {
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:PREF_IS_CANCEL_REQ_PUSH];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if (state == UIApplicationStateInactive)
    {
        //What you want to do when your app was in background and it got push notification
    }
}

-(void)handleRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)userInfo {
    
    NSMutableDictionary *aps=[userInfo valueForKey:@"aps"];
    NSMutableDictionary *msg=[aps valueForKey:@"message"];
    
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"%@",msg] message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:@"cancel", nil];
    [alert show];
}


#pragma mark-
#pragma mark- Indicator Delegate


-(void) showHUDLoadingView:(NSString *)strTitle
{
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:HUD];
    
    HUD.detailsLabelText=[strTitle isEqualToString:@""] ? @"Loading...":strTitle;
    [HUD show:YES];
}

-(void) hideHUDLoadingView
{
    [HUD removeFromSuperview];
    [HUD setHidden:YES];
    [HUD show:NO];
}

-(void)showToastMessage:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window
                                              animated:YES];
    
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = message;
    hud.margin = 10.f;
    hud.yOffset = 150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:0.5];
}

#pragma mark -
#pragma mark - Loading View

-(void)showLoadingWithTitle:(NSString *)title
{
    if (viewLoading==nil) {
        viewLoading=[[UIView alloc]initWithFrame:self.window.bounds];
        viewLoading.backgroundColor=[UIColor whiteColor];
        viewLoading.alpha=0.6f;
        UIImageView *img=[[UIImageView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-88)/2, ((viewLoading.frame.size.height-30)/2)-30, 88, 30)];
        img.backgroundColor=[UIColor clearColor];
        
        img.animationImages=[NSArray arrayWithObjects:[UIImage imageNamed:@"loading_1.png"],[UIImage imageNamed:@"loading_2.png"],[UIImage imageNamed:@"loading_3.png"], nil];
        img.animationDuration = 1.0f;
        img.animationRepeatCount = 0;
        [img startAnimating];
        [viewLoading addSubview:img];
        
        UITextView *txt=[[UITextView alloc]initWithFrame:CGRectMake((viewLoading.frame.size.width-250)/2, ((viewLoading.frame.size.height-60)/2)+20, 250, 60)];
        txt.textAlignment=NSTextAlignmentCenter;
        txt.backgroundColor=[UIColor clearColor];
        txt.text=[title uppercaseString];
        txt.font=[UIFont systemFontOfSize:16];
        txt.userInteractionEnabled=FALSE;
        txt.scrollEnabled=FALSE;
        txt.textColor=[UberStyleGuide colorDefault];
        [viewLoading addSubview:txt];
    }
    
    [self.window addSubview:viewLoading];
    [self.window bringSubviewToFront:viewLoading];
}

-(void)hideLoadingView
{
    
    if (viewLoading) {
        [viewLoading removeFromSuperview];
        viewLoading=nil;
    }
}

#pragma mark-
#pragma mark- Test Internet


- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return (networkStatus != NotReachable);
}

#pragma mark -
#pragma mark - sharedAppDelegate

+(AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark-
#pragma mark- Font Descriptor

-(id)setBoldFontDiscriptor:(id)objc
{
    if([objc isKindOfClass:[UIButton class]])
    {
        UIButton *button=objc;
        button.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return button;
    }
    else if([objc isKindOfClass:[UITextField class]])
    {
        UITextField *textField=objc;
        textField.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return textField;
        
        
    }
    else if([objc isKindOfClass:[UILabel class]])
    {
        UILabel *lable=objc;
        lable.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0f];
        return lable;
    }
    return objc;
}


@end
/*
 -(id)setBoldFontDiscriptor:(id)objc
 {
 if([objc isKindOfClass:[UIButton class]])
 {
 UIButton *button=objc;
 button.titleLabel.font=[UberStyleGuide fontRegularBold:13.0f];
 UIFontDescriptor * fontD = [button.font.fontDescriptor
 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold
 ];
 button.font = [UIFont fontWithDescriptor:fontD size:10.0f];
 return button;
 }
 else if([objc isKindOfClass:[UITextField class]])
 {
 UITextField *textField=objc;
 textField.font=[UberStyleGuide fontRegularBold];
 UIFontDescriptor * fontD = [textField.font.fontDescriptor
 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold
 ];
 textField.font = [UIFont fontWithDescriptor:fontD size:0];
 return textField;
 
 
 }
 else if([objc isKindOfClass:[UILabel class]])
 {
 UILabel *lable=objc;
 lable.font=[UberStyleGuide fontRegularBold];
 UIFontDescriptor * fontD = [lable.font.fontDescriptor
 fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold
 ];
 lable.font = [UIFont fontWithDescriptor:fontD size:0];
 return lable;
 
 
 }
 return objc;
 }
 */
