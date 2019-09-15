//
//  PreBACCheckListViewController.m
//  MobileTrek
//
//  Created by Steven Fisher on 10/20/15.
//  Copyright © 2015 RecoveryTrek. All rights reserved.
//

#import "PreBACCheckListViewController.h"
#import "MobileTrek-Swift.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface PreBACCheckListViewController ()
@property (strong, nonatomic) IBOutlet UILabel *mainLabel;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *btn1;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@property (weak, nonatomic) IBOutlet UIButton *btn3;
@property (weak, nonatomic) IBOutlet UIButton *btn4;
@property (weak, nonatomic) IBOutlet UIButton *btn5;
@property (weak, nonatomic) IBOutlet UIButton *btn6;
@property (weak, nonatomic) IBOutlet UIButton *btn7;

@property (weak, nonatomic) IBOutlet ButtonBindingLabel *lbl1;
@property (weak, nonatomic) IBOutlet ButtonBindingLabel *lbl2;
@property (weak, nonatomic) IBOutlet ButtonBindingLabel *lbl3;
@property (weak, nonatomic) IBOutlet ButtonBindingLabel *lbl4;
@property (weak, nonatomic) IBOutlet ButtonBindingLabel *lbl5;
@property (weak, nonatomic) IBOutlet ButtonBindingLabel *lbl6;
@property (weak, nonatomic) IBOutlet ButtonBindingLabel *lbl7;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIView *nextButtonFrameView;
@end

@implementation PreBACCheckListViewController
{
	Platform *platformUser;
	MBProgressHUD *hud;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	platformUser = [Platform shared];
	
	[self initializeLayout];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"hasCompletedPreBac"] == YES)
	{
		[self checkAllRadioButtons];
	}
}

- (void)initializeLayout
{
	self.lbl1.bindingButton = self.btn1;
	self.lbl2.bindingButton = self.btn2;
	self.lbl3.bindingButton = self.btn3;
	self.lbl4.bindingButton = self.btn4;
	self.lbl5.bindingButton = self.btn5;
	self.lbl6.bindingButton = self.btn6;
	self.lbl7.bindingButton = self.btn7;
	
	// Set proper background colors
	self.view.backgroundColor = Graphics.backgroundColor;
	self.nextBtn.backgroundColor = Graphics.primaryColor;
	self.nextButtonFrameView.backgroundColor = Graphics.backgroundColor;
}

- (void)viewDidAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    //   navigationController?.navigationBar.barStyle = .default
    
}

- (void)checkAllRadioButtons
{
	for (int i = 0; i < _scrollView.subviews.count; i++)
	{
		if ([[_scrollView.subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
		{
			UIButton *currentButton = (UIButton*)[_scrollView.subviews objectAtIndex:i];
			
			if (currentButton.isSelected == NO)
			{
				[currentButton sendActionsForControlEvents:UIControlEventTouchUpInside];
			}
		}
	}
}

- (NSUInteger)countCheckedRadioButtons
{
	NSUInteger checkedButtons = 0;
	
	for (int i = 0; i < _scrollView.subviews.count; i++)
	{
		if ([[_scrollView.subviews objectAtIndex:i] isKindOfClass:[UIButton class]])
		{
			if (((UIButton *)[_scrollView.subviews objectAtIndex:i]).isSelected == YES)
			{
				checkedButtons++;
			}
		}
	}
	
	return checkedButtons;
}

- (IBAction)btnSwitch:(UIButton *)sender
{
	if (sender.isSelected == YES)
	{
		[sender setImage:[UIImage imageNamed:@"buttonOff.png"] forState:UIControlStateNormal];
		[sender setSelected:NO];
	}
	else
	{
		[sender setImage:[UIImage imageNamed:@"buttonOn.png"] forState:UIControlStateNormal];
		[sender setSelected:YES];
	}
}

- (IBAction)nxtBtn_Clicked:(id)sender
{
	if ([self countCheckedRadioButtons] == 7)
	{
		hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        hud.label.text = @"Preparing Test";
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setBool:YES forKey:@"hasCompletedPreBac"];
		[defaults synchronize];
		
		NSInteger unixTime = [[NSDate date] timeIntervalSince1970];
		NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)unixTime];
		
		UIStoryboard *bacTestSB = NULL;
		
		if ([platformUser.bacDevice isEqualToString:@"Mars"]) {
			bacTestSB = [UIStoryboard storyboardWithName:@"MarsBacTesting" bundle:NULL];
			
			MarsBacViewController *bacTest = [bacTestSB instantiateViewControllerWithIdentifier:@"marsBacTestView"];
			bacTest.showBacLevel = _showBracLevel;
			bacTest.showBacResult = _showBracResult;
			
			[[[NTBACTestResults alloc] initWithBaseUrl:platformUser.baseUrl timeStamp:timeStamp participantId:platformUser.globalPartId]
			 sendRequest:^(NSString * _Nullable inputTime, NSString * _Nullable nextTestTime, BOOL isVideoRequired, NSString * _Nonnull message) {
                 [self->hud hideAnimated:YES];
				 
				 NSLog(@"BACTestResults message = %@", message);
				 
				 if ([message isEqualToString:@"success"] && isVideoRequired == YES) {
					 bacTest.willUseVideo = true;
				 }
				 else {
					 bacTest.willUseVideo = false;
					 
					 NSLog(@"Error while getting next bac test = %@", message);
				 }
				 
				 [self.navigationController pushViewController:bacTest animated:YES];
			 }];
		}
		else {
			bacTestSB = [UIStoryboard storyboardWithName:@"BacTesting" bundle:NULL];
			
			BreathConnectorViewController *bacTest = [bacTestSB instantiateViewControllerWithIdentifier:@"bacTestView"];
			bacTest.showBacLevel = _showBracLevel;
			bacTest.showBacResult = _showBracResult;
			
			[[[NTBACTestResults alloc] initWithBaseUrl:platformUser.baseUrl timeStamp:timeStamp participantId:platformUser.globalPartId]
			 sendRequest:^(NSString * _Nullable inputTime, NSString * _Nullable nextTestTime, BOOL isVideoRequired, NSString * _Nonnull message) {
                 [self->hud hideAnimated:YES];
				 
				 NSLog(@"BACTestResults message = %@", message);
				 
				 if ([message isEqualToString:@"success"] && isVideoRequired == YES) {
					 bacTest.willUseVideo = true;
				 }
				 else {
					 bacTest.willUseVideo = false;
					 
					 NSLog(@"Error while getting next bac test = %@", message);
				 }
				 
				 [self.navigationController pushViewController:bacTest animated:YES];
			 }];
		}
	}
	else
	{
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Agreement Error" message:@"In order to continue to complete a BAC test you must agree to all items in this list." preferredStyle:UIAlertControllerStyleAlert];
		UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
		[alert addAction:okAction];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.navigationController presentViewController:alert animated:YES completion:nil];
		});
	}
}

@end
