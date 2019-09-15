//
//  CheckInSelfieViewController.m
//  MobileTrek
//
//  Created by Steven Fisher on 7/27/15.
//  Copyright © 2015 RecoveryTrek. All rights reserved.
//

#import "CheckInSelfieViewController.h"
#import "MobileTrek-Swift.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface CheckInSelfieViewController ()
@property (weak, nonatomic) IBOutlet UIButton *checkInButton;
@property (weak, nonatomic) IBOutlet CTSKInlineCameraView *backCameraView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomFrameView;
@property (weak, nonatomic) IBOutlet UIImageView *silImageView;
@end

@implementation CheckInSelfieViewController
{
	Platform *globalPlatform;
	MBProgressHUD *progressHud;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	globalPlatform = [Platform shared];
	
	[_backCameraView initializeCameraWithFrontCamera:YES withVideo:NO];
	[_backCameraView showLiveCameraPreview];
	
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
	
	[_checkInButton setBackgroundColor:Graphics.primaryColor];
	[_bottomFrameView setBackgroundColor:Graphics.backgroundColor];
	
	self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (IBAction)checkInButton_Tapped:(id)sender
{
	[_checkInButton setEnabled:NO];
	
    progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.label.text = @"Uploading";

    [_backCameraView capturePicture:^(UIImage *image) {
        [self.backCameraView disconnectCameraPreview];

        // Get the base64 of the image
        NSData *imgData = UIImageJPEGRepresentation(image, 0.9);
        NSString *encodedImageStr = [imgData base64EncodedStringWithOptions:0];
        
        if(self.isFormPictureRequired){
            FormPictureController *formView = [self.storyboard instantiateViewControllerWithIdentifier:@"formCheckInView"];
            [formView setIsSignatureRequired:self.isSignatureRequired];
            [formView setSelfieUploadURLKey:encodedImageStr];
            [self.navigationController pushViewController:formView animated:true];
        }
        else if (self.isAttendanceRequired) {
            AttendanceViewController *attendanceView = [self.storyboard instantiateViewControllerWithIdentifier:@"attendanceView"];
            [attendanceView setIsSignatureRequired:self.isSignatureRequired];
            [attendanceView setSelfieUploadURLKey:encodedImageStr];
            [self.navigationController pushViewController:attendanceView animated:true];
        }
        else if (self.isSignatureRequired) {
            SignatureViewController *signatureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signatureView"];
            [signatureVC setSelfieUploadURLKey:encodedImageStr];
            [self.navigationController pushViewController:signatureVC animated:true];
        }
        else {
            [self checkIn:encodedImageStr];
        }
    }];
}

- (void)checkIn:(NSString *)encodedSelfieImg
{
    progressHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progressHud.label.text = @"Uploading";
    NTCheckInOutRequest *checkInOutRequest = [[NTCheckInOutRequest alloc] initWithBaseUrl:self->globalPlatform.baseUrl participantId:self->globalPlatform.globalPartId
                  pin:self->globalPlatform.globalPin checkInType:self->globalPlatform.checkInType
               action:self->globalPlatform.checkinorout gpsLat:self->globalPlatform.globalLat
              gpsLong:self->globalPlatform.globalLng meetingType:self->globalPlatform.meetingType];
    checkInOutRequest.selfie = encodedSelfieImg;
    [checkInOutRequest sendRequest:^(NSString * _Nonnull message) {
        NSLog(@"CheckInOut Completed. Response = %@", message);

        if ([message isEqualToString:@"success"] || [self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDate *timeStamp = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
            
            if (self->globalPlatform.meetingCheckIn
                && !self->globalPlatform.meetingCheckOut) {
                [defaults removeObjectForKey:@"SavedMeetingType"];
                [defaults removeObjectForKey:@"STORED_MEETING_NAME"];
                [defaults removeObjectForKey:@"meetingCheckInTime"];
            }
            else {
                if ([self->globalPlatform.checkInType isEqualToString:@"facilitycheckincheckout"]){
                    [defaults setObject:[formatter stringFromDate:timeStamp] forKey:@"facilityCheckInTime"];
                    [defaults setObject:self->globalPlatform.meetingType forKey:@"SavedMeetingType"];
                }else{
                    [defaults setObject:self->globalPlatform.meetingType forKey:@"SavedMeetingType"];
                    [defaults setObject:[formatter stringFromDate:timeStamp] forKey:@"meetingCheckInTime"];
                }
                
                
            }
            
            [defaults synchronize];

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Collection Site Check-In" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        [self->progressHud hideAnimated:YES];
                    // Go to mtrekmenu aka tab bar controller
                    MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
                    [mtrekmenu setIsFromCheckInOut:NO];
                    //[self.navigationController pushViewController:mtrekmenu animated:YES];
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
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Meeting Check-Out Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // Go to mtrekmenu aka tab bar controller
                MTrekMenuViewController *mtrekmenu = [self.storyboard instantiateViewControllerWithIdentifier:@"mtrekmenu"];
                [mtrekmenu setIsFromCheckInOut:NO];
              //  [self.navigationController pushViewController:mtrekmenu animated:YES];
                [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            }]];

            [alert addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Retry
                    [self checkIn:encodedSelfieImg];
                });
            }]];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

@end
