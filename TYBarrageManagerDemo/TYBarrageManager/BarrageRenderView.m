//
//  BarrageRenderView.m
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "BarrageRenderView.h"

@interface BarrageViewCell ()

@property (nonatomic, assign) BarrageViewCellRenderState state;

@property (nonatomic, assign) BarragePriority priority;

@property (nonatomic, assign) NSInteger renderChannel;

@end

@interface BarrageRenderView () {
    struct {
        unsigned int barrageRenderAvailableChannels :1;
    }_dataSourceFlags;
}

@property (nonatomic, assign) BarragePriority priority;

@property (nonatomic, assign)NSInteger channelCount;

@property (nonatomic, strong) NSMutableArray *barrageDatas;

@property (nonatomic, strong) NSMutableArray *barragebufferDatas;

@property (nonatomic, strong) NSMutableDictionary *channelBarrages;

@end

@implementation BarrageRenderView

- (instancetype)initWithFrame:(CGRect)frame Priority:(BarragePriority)priority {
    if (self = [self initWithFrame:frame]) {
        self.priority = priority;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _maxChannelCount = 0;
        _channelHeight = 26;
        _maxBarrageDataCount = 30;
        _maxBufferBarrageDataCount = 30;
        _firstChannelTopEdge = 0;
        _lastChannelBottomEdge = 0;
    }
    return self;
}

#pragma mark - getter setter

- (NSMutableArray *)barrageDatas {
    if (!_barrageDatas) {
        _barrageDatas = [NSMutableArray array];
    }
    return _barrageDatas;
}

- (NSMutableArray *)barragebufferDatas {
    if (!_barragebufferDatas) {
        _barragebufferDatas = [NSMutableArray array];
    }
    return _barragebufferDatas;
}

- (NSMutableDictionary *)channelBarrages {
    if (!_channelBarrages) {
        _channelBarrages = [NSMutableDictionary dictionary];
    }
    return _channelBarrages;
}

- (void)setDataSource:(id<BarrageRenderViewDataSource>)dataSource {
    _dataSource = dataSource;
    _dataSourceFlags.barrageRenderAvailableChannels = [dataSource respondsToSelector:@selector(barrageRenderAvailableChannels:)];
}

#pragma mark - RenderBarrage

- (void)prepareRenderBarrage {
    [self configreChannel];
}

- (void)recieveBarrageDatas:(NSArray *)barrageDatas {
    if (self.barrageDatas.count < _maxBarrageDataCount) {
        [self.barrageDatas addObjectsFromArray:barrageDatas];
    }else if (self.barragebufferDatas.count < _maxBufferBarrageDataCount) {
        [self.barragebufferDatas addObjectsFromArray:barrageDatas];
    }else {
        [self.barrageDatas removeAllObjects];
        [self.barrageDatas addObjectsFromArray:self.barragebufferDatas];
        [self.barragebufferDatas removeAllObjects];
        [self.barragebufferDatas addObjectsFromArray:barrageDatas];
    }
}

- (BOOL)haveBarrageDatas {
    return _barrageDatas.count > 0 || _barragebufferDatas.count > 0;
}

- (void)renderBarrage {
    if (_channelCount == 0) {
        NSLog(@"renader channelCount is 0!");
        return;
    }
    
    if (self.barrageDatas.count <= 0 && self.barragebufferDatas.count > 0) {
        [self.barrageDatas addObjectsFromArray:self.barragebufferDatas];
        [self.barragebufferDatas removeAllObjects];
    }
    
    if (self.barrageDatas.count <= 0 && self.barragebufferDatas.count <= 0) {
        return;
    }
    
    NSIndexSet *renderChannels = [self findRanderBarrageAvailableChannels];
    if (renderChannels.count <= 0) {
        return;
    }
    
    [renderChannels enumerateIndexesUsingBlock:^(NSUInteger channel, BOOL * stop) {
        id barrageData = self.barrageDatas.firstObject;
        if (self.barrageDatas.count > 0) {
            [self.barrageDatas removeObjectAtIndex:0];
        }
        [self renderBarrageCellData:barrageData channel:channel];
    }];

}

- (void)renderBarrageCellData:(id)barrageData channel:(NSUInteger) channel {
    if (!barrageData) {
        return;
    }
    
    BarrageViewCell *cell = [_dataSource barrageRenderView:self cellForBarrageData:barrageData];
    cell.state = BarrageViewCellRenderStateWaiting;
    cell.renderChannel = channel;
    cell.priority = self.priority;
    cell.frame = CGRectMake(CGRectGetWidth(self.frame), _firstChannelTopEdge+channel*self.channelHeight+(self.channelHeight-cell.renderSize.height)/2, cell.renderSize.width, cell.renderSize.height);
    
    if (!cell.superview) {
        [self addSubview:cell];
    }
    if (cell.hidden) {
        cell.hidden = NO;
    }
    
    [self.channelBarrages setObject:cell forKey:@(channel)];

    [cell startBarrage];
}

- (void)clearBarrage {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[BarrageViewCell class]]) {
            [(BarrageViewCell *)subView removeBarrage];
        }
    }
}

#pragma mark - channel

- (void)configreChannel {
    NSInteger channelCount =  CGRectGetHeight(self.frame)/(_channelHeight - _firstChannelTopEdge - _lastChannelBottomEdge);
    if (_maxChannelCount > 0 && _maxChannelCount < channelCount) {
        channelCount = _maxChannelCount;
    }
    _channelCount = channelCount;
}

- (NSIndexSet *)findRanderBarrageAvailableChannels {
    if (_dataSourceFlags.barrageRenderAvailableChannels) {
        NSIndexSet *channels = [_dataSource barrageRenderAvailableChannels:self];
        if (channels.count > 0) {
            return channels;
        }
    }
    NSMutableIndexSet *availableChannels = [NSMutableIndexSet indexSet];
    for (int index = 0; index < _channelCount; ++index) {
        if ([self isAvailableChannel:index]) {
            [availableChannels addIndex:index];;
        }
    }
    return [availableChannels copy];
}

- (BOOL)isAvailableChannel:(NSUInteger)channel {
    BarrageViewCell *cell = [self.channelBarrages objectForKey:@(channel)];
    if (!cell) {
        return YES;
    }
    
    if (cell.state == BarrageViewCellRenderStateWaiting || cell.state == BarrageViewCellRenderStateFinished) {
        return YES;
    }
    
    if ((cell.state == BarrageViewCellRenderStateAnimationing || cell.state == BarrageViewCellRenderStatePauseing) && cell.renderChannel == channel && CGRectGetMaxX([cell renderFrame]) < CGRectGetWidth(self.frame)) {
        return YES;
    }
    return NO;
    
}

#pragma mark - control

- (void)resume {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[BarrageViewCell class]]) {
            [(BarrageViewCell *)subView resumeBarrage];
        }
    }
}

- (void)pause {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[BarrageViewCell class]]) {
           [(BarrageViewCell *)subView pauseBarrage];
        }
    }
}

- (void)stop {
    [self clearBarrage];
    
    [self clearData];
}

- (void)clearData {
    [self.barrageDatas removeAllObjects];
    [self.barragebufferDatas removeAllObjects];
    [self.channelBarrages removeAllObjects];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    __block UIView *hitView = nil;
    [self.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIView *subView, NSUInteger idx, BOOL * stop) {
        CALayer *layer = subView.layer.presentationLayer; //图片的显示层
        if(CGRectContainsPoint(layer.frame, point)){ //触摸点在显示层中，返回当前图片
            hitView = subView;
            *stop = YES;
        }
    }];
    return hitView;
}

@end
