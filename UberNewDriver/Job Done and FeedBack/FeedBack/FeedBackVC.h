//
//  FeedBackVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "RatingBar.h"
#import "SWRevealViewController.h"

@interface FeedBackVC : BaseVC <UITextFieldDelegate,UITextViewDelegate>
{
    RatingBar *ratingView;
}
- (IBAction)submitBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblTask1;
@property (weak, nonatomic) IBOutlet UILabel *lblTask2;
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblLastName;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;
@property (nonatomic,strong) NSMutableDictionary *dictWalkInfo;


@property (weak, nonatomic) IBOutlet UITextView *txtComment;


@end
