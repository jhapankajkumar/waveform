//
//  UIImageView+WaveFormImageView.h
//  TuneIn
//
//  Created by Pankaj on 09/01/18.
//  Copyright © 2018 Aleph-Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface Waveform : NSObject
+ (void) getImageFromMPMediaUrl:(NSURL*) mediaUrl
           completionBlock:(void (^)(UIImage* waveImage))completionBlock;
@end
