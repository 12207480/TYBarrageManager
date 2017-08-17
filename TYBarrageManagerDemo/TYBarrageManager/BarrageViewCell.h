//
//  BarrageViewCell.h
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>

// 弹幕显示优先级,高优先级的始终会显示低的在前面
typedef NS_ENUM(NSUInteger, BarragePriority) {
    BarragePriorityLow,
    BarragePriorityMedium,
    BarragePriorityHigh
};

// 弹幕cell渲染状态
typedef NS_ENUM(NSUInteger, BarrageViewCellRenderState) {
    BarrageViewCellRenderStateWaiting,      // 等待渲染
    BarrageViewCellRenderStateAnimationing, // 渲染动画中
    BarrageViewCellRenderStatePauseing,     // 暂停
    BarrageViewCellRenderStateFinished,     // 完成
};

// 弹幕cell
@interface BarrageViewCell : UIView

// identifier
@property (nonatomic, strong) NSString *identifier;
// 弹幕大小
@property (nonatomic, assign) CGSize renderSize;
// 弹幕速度
@property (nonatomic, assign) CGFloat renderSpeed;

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
// 移除弹幕cell
- (void)removeBarrage;
// 暂停
- (void)pauseBarrage;
// 恢复动画
- (void)resumeBarrage;

@end
