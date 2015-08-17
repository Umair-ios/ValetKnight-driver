//
//  SignInVC.m
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "SignInVC.h"
#import "FacebookUtility.h"
#import <GooglePlus/GooglePlus.h>
#import "AppDelegate.h"
#import "GooglePlusUtility.h"
#import "UIImageView+Download.h"
#import "CarTypeCell.h"
#import "UtilityClass.h"
#import "UIView+Utils.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@interface SignInVC ()
{
    AppDelegate *appDelegate;
    //BOOL internet;
    BOOL isProPicAdded,isCountry;
    NSMutableArray *arrForCountry,*arrForTimeZone;
    NSMutableDictionary *dictparam,*timeZoneDict;
    NSArray *timeZoneArr;
    NSMutableArray *arrType;
    NSMutableString *strTypeId;
}

@property (weak, nonatomic) IBOutlet UILabel *lblPickerHeader;

@end

@implementation SignInVC

@synthesize txtEmail,txtFirstName,txtLastName,txtPassword,txtAddress,txtBio,txtZipcode,txtNumber,imgType,txtType,pickTypeView,typePicker,typeCollectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [super setBackBarItem];
    isProPicAdded=NO;
    //internet=[APPDELEGATE connected];
    
    [self.scrollView setScrollEnabled:YES];
    [self.scrollView setContentSize:CGSizeMake(320, 730)];
    arrForCountry=[[NSMutableArray alloc]init];
    arrForTimeZone = [[NSMutableArray alloc]init];
    
    dictparam=[[NSMutableDictionary alloc]init];
    
    [self.btnCheck setBackgroundImage:[UIImage imageNamed:@"cb_glossy_off.png"] forState:UIControlStateNormal];
    self.btnRegister.enabled=FALSE;
    txtType.userInteractionEnabled=NO;
    [self customFont];
}

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

#pragma mark-
#pragma mark- Custom Font

-(void)customFont
{
    self.txtFirstName.font=[UberStyleGuide fontRegular:14.0f];
    self.txtLastName.font=[UberStyleGuide fontRegular:14.0f];
    self.txtEmail.font=[UberStyleGuide fontRegular:14.0f];
    self.txtPassword.font=[UberStyleGuide fontRegular:14.0f];
    self.txtAddress.font=[UberStyleGuide fontRegular:14.0f];
    self.txtBio.font=[UberStyleGuide fontRegular:14.0f];
    self.txtZipcode.font=[UberStyleGuide fontRegular:14.0f];
    self.btnCountryCode.titleLabel.font = [UberStyleGuide fontRegular:14.0f];
    self.btnSelectTimeZone.titleLabel.font = [UberStyleGuide fontRegular:14.0f];
    
    self.btnNav_Register.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnRegister.titleLabel.font = [UberStyleGuide fontRegularBold];
    self.btnSelectService.titleLabel.font=[UberStyleGuide fontRegularBold];
    /*
     self.btnNav_Register=[APPDELEGATE setBoldFontDiscriptor:self.btnNav_Register];
     self.btnRegister=[APPDELEGATE setBoldFontDiscriptor:self.btnRegister];
     */
}


#pragma mark -
#pragma mark - UIButton Action

