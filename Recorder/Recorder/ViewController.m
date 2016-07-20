//
//  ViewController.m
//  Recorder
//
//  Created by William on 16/7/19.
//  Copyright © 2016年 William. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *recoder;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;

@property (nonatomic,strong) NSString *filePath;

@property (nonatomic,strong) NSTimer *timer;

@end

@implementation ViewController

- (NSString *)filePath
{
    if (!_filePath)
    {
        _filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _filePath = [_filePath stringByAppendingPathComponent:@"user"];
        NSFileManager *manage = [NSFileManager defaultManager];
        if ([manage createDirectoryAtPath:_filePath withIntermediateDirectories:YES attributes:nil error:nil])
        {
            _filePath = [_filePath stringByAppendingPathComponent:@"testAudio.aac"];
        }
    }
    
    return _filePath;
}

- (NSDictionary *)audioRecordingSettings{
    
    //设定录制信息
    //录音时所必需的参数设置
    NSDictionary *settings = @{
                               /*这个方法如果设置,一点要和上面的文件路径中的格式一致,否则会有问题
                               */
                               AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                               AVSampleRateKey:@44100,
                               AVNumberOfChannelsKey:@1,
                               AVEncoderAudioQualityKey:@(AVAudioQualityMin),
                               };

    return settings;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self audioAndVideo];
//    [self audioAndAudio];
//    [self Recorder];
//    [self initUI];
    
}

- (void)audioAndVideo
{
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"];
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"myPlayer" ofType:@"mp4"];
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    
    AVMutableComposition *compostion = [AVMutableComposition composition];
    AVMutableCompositionTrack *video = [compostion addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:0];
    [video insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject atTime:kCMTimeZero error:nil];
    AVMutableCompositionTrack *audio = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetMediumQuality];
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Audio.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    NSLog(@"%@",session.supportedFileTypes);
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = @"com.apple.quicktime-movie";
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
        {
            // 调用播放方法
            [self playAudio:[NSURL fileURLWithPath:outPutFilePath]];
        }
        else
        {
            NSLog(@"输出错误");
        }
    }];
    
}

- (void)audioAndAudio
{
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"];
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"醉赤壁" ofType:@"mp3"];
    AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
    AVURLAsset *videoAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    
    AVMutableComposition *compostion = [AVMutableComposition composition];
    AVMutableCompositionTrack *video = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [video insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    AVMutableCompositionTrack *audio = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    [audio insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject atTime:kCMTimeZero error:nil];
    
    /*
     批量插入音轨到文件最后
     CMTimeRange range = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
     [video insertTimeRanges:@[[NSValue valueWithCMTimeRange:range],[NSValue valueWithCMTimeRange:range]] ofTracks:@[[videoAsset tracksWithMediaType:AVMediaTypeAudio].firstObject,[audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject] atTime:kCMTimeZero error:nil];
     */
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetAppleM4A];
    NSString *outPutFilePath = [[self.filePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Audio.m4a"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:outPutFilePath error:nil];
    }
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = @"com.apple.m4a-audio";
    session.shouldOptimizeForNetworkUse = YES;
    [session exportAsynchronouslyWithCompletionHandler:^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:outPutFilePath])
        {
            // 调用播放方法
            [self playAudio:[NSURL fileURLWithPath:outPutFilePath]];
        }
        else
        {
            NSLog(@"输出错误");
        }
    }];
    
}

- (void)initUI
{
    UIButton *start = [[UIButton alloc]initWithFrame:CGRectMake(30, 30, 45, 45)];
    [start setBackgroundColor:[UIColor redColor]];
    [start setTitle:@"点我录音" forState:UIControlStateNormal];
    [self.view addSubview:start];
    [start addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];

}

- (void)playAudio:(NSURL *)url
{
    // 传入地址
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.view.frame;
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.view.layer addSublayer:playerLayer];
    // 隐藏提示框 开始播放
    // 播放
    [player play];
}

- (void)Recorder
{
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    NSDictionary *audioDic = [self audioRecordingSettings];
    NSLog(@"%@\r audioDic=%@",url,audioDic);
    self.recoder = [[AVAudioRecorder alloc]initWithURL:url settings:audioDic error:&error];
    self.recoder.delegate = self;
    self.recoder.meteringEnabled = YES;
}

- (void)start
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if ([self.recoder record])
    {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(check) userInfo:nil repeats:YES];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.recoder stop];
        [self.timer invalidate];
    });
}

- (void)check
{
    [_recoder updateMeters];//刷新音量数据
    NSLog(@"平均值%f",pow(10, (0.05 * [_recoder averagePowerForChannel:0])));
    double lowPassResults = pow(10, (0.05 * [_recoder peakPowerForChannel:0]));
    NSLog(@"峰值%lf",lowPassResults);
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag)
    {
        NSURL *url = recorder.url;
        NSError *error;
        NSData *data = [[NSData alloc]initWithContentsOfFile:self.filePath];
        self.audioPlayer = [[AVAudioPlayer alloc]initWithData:data error:&error];
        [self.audioPlayer play];
        NSLog(@"%@",url);
    }
    
}


@end
