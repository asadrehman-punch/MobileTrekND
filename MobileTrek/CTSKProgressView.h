//
//  CTSKProgressView.h
//  MobileTrek
//
//  Created by Steven Fisher on 7/31/15.
//  Copyright (c) 2015 RecoveryTrek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTSKProgressView : UIView

typedef void(^animationComplete)(void);

/**
 * Width of divider markers
 */
@property (nonatomic) float dividerWidth;

/**
 * Height of divider markers
 */
@property (nonatomic) float dividerHeight;

/**
 * Color of the progress
 */
@property (nonatomic) UIColor *progressColor;

/**
 * Color of border
 */
@property (nonatomic) UIColor *borderColor;

/**
 * Color of divider markers
 */
@property (nonatomic) UIColor *dividerColor;

/**
 * Sets progress and starts animation. Be sure to call reset progress if you already have an
 * animation operation running.
 *
 * @param progress Amount of progress to fill.
 * @param duration How long it should take to complete animation (in seconds).
 * @param completionHandler Called when the animation is completed. Use nil if you don't need this.
 */
- (void)setProgress:(float)progress animationDuration:(double)duration completion:(animationComplete)completionHandler;

/**
 * Sets loading and starts animation. Be sure to call reset progress if you already have an
 * animation operation running.
 */
- (void)setLoadingAnimation;

/**
 * Resets the progress to 0 and cleans up layers. Call this before running another progress animation.
 */
- (void)resetProgress;

@end