- (IBAction)faceBookBtnPressed:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:@"Please Wait"];
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if (![[FacebookUtility sharedObject]isLogin])
        {
            [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error)
             {
                 [APPDELEGATE hideLoadingView];
                 if (success)
                 {
                     //NSLog(@"Success");
                     appDelegate = [UIApplication sharedApplication].delegate;
                     [appDelegate userLoggedIn];
                     [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
                         if (response) {
                             //NSLog(@"%@",response);
                             self.txtEmail.text=[response valueForKey:@"email"];
                             NSArray *arr=[[response valueForKey:@"name"] componentsSeparatedByString:@" "];
                             txtPassword.userInteractionEnabled=NO;
                             self.txtFirstName.text=[arr objectAtIndex:0];
                             self.txtLastName.text=[arr objectAtIndex:1];
                             [dictparam setObject:@"facebook" forKey:PARAM_LOGIN_BY];
                             [dictparam setObject:[response valueForKey:@"id"] forKey:PARAM_SOCIAL_ID];
                             [self.imgProPic downloadFromURL:[response valueForKey:@"link"] withPlaceholder:nil];
                             NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [response objectForKey:@"id"]];
                             [self.imgProPic downloadFromURL:userImageURL withPlaceholder:nil];
                             isProPicAdded=YES;
                         }
                     }];
                 }
             }];
        }
        else{
            [APPDELEGATE hideLoadingView];
            //NSLog(@"User Login Click");
            appDelegate = [UIApplication sharedApplication].delegate;
            [[FacebookUtility sharedObject]fetchMeWithFBCompletionBlock:^(id response, NSError *error) {
                if (response) {
                    //NSLog(@"%@",response);
                    //NSLog(@"%@",response);
                    self.txtEmail.text=[response valueForKey:@"email"];
                    NSArray *arr=[[response valueForKey:@"name"] componentsSeparatedByString:@" "];
                    self.txtFirstName.text=[arr objectAtIndex:0];
                    self.txtLastName.text=[arr objectAtIndex:1];
                    [self.imgProPic downloadFromURL:[response valueForKey:@"link"] withPlaceholder:nil];
                    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [response objectForKey:@"id"]];
                    [self.imgProPic downloadFromURL:userImageURL withPlaceholder:nil];
                    isProPicAdded=YES;
                    
                }
            }];
            [appDelegate userLoggedIn];
        }
        
    }
    else
    {
        [APPDELEGATE hideLoadingView];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

- (IBAction)selectCountryBtnPressed:(id)sender
{
    isCountry = YES;
    self.lblPickerHeader.text = @"Select Country";
    [self.view endEditing:YES];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countrycodes" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    arrForCountry = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    self.pickerView.tag=100;
    
    [self.pickerView reloadAllComponents];
    self.viewForPicker.hidden=NO;
    pickTypeView.hidden=YES;
}

- (IBAction)selectTimeZone:(id)sender {
    isCountry = NO;
    self.lblPickerHeader.text = @"Select Timezone";
    
    [self.view endEditing:YES];
    self.pickerView.tag=100;
    
    arrForTimeZone = [timeZoneArr mutableCopy];
    [self.pickerView reloadAllComponents];
    self.viewForPicker.hidden=NO;
}

- (IBAction)googleBtnPressed:(id)sender
{
    [APPDELEGATE showLoadingWithTitle:@"Please Wait"];
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if ([[GooglePlusUtility sharedObject]isLogin])
        {
        }
        else
        {
            [[GooglePlusUtility sharedObject]loginWithBlock:^(id response, NSError *error)
             {
                 [APPDELEGATE hideLoadingView];
                 if (response)
                 {
                     //NSLog(@"Response ->%@ ",response);
                     txtPassword.userInteractionEnabled=NO;
                     
                     self.txtEmail.text=[response valueForKey:@"email"];
                     NSArray *arr=[[response valueForKey:@"name"] componentsSeparatedByString:@" "];
                     self.txtFirstName.text=[arr objectAtIndex:0];
                     self.txtLastName.text=[arr objectAtIndex:1];
                     [dictparam setObject:@"google" forKey:PARAM_LOGIN_BY];
                     [dictparam setObject:[response valueForKey:@"userid"] forKey:PARAM_SOCIAL_ID];
                     [self.imgProPic downloadFromURL:[response valueForKey:@"profile_image"] withPlaceholder:nil];
                     isProPicAdded=YES;
                 }
             }];
        }
    }
    else
    {
        [APPDELEGATE hideLoadingView];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)doneBtnPressed:(id)sender
{
    //    NSString *setTzName = [[timeZoneDict allKeysForObject:[arrUser valueForKey:@"timezone"]] firstObject];
    //    [self.btnSelectTimeZone setTitle:setTzName forState:UIControlStateNormal];
    
    [self.viewForPicker setHidden:YES];
}

- (IBAction)cancelBtnPressed:(id)sender
{
    NSInteger row;
    
    row = [self.pickerView selectedRowInComponent:0];
    [self.btnSelectTimeZone setTitle:[arrForTimeZone objectAtIndex:row] forState:UIControlStateNormal];
    
    [self.viewForPicker setHidden:YES];
}



- (IBAction)saveBtnPressed:(id)sender
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        if(self.txtFirstName.text.length<1 || self.txtLastName.text.length<1 || self.txtEmail.text.length<1 || self.txtNumber.text.length<1|| strTypeId==nil ||isProPicAdded==NO)
        {
            
            if(self.txtFirstName.text.length<1)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_FIRST_NAME", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            else if(self.txtLastName.text.length<1)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_LAST_NAME", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            else if(self.txtEmail.text.length<1)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_EMAIL", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            
            else if(self.txtNumber.text.length<1)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"PLEASE_NUMBER", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            else if(strTypeId==nil)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please Select Service Type", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
            else if(isProPicAdded==NO)
            {
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"Please Select Profile Picture", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                [alert show];
            }
        }
        else
        {
            NSString *strnumber=[NSString stringWithFormat:@"%@%@",self.btnCountryCode.titleLabel.text,txtNumber.text];
            NSString *strTimezone = [NSString stringWithFormat:@"%@",self.btnSelectTimeZone.titleLabel.text];
            
            [dictparam setObject:txtFirstName.text forKey:PARAM_FIRST_NAME];
            [dictparam setObject:txtLastName.text forKey:PARAM_LAST_NAME];
            [dictparam setObject:txtEmail.text forKey:PARAM_EMAIL];
            [dictparam setObject:strnumber forKey:PARAM_PHONE];
            [dictparam setObject:txtPassword.text forKey:PARAM_PASSWORD];
            [dictparam setObject:txtAddress.text forKey:PARAM_ADDRESS];
            [dictparam setObject:txtBio.text forKey:PARAM_BIO];
            [dictparam setObject:txtZipcode.text forKey:PARAM_ZIPCODE];
            [dictparam setObject:device_token forKey:PARAM_DEVICE_TOKEN];
            [dictparam setObject:@"ios" forKey:PARAM_DEVICE_TYPE];
            [dictparam setObject:strTypeId forKey:PARAM_WALKER_TYPE];
            
            [dictparam setObject:@"" forKey:PARAM_COUNTRY];
            [dictparam setObject:@"" forKey:PARAM_STATE];
            
            [dictparam setObject:@"" forKey:PARAM_PICTURE];
            [dictparam setValue:[timeZoneDict objectForKey:strTimezone] forKey:PARAM_TIME_ZONE];
            
            if([dictparam valueForKey:PARAM_SOCIAL_ID]==nil)
            {
                [dictparam setObject:@"manual" forKey:PARAM_LOGIN_BY];
                [dictparam setObject:@"" forKey:PARAM_SOCIAL_ID];
            }
            [APPDELEGATE showLoadingWithTitle:@"Please Wait"];
            UIImage *imgUpload = [[UtilityClass sharedObject]scaleAndRotateImage:self.imgProPic.image];
            
            AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:POST_METHOD];
            [afn getDataFromPath:FILE_REGISTER withParamDataImage:dictparam andImage:imgUpload withBlock:^(id response, NSError *error)
             {
                 
                 [APPDELEGATE hideLoadingView];
                 if (response)
                 {
                     if([[response valueForKey:@"success"] intValue]==1)
                     {
                         txtPassword.userInteractionEnabled=YES;
                         [APPDELEGATE showToastMessage:(NSLocalizedString(@"REGISTER_SUCCESS", nil))];
                         arrUser=response;
                         [self.navigationController popToRootViewControllerAnimated:YES];
                     }
                     else
                     {
                         [APPDELEGATE hideLoadingView];
                         UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"" message:[response valueForKey:@"error"] delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
                         [alert show];
                     }
                 }
                 else
                 {
                     [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
                 }
                 
                 //NSLog(@"REGISTER RESPONSE --> %@",response);
             }];
        }
    }
    else
    {
        [APPDELEGATE hideLoadingView];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"No Internet" message:NSLocalizedString(@"NO_INTERNET", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

- (IBAction)imgPickBtnPressed:(id)sender
{
    UIActionSheet *action=[[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Select Image", nil];
    action.tag=10001;
    [action showInView:self.view];
    
}

- (IBAction)backBtnPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)termsBtnPressed:(id)sender
{
    [self performSegueWithIdentifier:@"pushToTerms" sender:self];
}

- (IBAction)checkBtnPressed:(id)sender
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag == 0)
    {
        btn.tag=1;
        [btn setBackgroundImage:[UIImage imageNamed:@"cb_glossy_on.png"] forState:UIControlStateNormal];
        
        self.btnRegister.enabled=TRUE;
        
    }
    else
    {
        btn.tag=0;
        [btn setBackgroundImage:[UIImage imageNamed:@"cb_glossy_off.png"] forState:UIControlStateNormal];
        self.btnRegister.enabled=FALSE;
    }
}

- (IBAction)selectServiceBtnPressed:(id)sender
{
    UIDevice *thisDevice=[UIDevice currentDevice];
    if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        float closeY=(iOSDeviceScreenSize.height-self.btnSelectService.frame.size.height-self.btnRegister.frame.size.height-1);
        
        float openY=closeY-(self.bottomView.frame.size.height-self.btnSelectService.frame.size.height-self.btnRegister.frame.size.height)-30.0f;
        if (self.bottomView.frame.origin.y==closeY)
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomView.frame=CGRectMake(0, openY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        else
        {
            [UIView animateWithDuration:0.5 animations:^{
                
                self.bottomView.frame=CGRectMake(0, closeY, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
                
            } completion:^(BOOL finished)
             {
             }];
        }
        
    }
    
    
}

#pragma mark -
#pragma mark - UIActionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self openCamera];
            break;
        case 1:
            [self chooseFromLibaray];
            break;
        case 2:
            break;
        case 3:
            break;
    }
}

