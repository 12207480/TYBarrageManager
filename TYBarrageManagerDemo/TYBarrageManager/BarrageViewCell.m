//
//  BarrageViewCell.m
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/29.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "BarrageViewCell.h"

@interface BarrageViewCell ()

@property (nonatomic, assign) BarrageViewCellRenderState state;

@property (nonatomic, assign) BarragePriority priority;

@property (nonatomic, assign) NSInteger renderChannel;

@end

@implementation BarrageViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

#pragma mark - barrage

- (void)startBarrage {
    CGFloat renderDuring = self.frame.origin.x + CGRectGetWidth(self.frame) > 0 ? (self.frame.origin.x + CGRectGetWidth(self.frame))/_renderSpeed:0;
    [UIView animateWithDuration:renderDuring delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _state = BarrageViewCellRenderStateAnimationing;
        CGRect frame = self.frame;
        frame.origin.x = -self.frame.size.width;
        self.frame = frame;
    } completion:^(BOOL finished) {
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeBarrage];
            });
        }
    }];
}

- (void)removeBarrage {
    self.state = BarrageViewCellRenderStateFinished;
    [self.layer removeAllAnimations];
    [self removeFromSuperview];
}

- (void)pauseBarrage {
    self.state = BarrageViewCellRenderStatePauseing;
    CGRect rect = self.frame;
    if (self.layer.presentationLayer) {
        rect = ((CALayer *)self.layer.presentationLayer).frame;
    }
    self.frame = rect;
    [self.layer removeAllAnimations];
}

- (void)resumeBarrage {
    [self startBarrage];
}

- (CGRect)renderFrame {
    switch (_state) {
        case BarrageViewCellRenderStateAnimationing:
        {
            if (self.layer.presentationLayer) {
                return ((CALayer *)self.layer.presentationLayer).frame;
            }
            return self.frame;
        }
        case BarrageViewCellRenderStatePauseing:
        {
            return self.frame;
        }
        case BarrageViewCellRenderStateFinished:
        {
            CGRect frame = self.frame;
            frame.origin.x = - CGRectGetWidth(frame);
            return frame;
        }
        default:
            return CGRectZero;
    }
}

@end
