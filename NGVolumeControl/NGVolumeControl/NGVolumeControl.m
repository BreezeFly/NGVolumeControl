#import "NGVolumeControl.h"


@interface NGVolumeControl ()

@property (nonatomic, assign) float systemVolume;

- (UIImage *)imageForVolume:(float)volume;

@end


@implementation NGVolumeControl

@synthesize expandDirection = _expandDirection;

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _expandDirection = NGVolumeControlExpandDirectionUp;
    }
    
    return self;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGVolumeControl
////////////////////////////////////////////////////////////////////////

- (void)setVolume:(float)volume {
    float maxBound = MIN(volume, 1.f);
    float boundedVolume = MAX(maxBound, 0.f);
    
    self.systemVolume = boundedVolume;
}

- (float)volume {
    return self.systemVolume;
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
    if (volume < 0.33f) {
        return [UIImage imageNamed:@"NGVolumeControl.bundle/Volume1"];
    } else if (volume < 0.66f) {
        return [UIImage imageNamed:@"NGVolumeControl.bundle/Volume2"];
    } else {
        return [UIImage imageNamed:@"NGVolumeControl.bundle/Volume3"];
    }
}

@end
