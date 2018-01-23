//
//  ViewController.m
//  AVFoundation_Decode
//
//  Created by 星罗 on 2018/1/23.
//  Copyright © 2018年 星罗. All rights reserved.
//

#import "ViewController.h"
#import "AVDecodeTool.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@property(nonatomic, strong)UIImageView *imageVideoFrame;
@property(nonatomic, strong)AVDecodeTool *decode;
@property(nonatomic, strong)CADisplayLink *displayLink;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    
    [self initAVAsset];
}

- (void)initUI
{
    _imageVideoFrame = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH*9/16)];
    _imageVideoFrame.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_imageVideoFrame];
    
    UIButton *btnPlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [btnPlay setTitle:@"play" forState:UIControlStateNormal];
    [btnPlay setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btnPlay addTarget:self action:@selector(clickBtnPlay) forControlEvents:UIControlEventTouchUpInside];
    btnPlay.center = self.view.center;
    [self.view addSubview:btnPlay];
}

- (void)initAVAsset
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"chenyifaer" ofType:@"mp4"];
    NSURL *urlVideo = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVAsset assetWithURL:urlVideo];
    _decode = [[AVDecodeTool alloc] initWithAsset:asset];
}

- (void)clickBtnPlay
{
    [self initCADisplayLink];
}

- (void)initCADisplayLink
{
    if (_displayLink != nil) {
        [_displayLink invalidate];
    }
    //定义时钟对象
    _displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame)];
    [_displayLink setFrameInterval:3];
    //添加时钟对象到主运行循环
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)updateFrame
{
    CGImageRef cgImage = [_decode getNextFrameWithImageRef];
    [_imageVideoFrame setImage:[UIImage imageWithCGImage:cgImage]];
}

- (void)dealloc
{
    [_decode endDecode];
}


@end
