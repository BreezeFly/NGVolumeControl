//
//  NGVolumeControlViewController.m
//  NGVolumeControlDemo
//
//  Created by Tretter Matthias on 28.02.12.
//  Copyright (c) 2012 NOUS Wissensmanagement GmbH. All rights reserved.
//

#import "NGVolumeControlViewController.h"
#import "NGVolumeControl.h"

@implementation NGVolumeControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NGVolumeControl *volumeControl = [[NGVolumeControl alloc] initWithFrame:CGRectMake(200, 300, 35.f, 35.f)];
    [self.view addSubview:volumeControl];
}

@end
