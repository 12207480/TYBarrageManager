//
//  BarrageRenderView.h
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarrageViewCell.h"

@interface BarrageRenderView : UIView

// 渲染层优先级，高的在前面
@property (nonatomic, assign, readonly) BarragePriority priority;

// 最大航道数
@property (nonatomic, assign) NSInteger maxChannelCount;
// 航道高度
@property (nonatomic, assign) NSInteger channelHeight;

// 第一航道top边距
@property (nonatomic, assign) NSInteger firstChannelTopEdge;
// 最后航道bottom边距
@property (nonatomic, assign) NSInteger lastChannelBottomEdge;

// 最大当前准备渲染数
@property (nonatomic, assign) NSInteger maxBarrageDataCount;
// 最大当前等待渲染数
@property (nonatomic, assign) NSInteger maxBufferBarrageDataCount;


/**
 准备渲染
 */
- (void)prepareRenderBarrage;

- (void)recieveBarrageDatas:(NSArray *)barrageDatas;

- (BOOL)haveBarrageDatas;

- (void)renderBarrage;

- (void)clearBarrage;

- (void)resume;

- (void)pause;

- (void)stop;

@end
