//
//  BACTest.h
//  SQLiteTestProject
//
//  Created by Steven Fisher on 10/19/15.
//  Copyright © 2015 Construkt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BACTest : NSObject

@property (nonatomic) NSInteger sid;
@property (strong, nonatomic, nonnull) NSString *programURL;
@property (strong, nonatomic, nonnull) NSString *partId;
@property (strong, nonatomic, nonnull) NSString *partPin;
@property (strong, nonatomic, nonnull) NSString *gpsLat;
@property (strong, nonatomic, nonnull) NSString *gpsLong;
@property (strong, nonatomic, nonnull) NSString *bracLevel;
@property (strong, nonatomic, nonnull) NSString *bracResult;
@property (strong, nonatomic, nullable) NSString *encodedPicture;
@property (strong, nonatomic, nullable) NSString *imageUrl;
@property (strong, nonatomic, nullable) NSString *videoUrl;
@property (strong, nonatomic, nonnull) NSString *submitted;
@property (strong, nonatomic, nullable) NSString *bacDeviceId;

- (id _Nonnull)initWithParticipantInfo:(NSInteger)sid
                            programURL:(NSString * _Nonnull)programURL
                                partId:(NSString * _Nonnull)partId
                               partPin:(NSString * _Nonnull)partPin
                                gpsLat:(NSString * _Nonnull)gpsLat
                               gpsLong:(NSString * _Nonnull)gpsLong
                             bracLevel:(NSString * _Nonnull)bracLevel
                            bracResult:(NSString * _Nonnull)bracResult
                             submitted:(NSString * _Nonnull)submitted
                           bacDeviceId:(NSString * _Nullable)bacDeviceId;

@end
