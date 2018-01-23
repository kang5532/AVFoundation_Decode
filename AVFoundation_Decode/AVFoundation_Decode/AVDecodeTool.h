//
//  AVDecodeTool.h
//  AVFoundation_Decode
//
//  Created by 星罗 on 2018/1/23.
//  Copyright © 2018年 星罗. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVDecodeTool : NSObject

- (instancetype)initWithAsset:(AVAsset *)asset;

@property(nonatomic, strong)AVAsset *asset;

- (CGImageRef)getNextFrameWithImageRef; //依次获取帧序列

- (void)endDecode;

@end
