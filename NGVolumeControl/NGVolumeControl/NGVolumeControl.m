#import "NGVolumeControl.h"


#define kNGSliderWidth           40.f
#define kNGSliderHeight         100.f

@interface NGVolumeControl ()

@property (nonatomic, strong) UIImageView *volumeImageView;
@property (nonatomic, assign) float systemVolume;
@property (nonatomic, readonly) CGGradientRef gradient;

- (UIImage *)imageForVolume:(float)volume;
- (CGFloat)sliderFillYForVolume:(float)volume;

@end


@implementation NGVolumeControl

@synthesize expandDirection = _expandDirection;
@synthesize expanded = _expanded;
@synthesize volumeImageView = _volumeImageView;
@synthesize fillColor = _fillColor;
@synthesize gradient = _gradient;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _expandDirection = NGVolumeControlExpandDirectionUp;
        _expanded = YES;
        _fillColor = [UIColor blueColor];
        
        _volumeImageView = [[UIImageView alloc] initWithImage:[self imageForVolume:self.volume]];
        _volumeImageView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self addSubview:_volumeImageView];
    }
    
    return self;
}

- (void)dealloc {
    if (_gradient != NULL) {
        CFRelease(_gradient);
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIView
////////////////////////////////////////////////////////////////////////

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);

    CGContextDrawLinearGradient(context, self.gradient, self.bounds.origin, CGPointMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height), 0);
    
    if (self.expanded) {
        CGFloat y = [self sliderFillYForVolume:self.volume];
        CGRect fillRect = CGRectMake(self.center.x - kNGSliderWidth/2.f, y, kNGSliderWidth, kNGSliderHeight - y);
        
        CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
        CGContextFillRect(context, fillRect);
    }
    
    CGContextRestoreGState(context);
}

////////////////////////////////////////////////////////////////////////
#pragma mark - UIControl
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
#pragma mark - NGVolumeControl
////////////////////////////////////////////////////////////////////////

- (void)setVolume:(float)volume {
    float maxBound = MIN(volume, 1.f);
    float boundedVolume = MAX(maxBound, 0.f);
    
    self.systemVolume = boundedVolume;
    [self setNeedsDisplay];
}

- (float)volume {
    return self.systemVolume;
}

- (void)setExpanded:(BOOL)expanded {
    if (expanded != _expanded) {
        _expanded = expanded;
        [self setNeedsDisplay];
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

- (CGFloat)sliderFillYForVolume:(float)volume {
    CGFloat y = 0.f;
    
    switch (self.expandDirection) {
        case NGVolumeControlExpandDirectionUp:
            y = - kNGSliderHeight * volume;
            break;
            
        case NGVolumeControlExpandDirectionDown:
            y = self.bounds.size.height + kNGSliderHeight * volume;
            break;
    }
    
    return y;
}

- (CGGradientRef)gradient {
    if (_gradient == NULL) {
        UIColor *startColor = [UIColor whiteColor];
        UIColor *endColor = [UIColor darkGrayColor];
        CGColorSpaceRef colorSpace = CGColorGetColorSpace(startColor.CGColor);
        NSArray *colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
        
        _gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
    }
    
    return _gradient;
}

@end
