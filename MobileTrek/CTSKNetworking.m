//
//  CTSKNetworking.m
//  MobileTrek
//
//  Created by Steven Fisher on 10/19/15.
//  Copyright © 2015 RecoveryTrek. All rights reserved.
//

#import "CTSKNetworking.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#import "NetworkReachability.h"

@implementation CTSKNetworking

+ (BOOL)connectedToNetwork
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	
	if (!didRetrieveFlags)
		return NO;
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	
	if (isReachable && !needsConnection)
		NSLog(@"Connected to internet");
	else
		NSLog(@"Can't find internet connection");
	
	return (isReachable && !needsConnection) ? YES: NO;
}

@end