-(void)openCamera
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate =self;
        imagePickerController.allowsEditing=YES;
        imagePickerController.view.tag = 102;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else
    {
        UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"CAM_NOT_AVAILABLE", nil)delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alt show];
    }
}

-(void)chooseFromLibaray
{
    // Set up the image picker controller and add it to the view
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing=YES;
    imagePickerController.view.tag = 102;
    
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
}

#pragma mark -
#pragma mark - UIImagePickerController Delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imgProPic.contentMode = UIViewContentModeScaleAspectFill;
    self.imgProPic.clipsToBounds = YES;
    isProPicAdded=YES;
    self.imgProPic.image=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark - UIPickerView Delegate and Datasource

- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerView.tag==100)
    {
        if (isCountry) {
            [self.btnCountryCode setTitle:[[arrForCountry objectAtIndex:row] valueForKey:@"phone-code"] forState:UIControlStateNormal];
        }
        else {
            [self.btnSelectTimeZone setTitle:[arrForTimeZone objectAtIndex:row] forState:UIControlStateNormal];
        }
    }
    else if (typePicker.tag==101)
    {
        NSMutableDictionary *typeDict=[arrType objectAtIndex:row];
        txtType.text=[typeDict valueForKey:@"name"];
        [self.imgType downloadFromURL:[typeDict valueForKey:@"icon"] withPlaceholder:nil];
        strTypeId=[NSMutableString stringWithFormat:@"%@",[typeDict valueForKey:@"id"]];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickerView.tag==100)
    {
        if (isCountry) {
            return arrForCountry.count;
        }
        else {
            return arrForTimeZone.count;
        }
    }
    else if (typePicker.tag==101)
    {
        return arrType.count;
    }
    else
    {
        return  0;
    }
    
}
/*
 - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
 {
 NSString *strForTitle=[NSString stringWithFormat:@"%@  %@",[[arrForCountry objectAtIndex:row] valueForKey:@"phone-code"],[[arrForCountry objectAtIndex:row] valueForKey:@"name"]];
 return strForTitle;
 }*/

-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView *viewTitle=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
    
    if (self.pickerView.tag==100)
    {
        NSString *strForTitle;
        if (isCountry) {
            strForTitle=[NSString stringWithFormat:@"%@  %@",[[arrForCountry objectAtIndex:row] valueForKey:@"phone-code"],[[arrForCountry objectAtIndex:row] valueForKey:@"name"]];
        }
        else {
            strForTitle = [NSString stringWithFormat:@"%@",[arrForTimeZone objectAtIndex:row]];
        }
        
        UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(25, 0, 250, 40)];
        lbl.font = [UberStyleGuide fontRegular:15.0f];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text=strForTitle;
        
        UIImageView *imggv=[[UIImageView alloc]initWithFrame:CGRectMake(25, 5, 30, 30)];
        
        imggv.image=[UIImage imageNamed:@"Flag_of_India.png"];
        
        [viewTitle addSubview:lbl];
    }
    if(typePicker.tag==101)
    {
        NSMutableDictionary *dictType=[arrType objectAtIndex:row];
        
        UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, 250, 40)];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.text=[dictType valueForKey:@"name"];;
        
        UIImageView *imggv=[[UIImageView alloc]initWithFrame:CGRectMake(25, 5, 30, 30)];
        [imggv downloadFromURL:[dictType valueForKey:@"icon"] withPlaceholder:nil];
        
        
        [viewTitle addSubview:lbl];
        [viewTitle addSubview:imggv];
        
    }
    
    return viewTitle;
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40.0;
}

