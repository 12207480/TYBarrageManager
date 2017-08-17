//
//  BarrageView.m
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "BarrageView.h"
#import "WeakProxy.h"

@interface BarrageRenderView ()

@property (nonatomic, assign) BarragePriority priority;

@end

@interface BarrageView () {
    struct {
        unsigned int barragePriorityWithData :1;
        unsigned int configureBarrageRenderView :1;
    }_dataSourceFlags;
}

@property (nonatomic, assign) BarrageState state;

// UI
@property (nonatomic, strong) NSArray *renderViews;

// Data

//@property (nonatomic, strong) NSArray *barrageDatas;

@property (nonatomic, strong) NSTimer *timer;

@end

#define MAX_RENDER_COUNT 3

#define RENDER_VIEW_OFFSET 1000

@implementation BarrageView

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self configreBarrageView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self configreBarrageView];
    }
    return self;
}

#pragma mark - addSubView

- (void)configreBarrageView
{
    _timeInterval = 0.6;
    [self addBarrageContentViews];
}

- (void)addBarrageContentViews
{
    NSMutableArray *array = [NSMutableArray array];
    for (int idx = 0; idx < MAX_RENDER_COUNT; ++idx) {
        BarrageRenderView *renderView = [[BarrageRenderView alloc]initWithFrame:self.frame];
        renderView.priority = idx;
        renderView.tag = RENDER_VIEW_OFFSET+idx;
        [self addSubview:renderView];
        [array addObject:renderView];
    }
    
    _renderViews = [array copy];
}

#pragma mark - geter setter

- (void)setDataSource:(id<BarrageViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _dataSourceFlags.barragePriorityWithData = [dataSource respondsToSelector:@selector(barragePriorityWithData:)];
    _dataSourceFlags.configureBarrageRenderView = [dataSource respondsToSelector:@selector(barrageView:configureBarrageRenderView:priority:)];
}

- (BarrageRenderView *)renderViewWithPriority:(BarragePriority)priority
{
    if (priority < _renderViews.count) {
        return _renderViews[priority];
    }
    return _renderViews.lastObject;
}

#pragma mark - randerBarrage

- (void)prepareBarrage
{
    if (_state != BarrageStateUnPrepare && _state != BarrageStateStoped) {
        return;
    }
    
    for (BarrageRenderView *renderView in _renderViews) {
        if (_dataSourceFlags.configureBarrageRenderView) {
            [_dataSource barrageView:self configureBarrageRenderView:renderView priority:renderView.priority];
        }
        [renderView prepareRenderBarrage];
    }
    
    _state = BarrageStateWaiting;
}

- (void)sendBarrageDatas:(NSArray *)barrageDatas
{
    if (_state == BarrageStateUnPrepare) {
        [self prepareBarrage];
    }
    
    NSDictionary *priorityBarrages = [self priorityBarrageDictionaryWithDatas:barrageDatas];
    
    for (BarrageRenderView *renderView in _renderViews) {
        NSArray *renderBarrageDatas = [priorityBarrages objectForKey:@(renderView.priority)];
        if (renderBarrageDatas) {
            [renderView recieveBarrageDatas:[renderBarrageDatas copy]];
        }
    }
    
    [self startTimerIfNeed];
}

- (void)renderBarrage
{
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
    
    if (!haveBarrageDatas) {
        [self clearTimer];
        _state = BarrageStateWaiting;
    }
}

- (void)clearBarrage
{
    [self clearTimer];
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView clearBarrage];
    }
}

#pragma mark - dataSource

- (BarrageViewCell *)cellForBarrageData:(id)barrageData
{
    return [_dataSource barrageView:self cellForBarrageData:barrageData];
}

#pragma mark - control

- (void)resume
{
    _state = BarrageStateWaiting;
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView resume];
    }
    [self startTimerIfNeed];
}

- (void)pause
{
    _state = BarrageStatePauseing;
    [self clearTimer];
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView pause];
    }
}

- (void)restart
{
    if (_state == BarrageStateRendering || _state == BarrageStatePauseing) {
        [self clearBarrage];
    }
    
    _state = BarrageStateUnPrepare;
    
    [self prepareBarrage];
}

- (void)stop
{
    _state = BarrageStateStoped;
    [self clearTimer];
    for (BarrageRenderView *renderView in _renderViews) {
        [renderView stop];
    }
}

#pragma mark - private

- (NSDictionary *)priorityBarrageDictionaryWithDatas:(NSArray *)barrageDatas
{
    NSMutableDictionary *priorityBarrages = [NSMutableDictionary dictionary];
    if (_dataSourceFlags.barragePriorityWithData) {
        for (id barrageData in barrageDatas) {
            BarragePriority priority = [_dataSource barragePriorityWithData:barrageData];
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

- (void)startTimerIfNeed
{
    if (!_timer) {
        WeakProxy *proxy = [WeakProxy proxyWithTarget:self];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval target:proxy selector:@selector(renderBarrage) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)clearTimer
{
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - hitTest

- (id)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    __block UIView *clickedView = nil;
    [self.renderViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(BarrageRenderView *renderView, NSUInteger idx, BOOL * stop) {
        NSArray *subViews = renderView.subviews;
        [subViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *subView, NSUInteger idx, BOOL * stop) {
            if([subView isKindOfClass:[BarrageViewCell class]]){ //是要找的图片
                CALayer *layer = subView.layer.presentationLayer; //图片的显示层
                if(CGRectContainsPoint(layer.frame, point)){ //触摸点在显示层中，返回当前图片
                    clickedView = subView;
                    *stop = YES;
                }
            }
        }];
        
        if (clickedView) {
            *stop = YES;
        }
    }];

    if (clickedView) {
        return clickedView;
    }
    return [super hitTest:point withEvent:event];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    for (BarrageRenderView *renderView in _renderViews) {
        renderView.frame = self.bounds;
    }
}

- (void)dealloc
{
    [self stop];
}

@end
