//
//  BarrageRenderView.m
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "BarrageRenderView.h"
#import "BarrageView.h"

@interface BarrageView ()

- (BarrageViewCell *)cellForBarrageData:(id)barrageData;

@end

@interface BarrageViewCell ()

@property (nonatomic, assign) BarrageViewCellState state;

@property (nonatomic, assign) BarragePriority priority;

@property (nonatomic, assign) NSInteger renderChannel;

@end

@interface BarrageRenderView ()

@property (nonatomic, assign) BarragePriority priority;

@property (nonatomic, weak, readonly) BarrageView *barrageView;

@property (nonatomic, assign)NSInteger channelCount;

@property (nonatomic, strong) NSMutableArray *barrageDatas;

@property (nonatomic, strong) NSMutableArray *barragebufferDatas;

@property (nonatomic, strong) NSMutableDictionary *channelBarrages;

@end

@implementation BarrageRenderView

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

- (BarrageView *)barrageView {
    return (BarrageView *)self.superview;
}

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
    
    NSIndexSet *renderChannels = [self findRanderBarrageChannel];
    
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
    
    BarrageViewCell *cell = [self.barrageView cellForBarrageData:barrageData];
    cell.state = BarrageViewCellStateWaiting;
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

#pragma mark - private

- (void)configreChannel {
    NSInteger channelCount =  CGRectGetHeight(self.frame)/(_channelHeight - _firstChannelTopEdge - _lastChannelBottomEdge);
    if (_maxChannelCount > 0 && _maxChannelCount < channelCount) {
        channelCount = _maxChannelCount;
    }
    _channelCount = channelCount;
}

- (NSIndexSet *)findRanderBarrageChannel {
    NSMutableIndexSet *availableChannel = [NSMutableIndexSet indexSet];
    NSUInteger forecastChannel = arc4random_uniform((unsigned int)_channelCount);
    if ([self isAvailableChannel:forecastChannel]) {
        [availableChannel addIndex:forecastChannel];
    }
    
    BOOL searchDirectionDown = arc4random_uniform(2);
    NSUInteger searchChannel = searchDirectionDown ? forecastChannel +1+ _channelCount*100: forecastChannel+_channelCount*100 -1 ;

    while (searchChannel%_channelCount != forecastChannel) {
        
        if ([self isAvailableChannel:searchChannel%_channelCount]) {
            [availableChannel addIndex:searchChannel%_channelCount];;
        }
        
        if (searchDirectionDown) {
            ++searchChannel;
        }else {
            --searchChannel;
        }
    }
    return availableChannel;
}

- (BOOL)isAvailableChannel:(NSUInteger)channel {
    BarrageViewCell *cell = [self.channelBarrages objectForKey:@(channel)];
    if (!cell) {
        return YES;
    }
    
    if (cell.state == BarrageViewCellStateWaiting || cell.state == BarrageViewCellStateFinished) {
        return YES;
    }
    
    if ((cell.state == BarrageViewCellStateAnimationing || cell.state == BarrageViewCellStatePauseing) && cell.renderChannel == channel && CGRectGetMaxX([cell renderFrame]) < CGRectGetWidth(self.frame)) {
        return YES;
    }
    return NO;

}

@end
