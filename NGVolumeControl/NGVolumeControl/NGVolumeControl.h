//
//  NGVolumeControl.h
//  NGVolumeControl
//
//  Created by Tretter Matthias on 28.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGVolumeControlExpandDirection.h"

/**
 A custom volume control that features a quick-select gesture to change the system volume
 */
@interface NGVolumeControl : UIControl

/** The system volume, between 0.0f and 1.0f */
@property (nonatomic, assign) float volume;

/** The expand direction of the volume slider, either up or down */
@property (nonatomic, assign) NGVolumeControlExpandDirection expandDirection;
/** Flag whether the volume control is currently expanded */
@property (nonatomic, assign) BOOL expanded;

/** The height of the expanded volume slider */
@property (nonatomic, assign) CGFloat sliderHeight;

/** The color of the slider track below the current value, defaults to white */
@property (nonatomic, strong) UIColor *minimumTrackColor;
/** The color of the slider track above the current value, defaults to gray */
@property (nonatomic, strong) UIColor *maximumTrackColor;

/**
 Prevents the system audio change popup from showing up by adding a (hidden) MPVolumeView
 to the first window.
 */
+ (void)preventSystemVolumePopup;

- (void)setExpanded:(BOOL)expanded animated:(BOOL)animated;

@end
