//
//  OutlineView.m
//  MobileTrek
//
//  Created by Steven Fisher on 7/7/15.
//  Copyright (c) 2015 RecoveryTrek. All rights reserved.
//

#import "OutlineView.h"

@implementation OutlineView
{
    CAShapeLayer *shapeLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    shapeLayer = [CAShapeLayer layer];
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 1.0f;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], [NSNumber numberWithInt:5], nil];
    shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10.0f].CGPath;
    [self.layer addSublayer:shapeLayer];
}

@end