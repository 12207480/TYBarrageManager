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

// 弹幕cell 状态
typedef NS_ENUM(NSUInteger, BarrageViewCellState) {
    BarrageViewCellStateWaiting,
    BarrageViewCellStateAnimationing,
    BarrageViewCellStatePauseing,
    BarrageViewCellStateFinished,
};

@interface BarrageViewCell : UIView

// configure
// id
@property (nonatomic, strong) NSString *identifier;

// 弹幕大小
@property (nonatomic, assign) CGSize renderSize;

// 弹幕速度
@property (nonatomic, assign) CGFloat renderSpeed;

// 弹幕是否能点击
@property (nonatomic, assign) BOOL singleTapEnable;

// readonly
// 弹幕状态
@property (nonatomic, assign, readonly) BarrageViewCellState state;

// 弹幕优先级
@property (nonatomic, assign, readonly) BarragePriority priority;
// 弹幕轨道
@property (nonatomic, assign, readonly) NSInteger renderChannel;

// 弹幕当前render framw
- (CGRect)renderFrame;

- (void)animationBarrage;

- (void)removeBarrage;

- (void)pauseBarrage;

- (void)resumeBarrage;

@end
