//
//  CheckOut.m
//  RecoveryTrek
//
//  Created by Steven Fisher on 8/20/15.
//  Copyright (c) 2015 RecoveryTrek. All rights reserved.
//

#import "CheckOut.h"
#import "CheckOutSelfieViewController.h"
#import "MobileTrek-Swift.h"
#import <BugfenderSDK/BugfenderSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>
@interface CheckOut () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIView *backFrameView;

@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation CheckOut
{
    Platform *globalPlatform;
    MBProgressHUD *progressHud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    globalPlatform = [Platform shared];
    
    [globalPlatform setCheckinorout:@"checkout"];
    
    [self initializeLayout];
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    self.nextButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
 //   navigationController?.navigationBar.barStyle = .default
    
}

- (void)initializeLayout
{
	// Set background color
	[self.view setBackgroundColor:Graphics.backgroundColor];
	
	// Set background color for accents and navbar
	[self.navigationController.navigationBar setBarTintColor:Graphics.primaryColor];
	self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self.nextButton setBackgroundColor:Graphics.primaryColor];
	[self.backFrameView setBackgroundColor:Graphics.backgroundColor];
	
	if ([globalPlatform.checkInType isEqualToString:@"meetingcheckincheckout"])
	{
		if (!_isSelfieRequired && !_isAttendanceRequired && !_isSignatureRequired)
			[self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
	}
	else
	{
		if (!_isSelfieRequired)
			[self.nextButton setTitle:@"Done" forState:UIControlStateNormal];
	}
	
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (IBAction)nextButtonTapped:(id)sender
{
	if ([globalPlatform.checkInType isEqualToString:@"meetingcheckincheckout"])
	{
		if (_isSelfieRequired)
		{
			CheckOutSelfieViewController *checkOutSelfie = [self.storyboard instantiateViewControllerWithIdentifier:@"checkOutSelfie"];
			checkOutSelfie.isAttendanceRequired = _isAttendanceRequired;
			checkOutSelfie.isSignatureRequired = _isSignatureRequired;
			[self.navigationController pushViewController:checkOutSelfie animated:YES];
		}
        
		else if (_isAttendanceRequired)
		{
			AttendanceViewController *checkOutAtt = [self.storyboard instantiateViewControllerWithIdentifier:@"attendanceView"];
			checkOutAtt.isSignatureRequired = _isSignatureRequired;
			[self.navigationController pushViewController:checkOutAtt animated:YES];
		}
		else if (_isSignatureRequired)
		{
			SignatureViewController *signatureView = [self.storyboard instantiateViewControllerWithIdentifier:@"signatureView"];
			[self.navigationController pushViewController:signatureView animated:YES];
		}
		else
		{
            progressHud = nil;
            progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            progressHud.label.text = @"Uploading";
			NTCheckInOutRequest *checkInOutRequest = [[NTCheckInOutRequest alloc] initWithBaseUrl:globalPlatform.baseUrl participantId:globalPlatform.globalPartId
																							  pin:globalPlatform.globalPin checkInType:globalPlatform.checkInType
																						   action:globalPlatform.checkinorout gpsLat:globalPlatform.globalLat
																						  gpsLong:globalPlatform.globalLng meetingType:globalPlatform.meetingType];
			
			[checkInOutRequest sendRequest:^(NSString * _Nonnull message) {
				NSLog(@"CheckInOut Completed. Response = %@", message);
                [self->progressHud hideAnimated:true];
                 NSString *title = nil;
                if ([message isEqualToString:@"success"] || [self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]) {
                    [self takeTimeStampForDefaults];

                   
                    if ([self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]){
                        title = @"Collection Site Check-Out";
                    }else{
                        title = @"Meeting Check-Out";
                    }
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Go to mtrekmenu aka tab bar controller
                            MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
                            [mtrekmenu setIsFromCheckInOut:YES];
                           // [self.navigationController pushViewController:mtrekmenu animated:YES];
                            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
                        });
                    }];
                    [alert addAction:okAction];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                }
                else {
                    NSString *errorMessage = @"An error occurred while saving your meeting record. Your meeting was not recorded, please try again.";
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errorMessage preferredStyle:UIAlertControllerStyleAlert];

                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        // Go to mtrekmenu aka tab bar controller
                        MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
                       
                        if ([title isEqualToString:@"Meeting Check-Out"]){
                            [mtrekmenu setIsFromCheckInOut:YES];
                        }else{
                            [mtrekmenu setIsFromCheckInOut:NO];
                        }
                        [mtrekmenu setIsFromCheckInOut:YES];
                      //  [self.navigationController pushViewController:mtrekmenu animated:YES];
                        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
                    }]];

                    [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Retry
                            [self nextButtonTapped:nil];
                        });
                    }]];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                }
			}];
		}
	}
	else
	{
		if (_isSelfieRequired)
		{
			CheckOutSelfieViewController *checkOutSelfie = [self.storyboard instantiateViewControllerWithIdentifier:@"checkOutSelfie"];
            checkOutSelfie.isFormPictureRequired = _isFormPictureRequired;
			[self.navigationController pushViewController:checkOutSelfie animated:YES];
		}
        else if (_isFormPictureRequired)
        {
            FormPictureController *formPicture = [self.storyboard instantiateViewControllerWithIdentifier:@"formCheckInView"];
            [self.navigationController pushViewController:formPicture animated:YES];
        }
		else
		{
            progressHud = nil;
            progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            progressHud.label.text = @"Uploading";

			NTCheckInOutRequest *checkInOutRequest = [[NTCheckInOutRequest alloc] initWithBaseUrl:globalPlatform.baseUrl participantId:globalPlatform.globalPartId
																							  pin:globalPlatform.globalPin checkInType:globalPlatform.checkInType
																						   action:globalPlatform.checkinorout gpsLat:globalPlatform.globalLat
																						  gpsLong:globalPlatform.globalLng meetingType:globalPlatform.meetingType];
			
			[checkInOutRequest sendRequest:^(NSString * _Nonnull message) {
                [self->progressHud hideAnimated:true];
				NSLog(@"CheckInOut Completed. Response = %@", message);
                NSString *title = nil;
                if ([message isEqualToString:@"success"] || [self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]) {
                    [self takeTimeStampForDefaults];
                    
                    
                    if ([self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]){
                        title = @"Collection Site Check-Out";
                    }else{
                        title = @"Meeting Check-Out";
                    }

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Go to mtrekmenu aka tab bar controller
                            MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
                            if ([title isEqualToString:@"Meeting Check-Out"]){
                                [mtrekmenu setIsFromCheckInOut:YES];
                            }else{
                                [mtrekmenu setIsFromCheckInOut:NO];
                            }
                          //  [self.navigationController pushViewController:mtrekmenu animated:YES];
                            [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
                        });
                    }];
                    [alert addAction:okAction];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                }
                else {
                    NSString *errorMessage = @"An error occurred while saving your meeting record. Your meeting was not recorded, please try again.";
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:errorMessage preferredStyle:UIAlertControllerStyleAlert];

                    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        // Go to mtrekmenu aka tab bar controller
                        MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
                        [mtrekmenu setIsFromCheckInOut:YES];
                      //  [self.navigationController pushViewController:mtrekmenu animated:YES];
                        [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
                    }]];

                    [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Retry
                            [self nextButtonTapped:nil];
                        });
                    }]];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:alert animated:YES completion:nil];
                    });
                }
			}];
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Error" message:@"Failed to get your location. To continue please allow location permissions through the iOS Settings Application." preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self.navigationController popViewControllerAnimated:YES];
	}];
	
	UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
	}];
	
	[alert addAction:action];
	[alert addAction:settingsAction];
	
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [manager stopUpdatingLocation];

    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation != nil)
    {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude,
                                                                  currentLocation.coordinate.longitude);

        globalPlatform.globalLat = @(coord.latitude).stringValue;
        globalPlatform.globalLng = @(coord.longitude).stringValue;

        MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
        MKCoordinateRegion region = MKCoordinateRegionMake(coord, span);

        self.mapView.showsUserLocation = YES;
        self.mapView.mapType = MKMapTypeHybrid;
        [self.mapView setRegion:region animated:NO];
    }
    else {
        BFLog(@"Unable to grab current location");

        globalPlatform.globalLat = @"0";
        globalPlatform.globalLng = @"0";
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_nextButton setEnabled:YES];
    });
}

- (void)takeTimeStampForDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *timeStamp = [NSDate date];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
	
	NSLog(@"Date TimeStamp: %@", [formatter stringFromDate:timeStamp]);
	
	// Check if facility or meeting
	if ([globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"])
	{
		// Set timestamp for facility
		[defaults setObject:[formatter stringFromDate:timeStamp] forKey:@"facilityCheckOutTime"];
		[defaults synchronize];
	}
	else
	{
		// Set timestamp for meeting
		[defaults setObject:[formatter stringFromDate:timeStamp] forKey:@"meetingCheckOutTime"];
		[defaults removeObjectForKey:@"SavedMeetingType"];
		[defaults removeObjectForKey:@"STORED_MEETING_NAME"];
		[defaults removeObjectForKey:@"meetingCheckInTime"];
		[defaults synchronize];
	}
}

@end
