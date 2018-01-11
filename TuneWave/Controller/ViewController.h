//
//  ViewController.h
//  TuneWave
//
//  Created by Pankaj on 10/01/18.
//  Copyright © 2018 Aleph-Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController<MPMediaPickerControllerDelegate,
AVAudioPlayerDelegate,
UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *waveImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *waveScrollView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

- (IBAction)playPauseSong:(UIButton*)sender;
@property (weak, nonatomic) IBOutlet UIView *songDetailContainer;
@property (weak, nonatomic) IBOutlet UIImageView *artWorkImage;
@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *singerName;

@property (weak, nonatomic) IBOutlet UIView *trackIndicatorView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraints;

@end

