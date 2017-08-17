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

/**
 收到渲染数据
 */
- (void)recieveBarrageDatas:(NSArray *)barrageDatas;

/**
 开始渲染
 */
- (void)renderBarrage;

/**
 是否还存在渲染数据
 */
- (BOOL)haveBarrageDatas;

/**
 清除渲染数据
 */
- (void)clearBarrage;


- (void)resume;

- (void)pause;

- (void)stop;

@end
