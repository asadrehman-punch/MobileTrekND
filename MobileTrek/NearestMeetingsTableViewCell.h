//
//  NearestMeetingsTableViewCell.h
//  MobileTrek
//
//  Created by Steven Fisher on 8/15/15.
//  Copyright (c) 2015 RecoveryTrek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NearestMeetingsTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@end