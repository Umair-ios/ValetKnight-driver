//
//  ProfileVC.h
//  UberNewDriver
//
//  Created by My mac on 11/3/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"

@interface ProfileVC : BaseVC <UITextFieldDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;

@property (weak, nonatomic) IBOutlet UIScrollView *ScrollProfile;
@property (weak, nonatomic) IBOutlet UITextField *txtName;

@property (weak, nonatomic) IBOutlet UITextField *txtLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtZip;
@property (weak, nonatomic) IBOutlet UITextField *txtBio;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnLogOut;
@property (weak, nonatomic) IBOutlet UIButton *btnCountryCode;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (IBAction)LogOutBtnPressed:(id)sender;
- (IBAction)editBtnPressed:(id)sender;
- (IBAction)updateBtnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;

- (IBAction)imgPicBtnPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnProPic;


@end