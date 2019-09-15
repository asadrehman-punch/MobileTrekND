//
//  CheckOutSelfieViewController.m
//  MobileTrek
//
//  Created by Steven Fisher on 7/27/15.
//  Copyright © 2015 RecoveryTrek. All rights reserved.
//

#import "CheckOutSelfieViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <BugfenderSDK/BugfenderSDK.h>
#import "MobileTrek-Swift.h"

@interface CheckOutSelfieViewController ()

@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet CTSKInlineCameraView *backCameraView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIView *backFrameView;

@end

@implementation CheckOutSelfieViewController
{
	Platform *globalPlatform;
	MBProgressHUD *progressHud;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	globalPlatform = [Platform shared];

    [self checkIfCameraServicesAllowed];
	
	[self initializeLayout];
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
	
	self.checkInButton.backgroundColor = Graphics.primaryColor;
	self.backFrameView.backgroundColor = Graphics.backgroundColor;
	
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (IBAction)checkInButton_Tapped:(id)sender
{
	[self.checkInButton setEnabled:NO];
	
	[self.backCameraView capturePicture:^(UIImage *image) {
		[self.backCameraView disconnectCameraPreview];
		
		NSData *imgData = UIImageJPEGRepresentation(image, 0.9);
		NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:0];
        if([self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]){
            if(self.isFormPictureRequired){
                FormPictureController *formPicture = [self.storyboard instantiateViewControllerWithIdentifier:@"formCheckInView"];
                formPicture.selfieUploadURLKey = encodedImageStr;
                [self.navigationController pushViewController:formPicture animated:YES];
            }
            else
            {
                NSLog(@"checking out");
                
                [self checkIn:encodedImageStr];
            }
        }else{
            if (self.isAttendanceRequired)
            {
                AttendanceViewController *checkOutAtt = [self.storyboard instantiateViewControllerWithIdentifier:@"attendanceView"];
                checkOutAtt.selfieUploadURLKey = encodedImageStr;
                checkOutAtt.isSignatureRequired = self.isSignatureRequired;
                [self.navigationController pushViewController:checkOutAtt animated:YES];
            }
            else if (self.isSignatureRequired)
            {
                SignatureViewController *signatureView = [self.storyboard instantiateViewControllerWithIdentifier:@"signatureView"];
                signatureView.selfieUploadURLKey = encodedImageStr;
                [self.navigationController pushViewController:signatureView animated:YES];
            }
            else
            {
                NSLog(@"checking out");

                [self checkIn:encodedImageStr];
            }
        }
	}];
}

- (void)checkIn:(NSString *)selfieUploadURLKey
{
	progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	progressHud.label.text = @"Uploading";
	NTCheckInOutRequest *checkInOutRequest = [[NTCheckInOutRequest alloc] initWithBaseUrl:globalPlatform.baseUrl participantId:globalPlatform.globalPartId
																					  pin:globalPlatform.globalPin checkInType:globalPlatform.checkInType
																				   action:globalPlatform.checkinorout gpsLat:globalPlatform.globalLat
																				  gpsLong:globalPlatform.globalLng meetingType:globalPlatform.meetingType];
	checkInOutRequest.selfie = selfieUploadURLKey;
	[checkInOutRequest sendRequest:^(NSString * _Nonnull message) {
		NSLog(@"CheckInOut Completed. Response = %@", message);

        if ([message isEqualToString:@"success"] || [self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Collection Site Check-Out" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self takeTimeStampForDefaults];

                    // Go to mtrekmenu aka tab bar controller
                 //   MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
                   // [mtrekmenu setIsFromCheckInOut:NO];
                    //[self.navigationController pushViewController:mtrekmenu animated:YES];
                    // [self.navigationController popToRootViewControllerAnimated:true];
                    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
                });
            }];
            [alert addAction:okAction];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self->progressHud hideAnimated:YES];

                [self presentViewController:alert animated:YES completion:nil];
            });
        }
        else {
            NSString *errorMessage = @"An error occurred while saving your record. please try again.";
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // Go to mtrekmenu aka tab bar controller
               // MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
              //  [mtrekmenu setIsFromCheckInOut:NO];
              //  [self.navigationController pushViewController:mtrekmenu animated:YES];
               // [self.navigationController popToRootViewControllerAnimated:true];
                [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            }]];

            [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Retry
                    [self checkIn:selfieUploadURLKey];
                });
            }]];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self->progressHud hideAnimated:YES];

                [self presentViewController:alert animated:YES completion:nil];
            });
        }
	}];
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

- (void)checkIfCameraServicesAllowed
{
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized: {
            BFLog(@"Camera permission authorized");

            // Setup camera
            BFLog(@"Initializing camera");
            [self.backCameraView initializeCameraWithFrontCamera:YES withVideo:NO];
            BFLog(@"showing camera preview");
            [self.backCameraView showLiveCameraPreview];
            break;
        }

        case AVAuthorizationStatusDenied: {
            BFLog(@"Camera permission denied");

            [self displayPermissionDeniedAlert:@"Camera"];
            break;
        }

        case AVAuthorizationStatusRestricted: {
            BFLog(@"Camera permission restricted");

            [self displayedPermissionRestrictedAlert:@"Camera"];
            break;
        }

        case AVAuthorizationStatusNotDetermined: {
            // Setup camera
            BFLog(@"Initializing camera");
            [self.backCameraView initializeCameraWithFrontCamera:YES withVideo:NO];
            BFLog(@"showing camera preview");
            [self.backCameraView showLiveCameraPreview];
            break;
        }
    }
}

- (void)displayPermissionDeniedAlert:(NSString *)permissionName
{
    NSString *permString = [permissionName stringByAppendingString:@" permission"];
    NSString *alertMessage = [permString stringByAppendingString:@"s are required in order to perform a meeting check out. Please update these permissions in app settings."];

    // Tell the user to go to settings to fix permissions
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:permString
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // Pop back since we aren't getting permission from user
        [self.navigationController popViewControllerAnimated:YES];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Open app settings
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:NULL];
    }]];

    [self presentViewController:alert animated:YES completion:NULL];
}

- (void)displayedPermissionRestrictedAlert:(NSString *)permissionName
{
    NSString *permString = [permissionName stringByAppendingString:@" permission"];
    NSString *alertMessage = [permString stringByAppendingString:@"s are restricted. Please make sure that parental controls are disabled in order to perform a BAC test."];

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:permString
                                                                   message:alertMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Pop back
        [self.navigationController popViewControllerAnimated:YES];
    }]];

    [self presentViewController:alert animated:YES completion:NULL];
}

@end
