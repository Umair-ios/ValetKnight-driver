//
//  SideBarVC.h
//  UberNewDriver
//
//  Created by Deep Gami on 27/09/14.
//  Copyright (c) 2014 Deep Gami. All rights reserved.
//

#import "BaseVC.h"
#import "SWRevealViewController.h"
#import "PickMeUpMapVC.h"

@interface SideBarVC : BaseVC <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) PickMeUpMapVC *ViewObj;
@property (nonatomic, weak) IBOutlet UIImageView *imgProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@end
