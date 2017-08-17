//
//  BarrageView.h
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarrageRenderView.h"

typedef NS_ENUM(NSUInteger, BarrageState) {
    BarrageStateUnPrepare,
    BarrageStateWaiting,
    BarrageStateRendering,
    BarrageStatePauseing,
    BarrageStateStoped,
};

@class BarrageView;
@protocol BarrageViewDataSource <NSObject>

- (BarrageViewCell *)barrageView:(BarrageView *)barrageView cellForBarrageData:(id)barrageData;

@optional

- (void)barrageView:(BarrageView *)barrageView configureBarrageRenderView:(BarrageRenderView *)barrageRenderView priority:(BarragePriority)priority;

- (BarragePriority)barragePriorityWithData:(id)barrageData;

@end


@interface BarrageView : UIView

// 弹幕状态
@property (nonatomic, assign, readonly) BarrageState state;

// 弹幕发送间隔
@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, weak) id<BarrageViewDataSource> dataSource;

- (BarrageRenderView *)renderViewWithPriority:(BarragePriority)priority;

- (void)prepareBarrage;

- (void)sendBarrageDatas:(NSArray *)barrageDatas;

- (void)resume;

- (void)pause;

- (void)restart;

- (void)stop;

@end
