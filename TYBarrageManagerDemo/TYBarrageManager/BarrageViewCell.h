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

typedef NS_ENUM(NSUInteger, BarrageViewCellState) {
    BarrageViewCellStateWaiting,
    BarrageViewCellStateAnimationing,
    BarrageViewCellStatePauseing,
    BarrageViewCellStateFinished,
};

@interface BarrageViewCell : UIView

// 需要赋值

@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, assign) CGSize renderSize;

@property (nonatomic, assign) CGFloat renderSpeed;

@property (nonatomic, assign) BOOL singleTapEnable;

// readonly

@property (nonatomic, assign, readonly) BarrageViewCellState state;

@property (nonatomic, assign, readonly) BarragePriority priority;

@property (nonatomic, assign, readonly) NSInteger renderChannel;

- (CGRect)renderFrame;

- (void)animationBarrage;

- (void)removeBarrage;

- (void)pauseBarrage;

- (void)resumeBarrage;

@end
