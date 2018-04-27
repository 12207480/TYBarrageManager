//
//  BarrageView.m
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "BarrageView.h"

@interface BarrageView ()<BarrageRenderViewDataSource> {
    struct {
        unsigned int barragePriorityWithData :1;
        unsigned int configureBarrageRenderView :1;
    }_dataSourceFlags;
}

// Data
@property (nonatomic, assign) BarrageState state;

@property (nonatomic, assign) NSUInteger barrageRenderCount;

@property (nonatomic, assign) NSInteger countOfNoData;

// UI
@property (nonatomic, strong) NSArray *renderViews;

@property (nonatomic, strong) NSTimer *timer;

@end

#define RENDER_VIEW_OFFSET 10000

@implementation BarrageView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self configreBarrageView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
        [self configreBarrageView];
    }
    return self;
}

#pragma mark - addSubView

- (void)configreBarrageView {
    _timeInterval = 0.6;
    _countOfNoData = 0;
    _countOfNoDataWillClearTimer = 6;
    [self addBarrageContentViews];
}

- (void)addBarrageContentViews {
    NSMutableArray *array = [NSMutableArray array];
    BarragePriority count = BarragePriorityHigh + 1;
    if ([_dataSource respondsToSelector:@selector(countOfRenderViewInBarrageView:)]) {
        count = [_dataSource countOfRenderViewInBarrageView:self];
    }
    _barrageRenderCount = count;
    for (int idx = 0; idx < count; ++idx) {
        BarrageRenderView *renderView = [[BarrageRenderView alloc]initWithFrame:self.bounds Priority:idx];
        renderView.dataSource = self;
        renderView.tag = RENDER_VIEW_OFFSET+idx;
        [self addSubview:renderView];
        [array addObject:renderView];
    }
    _renderViews = [array copy];
}

#pragma mark - geter setter

- (void)setDataSource:(id<BarrageViewDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceFlags.barragePriorityWithData = [dataSource respondsToSelector:@selector(barrageView:priorityWithBarrageData:)];
    _dataSourceFlags.configureBarrageRenderView = [dataSource respondsToSelector:@selector(barrageView:configureBarrageRenderView:)];
}

- (BarrageRenderView *)renderViewWithPriority:(BarragePriority)priority {
    if (priority < _renderViews.count) {
        return _renderViews[priority];
    }
    return _renderViews.lastObject;
}

#pragma mark - randerBarrage

- (void)prepareBarrage {
    if (_state != BarrageStateUnPrepare && _state != BarrageStateStoped) {
        return;
    }
    
    for (BarrageRenderView *renderView in _renderViews) {
        if (_dataSourceFlags.configureBarrageRenderView) {
            [_dataSource barrageView:self configureBarrageRenderView:renderView];
        }
        [renderView prepareRenderBarrage];
    }
    
    _state = BarrageStateWaiting;
}

- (void)sendBarrageDatas:(NSArray *)barrageDatas {
    if (_state == BarrageStateUnPrepare) {
        [self prepareBarrage];
    }
    
    if (_state == BarrageStateStoped) {
        return;
    }
    
    NSDictionary *priorityBarrages = [self priorityBarrageDictionaryWithDatas:barrageDatas];
    
    for (BarrageRenderView *renderView in _renderViews) {
        NSArray *renderBarrageDatas = [priorityBarrages objectForKey:@(renderView.priority)];
        if (renderBarrageDatas) {
            [renderView recieveBarrageDatas:[renderBarrageDatas copy]];
        }
    }
    
    [self startTimer];
}

- (void)renderBarrage {
    if (_state == BarrageStateStoped || _state == BarrageStatePauseing) {
        return;
    }
    _state = BarrageStateRendering;
    BOOL haveBarrageDatas = NO;
    for (BarrageRenderView *renderView in _renderViews) {
        if ([renderView haveBarrageDatas]) {
            [renderView renderBarrage];
            haveBarrageDatas = YES;
        }
    }
    _countOfNoData = haveBarrageDatas ? 0 : _countOfNoData+1;
    
    if (_countOfNoData > _countOfNoDataWillClearTimer) {
        [self stopTimer];
        _state = BarrageStateWaiting;
    }
}

- (void)clearBarrage {
    [self stopTimer];
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView clearBarrage];
    }
}

#pragma mark - dataSource

- (BarrageViewCell *)barrageRenderView:(BarrageRenderView *)renderView cellForBarrageData:(id)barrageData {
    return [_dataSource barrageView:self cellForBarrageData:barrageData];
}

#pragma mark - control

- (void)resume {
    _state = BarrageStateWaiting;
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView resume];
    }
    [self startTimer];
}

- (void)pause {
    _state = BarrageStatePauseing;
    [self stopTimer];
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView pause];
    }
}

- (void)restart {
    if (_state == BarrageStateRendering || _state == BarrageStatePauseing) {
        [self clearBarrage];
    }
    _state = BarrageStateUnPrepare;
    [self prepareBarrage];
}

- (void)stop {
    _state = BarrageStateStoped;
    [self stopTimer];
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView stop];
    }
}

#pragma mark - private

- (NSDictionary *)priorityBarrageDictionaryWithDatas:(NSArray *)barrageDatas {
    NSMutableDictionary *priorityBarrages = [NSMutableDictionary dictionary];
    if (_dataSourceFlags.barragePriorityWithData) {
        for (id barrageData in barrageDatas) {
            BarragePriority priority = MIN([_dataSource barrageView:self priorityWithBarrageData:barrageData], _barrageRenderCount-1);
            
            NSMutableArray *array = [priorityBarrages objectForKey:@(priority)];
            if (!array) {
                array = [NSMutableArray array];
                [priorityBarrages setObject:array forKey:@(priority)];
            }
            [array addObject:barrageData];
        }
    }else {
        [priorityBarrages setObject:barrageDatas forKey:@(BarragePriorityLow)];
    }
    return priorityBarrages;
}

- (void)startTimer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:self selector:@selector(renderBarrage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopTimer {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - hitTest

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    __block UIView *hitView = nil;
    [_renderViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BarrageRenderView *renderView, NSUInteger idx, BOOL * stop) {
        hitView = [renderView hitTest:point withEvent:event];
        if (hitView) {
            *stop = YES;
        }
    }];
    
    if (_delegate && [hitView isKindOfClass:[BarrageViewCell class]] && [_delegate respondsToSelector:@selector(barrageView:didClickedBarrageCell:)]) {
        [_delegate barrageView:self didClickedBarrageCell:(BarrageViewCell *)hitView];
    }
    return hitView ? hitView : [super hitTest:point withEvent:event];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self stopTimer];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (BarrageRenderView *renderView in _renderViews) {
        renderView.frame = self.bounds;
    }
}

- (void)dealloc {
    [self stop];
}

@end