#pragma mark-
#pragma mark- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrType.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CarTypeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cartype" forIndexPath:indexPath];
    
    NSMutableDictionary *dictType=[arrType objectAtIndex:indexPath.row];
    
    if (strTypeId==nil)
    {
        if ([[dictType valueForKey:@"is_default"]intValue]==1)
        {
            strTypeId=[NSString stringWithFormat:@"%@",[dictType valueForKey:@"id"]];
        }
    }
    
    cell.lblTitle.text=[dictType valueForKey:@"name"];;
    if ([strTypeId isEqualToString:[dictType valueForKey:@"id"]])
    {
        cell.imgCheck.hidden=NO;
    }
    else
    {
        cell.imgCheck.hidden=YES;
    }
    
    [cell.imgType downloadFromURL:[dictType valueForKey:@"icon"] withPlaceholder:nil];
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *dictType=[arrType objectAtIndex:indexPath.row];
    //txtType.text=[dictType valueForKey:@"name"];;
    strTypeId=[NSMutableString stringWithFormat:@"%@",[dictType valueForKey:@"id"]];
    //[imgType downloadFromURL:[dictType valueForKey:@"icon"] withPlaceholder:nil];
    [self.typeCollectionView reloadData];
}

/*- (CGSize)collectionView:(UICollectionView *)collectionView
 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath
 {
 
 if(indexPath.row==arrType.count-1)
 return CGSizeMake(45, 60);
 
 return CGSizeMake(104, 60);
 }
 */
#pragma mark-
#pragma mark- Text Field Delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField==self.txtNumber  || textField==self.txtZipcode)
    {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        return ([string stringByTrimmingCharactersInSet:nonNumberSet].length > 0) || [string isEqualToString:@""];
    }
    return YES;
}





