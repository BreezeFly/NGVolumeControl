#import "NGVolumeControl.h"
#import "NGGeometryFunctions.h"


#define NGSystemVolumeDidChangeNotification         @"AVSystemController_SystemVolumeDidChangeNotification"
#define kNGSliderWidth                              40.f
#define kNGSliderHeight                            150.f
#define kNGMinimumSlideDistance                     15.f
#define kNGShadowRadius                             10.f


@interface NGVolumeControl ()

@property (nonatomic, strong) UIImageView *volumeImageView;
@property (nonatomic, strong) UIView *sliderView;
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, assign) float systemVolume;
@property (nonatomic, readonly) BOOL sliderVisible;

@property (nonatomic, assign) CGPoint touchStartPoint;
@property (nonatomic, assign) BOOL touchesMoved;

- (UIImage *)imageForVolume:(float)volume;

- (void)showSliderAnimated:(BOOL)animated;
- (void)hideSliderAnimated:(BOOL)animated;
- (void)toggleSliderAnimated:(BOOL)animated;

- (void)systemVolumeChanged:(NSNotification *)notification;
- (void)handleSliderValueChanged:(id)sender;

- (void)updateUI;

@end


@implementation NGVolumeControl

@synthesize expandDirection = _expandDirection;
@synthesize expanded = _expanded;
@synthesize volumeImageView = _volumeImageView;
@synthesize sliderView = _sliderView;
@synthesize slider = _slider;
@synthesize touchStartPoint = _touchStartPoint;
@synthesize touchesMoved = _touchesMoved;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        // TODO: respect direction
        _expandDirection = NGVolumeControlExpandDirectionUp;
        _expanded = NO;
        _touchesMoved = NO;
        _touchStartPoint = CGPointZero;
        
        _volumeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, 21.f, 23.f)];
        _volumeImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        _volumeImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_volumeImageView];
        
        CGRect sliderViewFrame = CGRectMake(0, -kNGSliderHeight, frame.size.width, kNGSliderHeight);
        _sliderView = [[UIView alloc] initWithFrame:sliderViewFrame];
        _sliderView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4f];
        [self hideSliderAnimated:NO];
        [self addSubview:_sliderView];
        
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(0.f, 0.f, kNGSliderHeight, kNGSliderWidth)];
        _slider.minimumValue = 0.f;
        _slider.maximumValue = 1.f;
        _slider.transform = CGAffineTransformMakeRotation(-M_PI/2.f);
        _slider.center = CGPointMake(_sliderView.frame.size.width/2.f, _sliderView.frame.size.height/2.f);
        [_slider addTarget:self action:@selector(handleSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        /*_slider.thumbTintColor = [UIColor redColor];
         _slider.minimumTrackTintColor = [UIColor whiteColor];
         _slider.maximumTrackTintColor = [UIColor darkGrayColor];*/
        [_sliderView addSubview:_slider];
        
        // set properties of glow Layer
        CALayer *glowLayer = self.layer;
        if ([glowLayer respondsToSelector:@selector(setShadowPath:)] && [glowLayer respondsToSelector:@selector(shadowPath)]) {
            CGMutablePathRef path = CGPathCreateMutable();
            
            CGPathAddRect(path, NULL, glowLayer.bounds);
            glowLayer.shadowPath = path;
            glowLayer.shadowOffset = CGSizeZero;
            glowLayer.shadowColor = [UIColor whiteColor].CGColor;
            glowLayer.shadowRadius = kNGShadowRadius;
            
            CGPathRelease(path);
        }
        
        // observe changes to system volume (volume buttons)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(systemVolumeChanged:)
                                                     name:NGSystemVolumeDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NGSystemVolumeDidChangeNotification object:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // if we move to a superview we update the UI
    if (newSuperview != nil) {
        [self updateUI];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    // if we move to a window we update the UI
    if (newWindow != nil) {
        [self updateUI];
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // if the slider is expanded we also have to take the sliderView into account
    BOOL inside = ([super pointInside:point withEvent:event] ||
                   (self.sliderVisible && CGRectContainsPoint(self.sliderView.frame, point)));
    
    if (!inside) {
        self.expanded = NO;
    }
    
    return inside;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIControl
////////////////////////////////////////////////////////////////////////

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.touchStartPoint = [touch locationInView:self];
    
    if (!self.expanded) {
        self.expanded = YES;
        self.touchesMoved = NO;
        self.slider.userInteractionEnabled = NO;
    } else {
        self.expanded = NO;
    }
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.expanded) {
        CGPoint point = [touch locationInView:self.sliderView];
        CGFloat distance = NGDistanceBetweenCGPoints(point, self.touchStartPoint);
        
        if (distance > kNGMinimumSlideDistance) {
            self.touchesMoved = YES;
        }
        
        if (point.y <= kNGSliderHeight) {
            CGFloat percentage = 1.f - (point.y/kNGSliderHeight);

            self.slider.value = percentage;
            self.volume = percentage;
        }    
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.touchesMoved) {
        self.expanded = NO;
        self.touchesMoved = NO;
    }
    
    self.slider.userInteractionEnabled = YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    self.slider.userInteractionEnabled = YES;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    CALayer *glowLayer = self.layer;
    
    if ([glowLayer respondsToSelector:@selector(setShadowPath:)] && [glowLayer respondsToSelector:@selector(shadowPath)]) {
        if (highlighted) {
            glowLayer.shadowOpacity = 0.9f;
        } else {
            glowLayer.shadowOpacity = 0.f;
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGVolumeControl
////////////////////////////////////////////////////////////////////////

- (void)setVolume:(float)volume {
    float maxBound = MIN(volume, 1.f);
    float boundedVolume = MAX(maxBound, 0.f);
    
    self.systemVolume = boundedVolume;
    
    // system volume doesn't work on the simulator, so for testing purposes we
    // set the slider/image directly instead of using system volume as in updateUI
#if TARGET_IPHONE_SIMULATOR
    self.volumeImageView.image = [self imageForVolume:volume];
    self.slider.value = volume;
#else
    [self updateUI];
#endif
}

- (float)volume {
    return self.systemVolume;
}

- (void)setExpanded:(BOOL)expanded {
    if (expanded != _expanded) {
        _expanded = expanded;
        
        if (expanded) {
            [self showSliderAnimated:YES];
        } else {
            [self hideSliderAnimated:YES];
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)setSystemVolume:(float)systemVolume {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    musicPlayer.volume = systemVolume;
}

- (float)systemVolume {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    return musicPlayer.volume;
}

- (UIImage *)imageForVolume:(float)volume {
    // Returns an image that represents the current volume
    if (volume < 0.001f) {
        return [UIImage imageNamed:@"NGVolumeControl.bundle/Volume0"];
    } else if (volume < 0.33f) {
        return [UIImage imageNamed:@"NGVolumeControl.bundle/Volume1"];
    } else if (volume < 0.66f) {
        return [UIImage imageNamed:@"NGVolumeControl.bundle/Volume2"];
    } else {
        return [UIImage imageNamed:@"NGVolumeControl.bundle/Volume3"];
    }
}

- (BOOL)sliderVisible {
    return self.sliderView.alpha > 0.f && !self.sliderView.hidden;
}

- (void)toggleSliderAnimated:(BOOL)animated {
    if (self.sliderVisible) {
        [self hideSliderAnimated:animated];
    } else {
        [self showSliderAnimated:animated];
    }
}

- (void)showSliderAnimated:(BOOL)animated {
    if (self.sliderVisible) {
        return;
    }
    
    // TODO: animated flag
    self.sliderView.alpha = 1.f;
}

- (void)hideSliderAnimated:(BOOL)animated {
    if (!self.sliderVisible) {
        return;
    }
    
    // TODO: animated flag
    self.sliderView.alpha = 0.f;
}

- (void)updateUI {
    // update the UI to reflect the current volume
    self.volumeImageView.image = [self imageForVolume:self.volume];
    self.slider.value = self.volume;
}

- (void)systemVolumeChanged:(NSNotification *)notification {
    // we update the UI when the system volume changed (volume buttons)
    [self updateUI];
}

- (void)handleSliderValueChanged:(id)sender {
    self.volume = self.slider.value;
}

@end
