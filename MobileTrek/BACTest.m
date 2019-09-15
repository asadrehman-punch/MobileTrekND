//
//  BACTest.m
//  SQLiteTestProject
//
//  Created by Steven Fisher on 10/19/15.
//  Copyright © 2015 Construkt. All rights reserved.
//

#import "BACTest.h"

@implementation BACTest

- (id)initWithParticipantInfo:(NSInteger)sid
                   programURL:(NSString *)programURL
                       partId:(NSString *)partId
                      partPin:(NSString *)partPin
                       gpsLat:(NSString *)gpsLat
                      gpsLong:(NSString *)gpsLong
                    bracLevel:(NSString *)bracLevel
                   bracResult:(NSString *)bracResult
                    submitted:(NSString *)submitted
                  bacDeviceId:(NSString * _Nullable)bacDeviceId
{
	self = [super init];
	if (self)
	{
		self.sid = sid;
		self.programURL = programURL;
		self.partId = partId;
		self.partPin = partPin;
		self.gpsLat = gpsLat;
		self.gpsLong = gpsLong;
		self.bracLevel = bracLevel;
		self.bracResult = bracResult;
		self.submitted = submitted;
        self.bacDeviceId = bacDeviceId;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@",
			[NSString stringWithFormat:@"{ SID: %ld, ", (long)self.sid],
			[NSString stringWithFormat:@"Program URL: %@, ", self.programURL],
			[NSString stringWithFormat:@"Participant ID: %@, ", self.partId],
			[NSString stringWithFormat:@"Pin: %@, ", self.partPin],
			[NSString stringWithFormat:@"GPS Lat: %@, ", self.gpsLat],
			[NSString stringWithFormat:@"GPS Lng: %@, ", self.gpsLong],
			[NSString stringWithFormat:@"BrAC Level: %@, ", self.bracLevel],
			[NSString stringWithFormat:@"BrAC Result: %@, ", self.bracResult],
			[NSString stringWithFormat:@"Image: %@, ", (self.imageUrl == NULL) ? @"null" : self.imageUrl],
			[NSString stringWithFormat:@"Video: %@, ", (self.videoUrl == NULL) ? @"null" : self.videoUrl],
			[NSString stringWithFormat:@"Submitted: %@, ", self.submitted],
            [NSString stringWithFormat:@"BAC Device UUID: %@ }", (_bacDeviceId == NULL) ? @"null" : _bacDeviceId]];
}

@end