-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGPoint offset;
    if(textField==self.txtFirstName)
    {
        offset=CGPointMake(0, 30);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if(textField==self.txtLastName)
    {
        offset=CGPointMake(0, 60);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if(textField==self.txtEmail)
    {
        offset=CGPointMake(0, 110);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if(textField==self.txtNumber)
    {
        offset=CGPointMake(0, 230);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if(textField==self.txtPassword)
    {
        offset=CGPointMake(0, 190);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    else if(textField==self.txtAddress)
    {
        offset=CGPointMake(0, 270);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    else if(textField==self.txtBio)
    {
        offset=CGPointMake(0, 330);
        [self.scrollView setContentOffset:offset animated:YES];
    }
    else if(textField==self.txtZipcode)
    {
        offset=CGPointMake(0, 390);
        [self.scrollView setContentOffset:offset animated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CGPoint offset;
    offset=CGPointMake(0, 0);
    [self.scrollView setContentOffset:offset animated:YES];
    
    if(textField==self.txtFirstName)
        [self.txtLastName becomeFirstResponder];
    else if(textField==self.txtLastName)
        [self.txtEmail becomeFirstResponder];
    else if(textField==self.txtEmail)
        [self.txtPassword becomeFirstResponder];
    else if(textField==self.txtNumber)
        [self.txtAddress becomeFirstResponder];
    else if(textField==self.txtPassword)
        [self.txtNumber becomeFirstResponder];
    else if(textField==self.txtAddress)
        [self.txtBio becomeFirstResponder];
    else if(textField==self.txtBio)
        [self.txtZipcode becomeFirstResponder];
    
    [textField resignFirstResponder];
    return YES;
}



#pragma mark-
#pragma mark- Get WalerType Method


-(void)getType
{
    if([[AppDelegate sharedAppDelegate]connected])
    {
        AFNHelper *afn=[[AFNHelper alloc]initWithRequestMethod:GET_METHOD];
        [afn getDataFromPath:FILE_WALKER_TYPE withParamData:nil withBlock:^(id response, NSError *error)
         {
             
             //NSLog(@"Check Request= %@",response);
             if (response) {
                 if([[response valueForKey:@"success"] intValue]==1)
                 {
                     arrType=[response valueForKey:@"types"];
                     [typeCollectionView reloadData];
                     self.pickerView.tag=0;
                     typePicker.tag=101;
                     [typePicker reloadAllComponents];
                 }
             }
             else
             {
                 [APPDELEGATE showToastMessage:NSLocalizedString(@"ERROR", nil)];
             }
             
             
         }];
    }
}

- (IBAction)typeBtnPressed:(id)sender
{
    if(pickTypeView.hidden==YES)
    {
        typePicker.tag=101;
        self.pickerView.tag=0;
        [typePicker reloadAllComponents];
        pickTypeView.hidden=NO;
    }
    else
    {
        pickTypeView.hidden=YES;
    }
}

- (IBAction)pickDoneBtnPressed:(id)sender
{
    self.pickTypeView.hidden=YES;
}

- (IBAction)pickCancelBtnPressed:(id)sender
{
    self.pickTypeView.hidden=YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    arrType=[[NSMutableArray alloc]init];
    [self getType];
    pickTypeView.hidden=YES;
    self.viewForPicker.hidden=YES;
    [self.imgProPic applyRoundedCornersFull];
    
    timeZoneArr = [NSArray arrayWithObjects:@"(UTC-11:00) Midway Island",@"(UTC-11:00) Samoa",@"(UTC-10:00) Hawaii",@"(UTC-09:00) Alaska",@"(UTC-08:00) Pacific Time (US & Canada)",@"(UTC-08:00) Tijuana",@"TC-07:00) Arizona",@"(UTC-07:00) Chihuahua",@"(UTC-07:00) La Paz",@"(UTC-07:00) Mazatlan",@"(UTC-07:00) Mountain Time (US & Canada)",@"(UTC-06:00) Central America",@"(UTC-06:00) Central Time (US & Canada)",@"(UTC-06:00) Guadalajara",@"(UTC-06:00) Mexico City",@"(UTC-06:00) Monterrey",@"(UTC-06:00) Saskatchewan",@"(UTC-05:00) Bogota",@"(UTC-05:00) Bogota",@"(UTC-05:00) Eastern Time (US & Canada)",@"(UTC-05:00) Indiana (East)",@"(UTC-05:00) Lima",@"(UTC-05:00) Quito",@"(UTC-04:00) Atlantic Time (Canada)",@"(UTC-04:30) Caracas",@"(UTC-04:00) La Paz",@"(UTC-04:00) Santiago",@"(UTC-03:30) Newfoundland",@"(UTC-03:00) Brasilia",@"(UTC-03:00) Buenos Aires",@"(UTC-03:00) Georgetown",@"(UTC-03:00) Greenland",@"(UTC-02:00) Mid-Atlantic",@"(UTC-01:00) Azores",@"(UTC-01:00) Cape Verde Is.",@"(UTC+00:00) Casablanca",@"(UTC+00:00) Edinburgh",@"(UTC+00:00) Greenwich Mean Time : Dublin",@"(UTC+00:00) Lisbon",@"(UTC+00:00) London",@"(UTC+00:00) Monrovia",@"(UTC+00:00) UTC",@"(UTC+01:00) Amsterdam",@"(UTC+01:00) Belgrade",@"(UTC+01:00) Berlin",@"(UTC+01:00) Bern",@"(UTC+01:00) Bratislava",@"(UTC+01:00) Brussels",@"(UTC+01:00) Budapest",@"(UTC+01:00) Copenhagen",@"(UTC+01:00) Ljubljana",@"(UTC+01:00) Madrid",@"(UTC+01:00) Paris",@"(UTC+01:00) Prague",@"(UTC+01:00) Rome",@"(UTC+01:00) Sarajevo",@"(UTC+01:00) Skopje",@"(UTC+01:00) Stockholm",@"(UTC+01:00) Vienna",@"(UTC+01:00) Warsaw",@"(UTC+01:00) West Central Africa",@"(UTC+01:00) Zagreb",@"(UTC+02:00) Athens",@"(UTC+02:00) Bucharest",@"(UTC+02:00) Cairo",@"(UTC+02:00) Harare",@"(UTC+02:00) Helsinki",@"(UTC+02:00) Istanbul",@"(UTC+02:00) Jerusalem",@"(UTC+02:00) Kyiv",@"(UTC+02:00) Pretoria",@"(UTC+02:00) Riga",@"(UTC+02:00) Sofia",@"(UTC+02:00) Tallinn",@"(UTC+02:00) Vilnius",@"(UTC+03:00) Baghdad",@"(UTC+03:00) Kuwait",@"(UTC+03:00) Minsk",@"(UTC+03:00) Nairobi",@"(UTC+03:00) Riyadh",@"(UTC+03:00) Volgograd",@"(UTC+03:30) Tehran",@"(UTC+04:00) Abu Dhabi",@"(UTC+04:00) Baku",@"(UTC+04:00) Moscow",@"(UTC+04:00) Muscat",@"(UTC+04:00) St. Petersburg",@"(UTC+04:00) Tbilisi",@"(UTC+04:00) Yerevan",@"(UTC+04:30) Kabul",@"(UTC+05:00) Islamabad",@"(UTC+05:00) Karachi",@"(UTC+05:00) Tashkent",@"(UTC+05:30) Chennai",@"(UTC+05:30) Kolkata",@"(UTC+05:30) Mumbai",@"(UTC+05:30) New Delhi",@"(UTC+05:30) Sri Jayawardenepura",@"(UTC+05:45) Kathmandu",@"(UTC+06:00) Almaty",@"(UTC+06:00) Astana",@"(UTC+06:00) Dhaka",@"(UTC+06:00) Ekaterinburg",@"(UTC+06:30) Rangoon",@"(UTC+07:00) Bangkok",@"(UTC+07:00) Hanoi",@"(UTC+07:00) Jakarta",@"(UTC+07:00) Novosibirsk",@"(UTC+08:00) Beijing",@"(UTC+08:00) Chongqing",@"(UTC+08:00) Hong Kong",@"(UTC+08:00) Krasnoyarsk",@"(UTC+08:00) Kuala Lumpur",@"(UTC+08:00) Perth",@"(UTC+08:00) Singapore",@"(UTC+08:00) Taipei",@"(UTC+08:00) Ulaan Bataar",@"(UTC+08:00) Urumqi",@"(UTC+09:00) Irkutsk",@"(UTC+09:00) Osaka",@"(UTC+09:00) Sapporo",@"(UTC+09:00) Seoul",@"(UTC+09:00) Tokyo",@"(UTC+09:30) Adelaide",@"(UTC+09:30) Darwin",@"(UTC+10:00) Brisbane",@"(UTC+10:00) Canberra",@"(UTC+10:00) Guam",@"(UTC+10:00) Hobart",@"(UTC+10:00) Melbourne",@"(UTC+10:00) Port Moresby",@"(UTC+10:00) Sydney",@"(UTC+10:00) Yakutsk",@"(UTC+11:00) Vladivostok",@"(UTC+12:00) Auckland",@"(UTC+12:00) Fiji",@"(UTC+12:00) International Date Line West",@"(UTC+12:00) Kamchatka",@"(UTC+12:00) Magadan",@"(UTC+12:00) Marshall Is.",@"(UTC+12:00) New Caledonia",@"(UTC+12:00) Solomon Is.",@"(UTC+12:00) Wellington",@"(UTC+13:00) Nuku'alofa", nil];
    
    timeZoneDict = [[NSMutableDictionary alloc]init];
    [timeZoneDict setObject:@"Pacific/Midway" forKey:@"(UTC-11:00) Midway Island"];
    [timeZoneDict setObject:@"Pacific/Samoa" forKey:@"(UTC-11:00) Samoa"];
    [timeZoneDict setObject:@"Pacific/Honolulu" forKey:@"(UTC-10:00) Hawaii"];
    [timeZoneDict setObject:@"US/Alaska" forKey:@"(UTC-09:00) Alaska"];
    [timeZoneDict setObject:@"America/Los_Angeles" forKey:@"(UTC-08:00) Pacific Time (US & Canada)"];
    [timeZoneDict setObject:@"America/Tijuana" forKey:@"(UTC-08:00) Tijuana"];
    [timeZoneDict setObject:@"US/Arizona" forKey:@"(UTC-07:00) Arizona"];
    [timeZoneDict setObject:@"America/Chihuahua" forKey:@"(UTC-07:00) Chihuahua"];
    [timeZoneDict setObject:@"America/Chihuahua" forKey:@"La Paz"];
    [timeZoneDict setObject:@"America/Mazatlan" forKey:@"(UTC-07:00) Mazatlan"];
    [timeZoneDict setObject:@"US/Mountain" forKey:@"(UTC-07:00) Mountain Time (US & Canada)"];
    [timeZoneDict setObject:@"America/Managua" forKey:@"(UTC-06:00) Central America"];
    [timeZoneDict setObject:@"US/Central" forKey:@"(UTC-06:00) Central Time (US & Canada)"];
    [timeZoneDict setObject:@"America/Mexico_City" forKey:@"(UTC-06:00) Guadalajara"];
    [timeZoneDict setObject:@"America/Mexico_City" forKey:@"(UTC-06:00) Mexico City"];
    [timeZoneDict setObject:@"America/Monterrey" forKey:@"(UTC-06:00) Monterrey"];
    [timeZoneDict setObject:@"Canada/Saskatchewan" forKey:@"(UTC-06:00) Saskatchewan"];
    [timeZoneDict setObject:@"America/Bogota" forKey:@"(UTC-05:00) Bogota"];
    [timeZoneDict setObject:@"US/Eastern" forKey:@"(UTC-05:00) Eastern Time (US & Canada)"];
    [timeZoneDict setObject:@"US/East-Indiana" forKey:@"(UTC-05:00) Indiana (East)"];
    [timeZoneDict setObject:@"America/Lima" forKey:@"(UTC-05:00) Lima"];
    [timeZoneDict setObject:@"America/Bogota" forKey:@"(UTC-05:00) Quito"];
    [timeZoneDict setObject:@"Canada/Atlantic" forKey:@"(UTC-04:00) Atlantic Time (Canada)"];
    [timeZoneDict setObject:@"America/Caracas" forKey:@"(UTC-04:30) Caracas"];
    [timeZoneDict setObject:@"America/La_Paz" forKey:@"(UTC-04:00) La Paz"];
    [timeZoneDict setObject:@"America/Santiago" forKey:@"(UTC-04:00) Santiago"];
    [timeZoneDict setObject:@"Canada/Newfoundland" forKey:@"(UTC-03:30) Newfoundland"];
    [timeZoneDict setObject:@"America/Sao_Paulo" forKey:@"(UTC-03:00) Brasilia"];
    [timeZoneDict setObject:@"America/Argentina/Buenos_Aires" forKey:@"(UTC-03:00) Buenos Aires"];
    [timeZoneDict setObject:@"America/Argentina/Buenos_Aires" forKey:@"(UTC-03:00) Georgetown"];
    [timeZoneDict setObject:@"America/Godthab" forKey:@"(UTC-03:00) Greenland"];
    [timeZoneDict setObject:@"America/Noronha" forKey:@"(UTC-02:00) Mid-Atlantic"];
    [timeZoneDict setObject:@"Atlantic/Azores" forKey:@"(UTC-01:00) Azores"];
    [timeZoneDict setObject:@"Atlantic/Cape_Verde" forKey:@"(UTC-01:00) Cape Verde Is."];
    [timeZoneDict setObject:@"Africa/Casablanca" forKey:@"(UTC+00:00) Casablanca"];
    [timeZoneDict setObject:@"Europe/London" forKey:@"(UTC+00:00) Edinburgh"];
    [timeZoneDict setObject:@"Etc/Greenwich" forKey:@"(UTC+00:00) Greenwich Mean Time : Dublin"];
    [timeZoneDict setObject:@"Europe/Lisbon" forKey:@"(UTC+00:00) Lisbon"];
    [timeZoneDict setObject:@"Europe/London" forKey:@"(UTC+00:00) London"];
    [timeZoneDict setObject:@"Africa/Monrovia" forKey:@"(UTC+00:00) Monrovia"];
    [timeZoneDict setObject:@"UTC" forKey:@"(UTC+00:00) UTC"];
    [timeZoneDict setObject:@"Europe/Amsterdam" forKey:@"(UTC+01:00) Amsterdam"];
    [timeZoneDict setObject:@"Europe/Belgrade" forKey:@"(UTC+01:00) Belgrade"];
    [timeZoneDict setObject:@"Europe/Berlin" forKey:@"(UTC+01:00) Berlin"];
    [timeZoneDict setObject:@"Europe/Berlin" forKey:@"(UTC+01:00) Bern"];
    [timeZoneDict setObject:@"Europe/Bratislava" forKey:@"(UTC+01:00) Bratislava"];
    [timeZoneDict setObject:@"Europe/Brussels" forKey:@"(UTC+01:00) Brussels"];
    [timeZoneDict setObject:@"Europe/Budapest" forKey:@"(UTC+01:00) Budapest"];
    [timeZoneDict setObject:@"Europe/Copenhagen" forKey:@"(UTC+01:00) Copenhagen"];
    [timeZoneDict setObject:@"Europe/Ljubljana" forKey:@"(UTC+01:00) Ljubljana"];
    [timeZoneDict setObject:@"Europe/Madrid" forKey:@"(UTC+01:00) Madrid"];
    [timeZoneDict setObject:@"Europe/Paris" forKey:@"(UTC+01:00) Paris"];
    [timeZoneDict setObject:@"Europe/Prague" forKey:@"(UTC+01:00) Prague"];
    [timeZoneDict setObject:@"Europe/Rome" forKey:@"(UTC+01:00) Rome"];
    [timeZoneDict setObject:@"Europe/Sarajevo" forKey:@"(UTC+01:00) Sarajevo"];
    [timeZoneDict setObject:@"Europe/Skopje" forKey:@"(UTC+01:00) Skopje"];
    [timeZoneDict setObject:@"Europe/Stockholm" forKey:@"(UTC+01:00) Stockholm"];
    [timeZoneDict setObject:@"Europe/Vienna" forKey:@"(UTC+01:00) Vienna"];
    [timeZoneDict setObject:@"Europe/Warsaw" forKey:@"(UTC+01:00) Warsaw"];
    [timeZoneDict setObject:@"Africa/Lagos" forKey:@"(UTC+01:00) West Central Africa"];
    [timeZoneDict setObject:@"Europe/Zagreb" forKey:@"(UTC+01:00) Zagreb"];
    [timeZoneDict setObject:@"Europe/Athens" forKey:@"(UTC+02:00) Athens"];
    [timeZoneDict setObject:@"Europe/Bucharest" forKey:@"(UTC+02:00) Bucharest"];
    [timeZoneDict setObject:@"Africa/Cairo" forKey:@"(UTC+02:00) Cairo"];
    [timeZoneDict setObject:@"Africa/Harare" forKey:@"(UTC+02:00) Harare"];
    [timeZoneDict setObject:@"Europe/Helsinki" forKey:@"(UTC+02:00) Helsinki"];
    [timeZoneDict setObject:@"Europe/Istanbul" forKey:@"(UTC+02:00) Istanbul"];
    [timeZoneDict setObject:@"Asia/Jerusalem" forKey:@"(UTC+02:00) Jerusalem"];
    [timeZoneDict setObject:@"Europe/Helsinki" forKey:@"(UTC+02:00) Kyiv"];
    [timeZoneDict setObject:@"Africa/Johannesburg" forKey:@"(UTC+02:00) Pretoria"];
    [timeZoneDict setObject:@"Europe/Riga" forKey:@"(UTC+02:00) Riga"];
    [timeZoneDict setObject:@"Europe/Sofia" forKey:@"(UTC+02:00) Sofia"];
    [timeZoneDict setObject:@"Europe/Tallinn" forKey:@"(UTC+02:00) Tallinn"];
    [timeZoneDict setObject:@"Europe/Vilnius" forKey:@"(UTC+02:00) Vilnius"];
    [timeZoneDict setObject:@"Asia/Baghdad" forKey:@"(UTC+03:00) Baghdad"];
    [timeZoneDict setObject:@"Asia/Kuwait" forKey:@"(UTC+03:00) Kuwait"];
    [timeZoneDict setObject:@"Europe/Minsk" forKey:@"(UTC+03:00) Minsk"];
    [timeZoneDict setObject:@"Africa/Nairobi" forKey:@"(UTC+03:00) Nairobi"];
    [timeZoneDict setObject:@"Asia/Riyadh" forKey:@"(UTC+03:00) Riyadh"];
    [timeZoneDict setObject:@"Europe/Volgograd" forKey:@"(UTC+03:00) Volgograd"];
    [timeZoneDict setObject:@"Asia/Tehran" forKey:@"(UTC+03:30) Tehran"];
    [timeZoneDict setObject:@"Asia/Muscat" forKey:@"(UTC+04:00) Abu Dhabi"];
    [timeZoneDict setObject:@"Asia/Baku" forKey:@"(UTC+04:00) Baku"];
    [timeZoneDict setObject:@"Europe/Moscow" forKey:@"(UTC+04:00) Moscow"];
    [timeZoneDict setObject:@"Asia/Muscat" forKey:@"(UTC+04:00) Muscat"];
    [timeZoneDict setObject:@"Europe/Moscow" forKey:@"(UTC+04:00) St. Petersburg"];
    [timeZoneDict setObject:@"Asia/Tbilisi" forKey:@"(UTC+04:00) Tbilisi"];
    [timeZoneDict setObject:@"Asia/Yerevan" forKey:@"(UTC+04:00) Yerevan"];
    [timeZoneDict setObject:@"Asia/Kabul" forKey:@"(UTC+04:30) Kabul"];
    [timeZoneDict setObject:@"Asia/Karachi" forKey:@"(UTC+05:00) Islamabad"];
    [timeZoneDict setObject:@"Asia/Karachi" forKey:@"(UTC+05:00) Karachi"];
    [timeZoneDict setObject:@"Asia/Tashkent" forKey:@"(UTC+05:00) Tashkent"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) Chennai"];
    [timeZoneDict setObject:@"Asia/Kolkata" forKey:@"(UTC+05:30) Kolkata"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) Mumbai"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) New Delhi"];
    [timeZoneDict setObject:@"Asia/Calcutta" forKey:@"(UTC+05:30) Sri Jayawardenepura"];
    [timeZoneDict setObject:@"Asia/Katmandu" forKey:@"(UTC+05:45) Kathmandu"];
    [timeZoneDict setObject:@"Asia/Almaty" forKey:@"(UTC+06:00) Almaty"];
    [timeZoneDict setObject:@"Asia/Dhaka" forKey:@"(UTC+06:00) Astana"];
    [timeZoneDict setObject:@"Asia/Dhaka" forKey:@"(UTC+06:00) Dhaka"];
    [timeZoneDict setObject:@"Asia/Yekaterinburg" forKey:@"(UTC+06:00) Ekaterinburg"];
    [timeZoneDict setObject:@"Asia/Rangoon" forKey:@"(UTC+06:30) Rangoon"];
    [timeZoneDict setObject:@"Asia/Bangkok" forKey:@"(UTC+07:00) Bangkok"];
    [timeZoneDict setObject:@"Asia/Bangkok" forKey:@"(UTC+07:00) Hanoi"];
    [timeZoneDict setObject:@"Asia/Jakarta" forKey:@"(UTC+07:00) Jakarta"];
    [timeZoneDict setObject:@"Asia/Novosibirsk" forKey:@"(UTC+07:00) Novosibirsk"];
    [timeZoneDict setObject:@"Asia/Hong_Kong" forKey:@"(UTC+08:00) Beijing"];
    [timeZoneDict setObject:@"Asia/Chongqing" forKey:@"(UTC+08:00) Chongqing"];
    [timeZoneDict setObject:@"Asia/Hong_Kong" forKey:@"(UTC+08:00) Hong Kong"];
    [timeZoneDict setObject:@"Asia/Krasnoyarsk" forKey:@"(UTC+08:00) Krasnoyarsk"];
    [timeZoneDict setObject:@"Asia/Kuala_Lumpur" forKey:@"(UTC+08:00) Kuala Lumpur"];
    [timeZoneDict setObject:@"Australia/Perth" forKey:@"(UTC+08:00) Perth"];
    [timeZoneDict setObject:@"Asia/Singapore" forKey:@"(UTC+08:00) Singapore"];
    [timeZoneDict setObject:@"Asia/Taipei" forKey:@"(UTC+08:00) Taipei"];
    [timeZoneDict setObject:@"Asia/Ulan_Bator" forKey:@"(UTC+08:00) Ulaan Bataar"];
    [timeZoneDict setObject:@"Asia/Urumqi" forKey:@"(UTC+08:00) Urumqi"];
    [timeZoneDict setObject:@"Asia/Irkutsk" forKey:@"(UTC+09:00) Irkutsk"];
    [timeZoneDict setObject:@"Asia/Tokyo" forKey:@"(UTC+09:00) Osaka"];
    [timeZoneDict setObject:@"Asia/Tokyo" forKey:@"(UTC+09:00) Sapporo"];
    [timeZoneDict setObject:@"Asia/Seoul" forKey:@"(UTC+09:00) Seoul"];
    [timeZoneDict setObject:@"Asia/Tokyo" forKey:@"(UTC+09:00) Tokyo"];
    [timeZoneDict setObject:@"Australia/Adelaide" forKey:@"(UTC+09:30) Adelaide"];
    [timeZoneDict setObject:@"Australia/Darwin" forKey:@"(UTC+09:30) Darwin"];
    [timeZoneDict setObject:@"Australia/Brisbane" forKey:@"(UTC+10:00) Brisbane"];
    [timeZoneDict setObject:@"Australia/Canberra" forKey:@"(UTC+10:00) Canberra"];
    [timeZoneDict setObject:@"Pacific/Guam" forKey:@"(UTC+10:00) Guam"];
    [timeZoneDict setObject:@"Australia/Hobart" forKey:@"(UTC+10:00) Hobart"];
    [timeZoneDict setObject:@"Australia/Melbourne" forKey:@"(UTC+10:00) Melbourne"];
    [timeZoneDict setObject:@"Pacific/Port_Moresby" forKey:@"(UTC+10:00) Port Moresby"];
    [timeZoneDict setObject:@"Australia/Sydney" forKey:@"(UTC+10:00) Sydney"];
    [timeZoneDict setObject:@"Asia/Yakutsk" forKey:@"(UTC+10:00) Yakutsk"];
    [timeZoneDict setObject:@"Asia/Vladivostok" forKey:@"(UTC+11:00) Vladivostok"];
    [timeZoneDict setObject:@"Pacific/Auckland" forKey:@"(UTC+12:00) Auckland"];
    [timeZoneDict setObject:@"Pacific/Fiji" forKey:@"(UTC+12:00) Fiji"];
    [timeZoneDict setObject:@"Pacific/Kwajalein" forKey:@"(UTC+12:00) International Date Line West"];
    [timeZoneDict setObject:@"Asia/Kamchatka" forKey:@"(UTC+12:00) Kamchatka"];
    [timeZoneDict setObject:@"Asia/Magadan" forKey:@"(UTC+12:00) Magadan"];
    [timeZoneDict setObject:@"Pacific/Fiji" forKey:@"(UTC+12:00) Marshall Is."];
    [timeZoneDict setObject:@"Asia/Magadan" forKey:@"(UTC+12:00) New Caledonia"];
    [timeZoneDict setObject:@"Asia/Magadan" forKey:@"(UTC+12:00) Solomon Is."];
    [timeZoneDict setObject:@"Pacific/Auckland" forKey:@"(UTC+12:00) Wellington"];
    [timeZoneDict setObject:@"Pacific/Tongatapu" forKey:@"(UTC+13:00) Nuku'alofa"];
    
    // Display the current TimeZone
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSString *tzName = [timeZone name];
    NSString *localTzName = [[timeZoneDict allKeysForObject:tzName] firstObject];
    [self.btnSelectTimeZone setTitle:localTzName forState:UIControlStateNormal];
    
    // Get ISO code from mobile SIM
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSString *isoCode = [[carrier isoCountryCode] uppercaseString];
    
    // Get the list of country codes
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countrycodes" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    arrForCountry = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    // Filter the phone code using the ISO Country code
    NSString *keyForType = @"alpha-2";
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K like %@",keyForType,isoCode];
    
    NSArray *filteredContacts = [arrForCountry filteredArrayUsingPredicate:filter];
    
    // Change the Button name to the currnt phone code
    NSString *phoneCode;
    if ([filteredContacts count] > 0) {
        phoneCode = [[filteredContacts valueForKey:@"phone-code"] firstObject];
        [self.btnCountryCode setTitle:phoneCode forState:UIControlStateNormal];
    }
    
}

@end
