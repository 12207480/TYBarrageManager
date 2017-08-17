//
//  BarrageViewCell.h
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

// 弹幕显示优先级,高优先级的始终会显示低的在前面
typedef NSUInteger BarragePriority;
static BarragePriority BarragePriorityLow = 0;
static BarragePriority BarragePriorityMedium = 1;
static BarragePriority BarragePriorityHigh = 2;


// 弹幕cell渲染状态
typedef NS_ENUM(NSUInteger, BarrageViewCellRenderState) {
    BarrageViewCellRenderStateWaiting,      // 等待渲染
    BarrageViewCellRenderStateAnimationing, // 渲染动画中
    BarrageViewCellRenderStatePauseing,     // 暂停
    BarrageViewCellRenderStateFinished,     // 完成
};

@class BarrageViewCell;
@protocol BarrageViewCellDelegate <NSObject>

- (void)barrageViewCellDidFinishRender:(BarrageViewCell *)cell;

@end

// 弹幕cell
@interface BarrageViewCell : UIView

// 弹幕大小
@property (nonatomic, assign) CGSize renderSize;
// 弹幕速度
@property (nonatomic, assign) CGFloat renderSpeed;

// identifier
@property (nonatomic, strong, readonly) NSString *identifier;
// 弹幕状态
@property (nonatomic, assign, readonly) BarrageViewCellRenderState state;
// 弹幕优先级
@property (nonatomic, assign, readonly) BarragePriority priority;
// 弹幕轨道
@property (nonatomic, assign, readonly) NSInteger renderChannel;
// 弹幕位置
@property (nonatomic, assign ,readonly) CGRect renderFrame;

// 开始弹幕cell动画
- (void)startBarrage;
// 暂停
- (void)pauseBarrage;
// 恢复动画
- (void)resumeBarrage;
// 移除弹幕cell
- (void)removeBarrage;

@end
