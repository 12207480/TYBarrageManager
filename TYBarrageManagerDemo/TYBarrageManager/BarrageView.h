//
//  BarrageView.h
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarrageRenderView.h"

// 弹幕状态
typedef NS_ENUM(NSUInteger, BarrageState) {
    BarrageStateUnPrepare,
    BarrageStateWaiting,
    BarrageStateRendering,
    BarrageStatePauseing,
    BarrageStateStoped,
};

@class BarrageView;
@protocol BarrageViewDataSource <NSObject>
// 弹幕 cell
- (BarrageViewCell *)barrageView:(BarrageView *)barrageView cellForBarrageData:(id)barrageData;

@optional

// 渲染层个数，每个渲染层都有一个BarragePriority 默认 3层
- (NSUInteger)countOfRenderViewInBarrageView:(BarrageView *)barrageView;

// 弹幕设置
- (void)barrageView:(BarrageView *)barrageView configureBarrageRenderView:(BarrageRenderView *)renderView;

// 弹幕优先级
- (BarragePriority)barrageView:(BarrageView *)barrageView priorityWithBarrageData:(id)barrageData;

@end

@protocol BarrageViewDelegate <NSObject>
@optional
// 选中弹幕
- (void)barrageView:(BarrageView *)barrageView didClickedBarrageCell:(BarrageViewCell *)BarrageCell;

@end


@interface BarrageView : UIView

@property (nonatomic, weak) id<BarrageViewDataSource> dataSource;

@property (nonatomic, weak) id<BarrageViewDelegate> delegate;

// 弹幕状态
@property (nonatomic, assign, readonly) BarrageState state;

// 弹幕发送间隔
@property (nonatomic, assign) NSTimeInterval timeInterval;

// 连续5次没有数据清除定时器
@property (nonatomic, assign) NSInteger countOfNoDataWillClearTimer;

// 弹幕优先级层
- (BarrageRenderView *)renderViewWithPriority:(BarragePriority)priority;

// 准备弹幕
- (void)prepareBarrage;

// 发送弹幕
- (void)sendBarrageDatas:(NSArray *)barrageDatas;

// 恢复
- (void)resume;

// 暂停
- (void)pause;

// 重新开始
- (void)restart;

// 停止
- (void)stop;

@end
