//
//  AVDecodeTool.m
//  AVFoundation_Decode
//
//  Created by 星罗 on 2018/1/23.
//  Copyright © 2018年 星罗. All rights reserved.
//

#import "AVDecodeTool.h"

@interface AVDecodeTool()
{
    AVAssetTrack *videoTrack;
    AVAssetReaderTrackOutput *videoReaderOutput;
    AVAssetReader *reader;
    AVAsset *assetVideo;
}

@end

@implementation AVDecodeTool

- (instancetype)initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if (self) {
        [self setAsset:asset];
    }
    return self;
}

- (void)setAsset:(AVAsset *)asset
{
    if (asset == nil) {
        NSLog(@"asset 为nil：");
        return;
    }
    _asset = asset;
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self startDecode:asset withSeekSecond:0];
        });
    }];
}

- (void)startDecode:(AVAsset *)asset withSeekSecond:(float)fSeekSecond
{
    NSError *error;
    //获取视频的总轨道
    videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    int pixelFormatType = kCVPixelFormatType_32BGRA;//如果解码后需要直接由OpenGL显示可使用该类型，kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
    
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:@(pixelFormatType) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    
    reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    if([reader canAddOutput:videoReaderOutput]){
        [reader addOutput:videoReaderOutput];
    }
    
    reader.timeRange = CMTimeRangeMake(CMTimeMakeWithSeconds(fSeekSecond, asset.duration.timescale), kCMTimePositiveInfinity);
    //重点：timeRange必须在startReading之前调用，否则无效，在startReading定义的地方有说明
    [reader startReading];
    
}

- (CGImageRef)getNextFrameWithImageRef
{
    // 要确保nominalFrameRate>0
    if ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        // 读取 video sample
        CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
        CGImageRef cgimage = [self updateBufferRef:videoBuffer];
        CFRelease(videoBuffer);
        return cgimage;
    }
    return nil;
}

- (CGImageRef)updateBufferRef:(CMSampleBufferRef)videoBuffer
{
    CGImageRef cgimage = [self imageFromSampleBufferRef:videoBuffer];
    if (!(__bridge id)(cgimage)) { return nil; }
    return cgimage;
}

// AVFoundation 捕捉视频帧，很多时候都需要把某一帧转换成 image
- (CGImageRef)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef
{
    // 为媒体数据设置一个CMSampleBufferRef
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBufferRef);
    // 锁定 pixel buffer 的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到 pixel buffer 的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到 pixel buffer 的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到 pixel buffer 的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    // 创建一个依赖于设备的 RGB 颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphic context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    //根据这个位图 context 中的像素创建一个 Quartz image 对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁 pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // 释放 context 和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return quartzImage;
    
}

- (void)endDecode
{
    [reader cancelReading];
}

@end
