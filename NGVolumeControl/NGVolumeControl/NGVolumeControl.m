#import "NGVolumeControl.h"


@interface NGVolumeControl ()

@property (nonatomic, assign) float systemVolume;

@end


@implementation NGVolumeControl

////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
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

@end
