//
//  CheckOut.h
//  RecoveryTrek
//
//  Created by Steven Fisher on 8/20/15.
//  Copyright (c) 2015 RecoveryTrek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface CheckOut : UIViewController<CLLocationManagerDelegate>

@property (nonatomic) BOOL isSelfieRequired;
@property (nonatomic) BOOL isSignatureRequired;
@property (nonatomic) BOOL isAttendanceRequired;
@property (nonatomic) BOOL isFormPictureRequired;
@end
