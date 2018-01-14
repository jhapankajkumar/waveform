//
//  ViewController.m
//  TuneWave
//
//  Created by Pankaj on 10/01/18.
//  Copyright © 2018 Aleph-Labs. All rights reserved.
//

#import "ViewController.h"
#import "WaveForm.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define kPadding 10
#define kArtWorkImageDimension 100

@interface ViewController () {
    MPMediaItem *selectedMediaItem;
    AVPlayer *mediaPlayer;
    NSTimer * timer;
    double pixelCrossed;
    UIImageView *bigWaveImageView;
    NSURL *selectedMediaUrl;
    BOOL isVideoSelected;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _songDetailContainer.hidden = true;
    self.waveScrollView.delegate = self;
    self.playPauseButton.enabled = false;
    self.playPauseButton.alpha = 0.7;
    
}

#pragma mark - IBActions
- (IBAction)importMusic:(id)sender {
    
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"Choose Media" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Music Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectAudio];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Video Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self selectVideo];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)playPauseSong:(UIButton *)sender {
    if (!sender.selected) {
        sender.selected = true;
        [self playAudio];
    }
    else {
        sender.selected = false;
        [self pauseAudio];
    }
}


-(void)selectAudio {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = NO;
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

-(void)selectVideo {
    // Present videos from which to choose
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self; // ensure you set the delegate so when a video is chosen the right method can be called
    
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    // This code ensures only videos are shown to the end user
    videoPicker.mediaTypes = @[(NSString*)kUTTypeMovie, (NSString*)kUTTypeAVIMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeMPEG4];
    
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    [self presentViewController:videoPicker animated:YES completion:nil];

}



#pragma mark - MediaPicker Delegates
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    selectedMediaItem = [mediaItemCollection representativeItem];
    selectedMediaUrl = selectedMediaItem.assetURL;
    [self setMediaInformation];
    [self showWaveForm];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    isVideoSelected = true;
    // This is the NSURL of the video object
    NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
    selectedMediaUrl = videoURL;
    [self showWaveForm];
    NSLog(@"VideoURL = %@", videoURL);
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - UI-Update Methods
-(void)setupWaveImage:(UIImage *)waveImage {
    self.waveImageView.image = waveImage;
    [bigWaveImageView removeFromSuperview];
    bigWaveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, kPadding, waveImage.size.width,self.waveScrollView.frame.size.height-(kPadding * 2))];
    bigWaveImageView.image = waveImage;
    [self.waveScrollView addSubview:bigWaveImageView];
    [self.waveScrollView setContentSize:CGSizeMake(waveImage.size.width + self.waveScrollView.frame.size.width, self.waveScrollView.frame.size.height)];

    [self startMediaPlayer];
}

-(void)startMediaPlayer {
    
    [mediaPlayer pause];
    mediaPlayer = nil;
    mediaPlayer = [[AVPlayer alloc]initWithURL:selectedMediaUrl];
    self.playPauseButton.enabled = true;
    self.playPauseButton.alpha = 1.0;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(mediaFailedToPlayTillEnd) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    
    
}

-(void)setMediaInformation {
    
    self.songDetailContainer.hidden = false;
    NSString *artist = [selectedMediaItem valueForProperty:MPMediaItemPropertyAlbumArtist];
    NSString *title = [selectedMediaItem valueForProperty:MPMediaItemPropertyTitle];
    self.songName.text = title;
    self.singerName.text = artist;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        MPMediaItemArtwork* artwork = [selectedMediaItem valueForProperty:MPMediaItemPropertyArtwork];
        if ( !artwork || artwork.bounds.size.width == 0 ) {
            // try album artwork
            NSNumber* albumID = [selectedMediaItem valueForProperty:MPMediaItemPropertyAlbumPersistentID];
            MPMediaQuery*   mediaQuery = [MPMediaQuery albumsQuery];
            MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue:albumID forProperty:MPMediaItemPropertyAlbumPersistentID];
            [mediaQuery addFilterPredicate:predicate];
            NSArray* arrMediaItems = [mediaQuery items];
            if ( [arrMediaItems count] > 0 ) {
                artwork = [[arrMediaItems objectAtIndex:0] valueForProperty:MPMediaItemPropertyArtwork];
                if ( artwork ) {
                    int nBreak = 0;
                    nBreak++;
                }
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if ( artwork && artwork.bounds.size.width > 0 ) {
                UIImage *image = [artwork imageWithSize:CGSizeMake(kArtWorkImageDimension, kArtWorkImageDimension)];
                self.artWorkImage.image = image;
            }
            
        });
    });
    
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}


-(void) showWaveForm {
    
    [Waveform getImageFromMPMediaUrl:selectedMediaUrl completionBlock:^(UIImage* waveImage){
        [self resetMediaPlayer];
        [self setupWaveImage:waveImage];
        
    }];
}


#pragma mark - AudioPlayerDelegates
- (void)mediaFinishedPlaying {
    [self resetMediaPlayer];
}

-(void)mediaFailedToPlayTillEnd {
    //Error
}

-(void)resetMediaPlayer {
    [timer invalidate];
    [self.waveScrollView setContentOffset:CGPointMake(0, 0) animated:true];
    self.playPauseButton.selected = false;
    self.timeLabel.text =  @"00:00:00";
    pixelCrossed = 0.0;
    _leadingConstraints.constant = 0;
}

-(void)updateTrack {
    double perPixel =  [[NSUserDefaults standardUserDefaults] doubleForKey:@"samplePerPixel"];
    pixelCrossed =  CMTimeGetSeconds(mediaPlayer.currentTime) * perPixel;
    CGRect rect = CGRectMake(pixelCrossed, 0, self.waveScrollView.frame.size.width, self.waveScrollView.frame.size.height);
    [self.waveScrollView setContentOffset:rect.origin animated:true];
    _timeLabel.text = [self stringFromTimeInterval:pixelCrossed];
    
    double multiPlier = bigWaveImageView.image.size.width/self.waveImageView.frame.size.width;
    
    NSInteger movePositionX = pixelCrossed/multiPlier;
    _leadingConstraints.constant = movePositionX;
}

-(void)playAudio {
    
    [mediaPlayer play];
    self.playPauseButton.selected = true;
    
    if (![timer isValid]) {
        timer  =  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTrack) userInfo:nil repeats:YES];
    }
}

-(void)pauseAudio{
    [mediaPlayer pause];
    self.playPauseButton.selected = false;
    [timer invalidate];
}

#pragma mark - ScrollViewDelegates

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self adjustScrollViewWhenSeek:scrollView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self adjustScrollViewWhenSeek:scrollView];
}

-(void)adjustScrollViewWhenSeek:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    int xCoordinate = offset.x + scrollView.frame.size.width/2;
    double perPixel =  [[NSUserDefaults standardUserDefaults] doubleForKey:@"samplePerPixel"];
    NSTimeInterval duration = xCoordinate/perPixel;
    [scrollView setContentOffset:offset];
    [mediaPlayer seekToTime: CMTimeMake(duration, 1)];
    _timeLabel.text = [self stringFromTimeInterval:duration];
}

@end
