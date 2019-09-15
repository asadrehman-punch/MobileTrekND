//
//  CTSKProgressView.m
//  MobileTrek
//
//  Created by Steven Fisher on 7/31/15.
//  Copyright (c) 2015 RecoveryTrek. All rights reserved.
//

#import "CTSKProgressView.h"

static const CGFloat kBorderWidth = 2.0;

@interface CTSKProgressView()
@property (nonatomic) UIImageView *loadingBufferView;
@end

@implementation CTSKProgressView {
	CAShapeLayer *progressLayer;
}

- (instancetype)init {
	if (self = [super init]) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		[self commonInit];
	}
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	_dividerWidth = 1;
	_dividerHeight = 10;
	_progressColor = [UIColor blueColor];
	_borderColor = [UIColor blackColor];
	_dividerColor = [UIColor blackColor];
	
	self.backgroundColor = [UIColor clearColor];
}

- (void)setupProgressBar {
	[self initializeLayout];
	
	self.clipsToBounds = YES;
	[self.layer setCornerRadius:5];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	[self setupProgressBar];
}

- (void)initializeLayout {
	CAShapeLayer *outerpathLayer = [[CAShapeLayer alloc] init];
	float divWidth = _dividerWidth;
	float divHeight = _dividerHeight;
	
	UIBezierPath *innerPath = [UIBezierPath bezierPathWithRect:self.bounds];
	progressLayer = [[CAShapeLayer alloc] init];
	progressLayer.path = innerPath.CGPath;
	progressLayer.lineWidth = 1.5;
	progressLayer.fillColor = _progressColor.CGColor;
	progressLayer.frame = self.bounds;
	[self.layer addSublayer:progressLayer];
	
	UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(5, 5)];
	outerpathLayer.path = path.CGPath;
	outerpathLayer.fillColor = [UIColor clearColor].CGColor;
	outerpathLayer.strokeColor = _borderColor.CGColor;
	outerpathLayer.lineWidth = kBorderWidth;
	[self.layer addSublayer:outerpathLayer];
	
	CAShapeLayer *lineMarkersLayer = [[CAShapeLayer alloc] init];
	const int dividerCount = 7;
	const float offset = self.bounds.size.width / dividerCount - (dividerCount * divWidth);
	const float borderOffset = 1;
	CGMutablePathRef lineMarkers = CGPathCreateMutable();
	UIBezierPath *tempPath = NULL;
	float curOffset = offset - divWidth;
	float yPos = 0;
	float curDivHeight = divHeight;
	
	for (int x = 0; x < 2; x ++) {
		for (int i = 0; i < dividerCount; i++) {
			curOffset = offset * (i + 1);
			curDivHeight = (i % 2) ? divHeight : divHeight / 2;
			yPos = (x == 0) ? borderOffset : (self.bounds.size.height - curDivHeight) - borderOffset;
			
			tempPath = [UIBezierPath bezierPathWithRect:CGRectMake(curOffset, yPos, divWidth, curDivHeight)];
			CGPathAddPath(lineMarkers, NULL, tempPath.CGPath);
		}
	}
	
	lineMarkersLayer.path = lineMarkers;
	lineMarkersLayer.fillColor = _dividerColor.CGColor;
	
	CGPathRelease(lineMarkers);
	
	[self.layer addSublayer:lineMarkersLayer];
	
	progressLayer.bounds = CGRectMake(progressLayer.bounds.size.width, progressLayer.bounds.origin.y, progressLayer.bounds.size.width, progressLayer.bounds.size.height);
	
	_loadingBufferView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading_buffer.png"]];
	_loadingBufferView.frame = CGRectMake(self.bounds.origin.x - 50, 0, 50, self.bounds.size.height);
	_loadingBufferView.hidden = YES;
	[self addSubview:_loadingBufferView];
}

- (void)setProgress:(float)progress animationDuration:(double)duration completion:(animationComplete)completionHandler {
	CGRect bounds1 = CGRectMake(progressLayer.bounds.size.width, progressLayer.bounds.origin.y, progressLayer.bounds.size.width, progressLayer.bounds.size.height);
	CGRect bounds = CGRectMake(0, progressLayer.bounds.origin.y, progressLayer.bounds.size.width, progressLayer.bounds.size.height);
	
	[CATransaction begin]; {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
		animation.duration = duration;
		animation.fromValue = [NSValue valueWithCGRect:bounds1];
		animation.toValue = [NSValue valueWithCGRect:bounds];
		progressLayer.bounds = bounds;
		
		[CATransaction setCompletionBlock:^{
			if (completionHandler != NULL)
				completionHandler();
		}];
		
		[progressLayer addAnimation:animation forKey:@"bounds"];
	} [CATransaction commit];
}

- (void)resetProgress {
	// Reset to previous background color
	[self setBackgroundColor:[UIColor clearColor]];
	
	// Remove all sublayers
	self.layer.sublayers = nil;
}

- (void)setLoadingAnimation {    
	// Set bg color to desired progress color without calling setter
	self.backgroundColor = _progressColor;
	
	[_loadingBufferView setHidden:NO];
	
	float maxXPosition = self.bounds.size.width + 50;
	
	__block CGRect origPosition = _loadingBufferView.frame;
	
	[UIView animateWithDuration:2 delay:0 options:(UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat | UIViewAnimationCurveLinear) animations:^{
		origPosition.origin.x += maxXPosition;
		self.loadingBufferView.frame = origPosition;
	} completion:^(BOOL finished) {
		self.loadingBufferView.hidden = YES;
	}];
}

@end
