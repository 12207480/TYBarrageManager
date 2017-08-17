//
//  BarrageLabelCell.m
//  TYBarrageManagerDemo
//
//  Created by tany on 16/11/30.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "BarrageLabelCell.h"

@interface BarrageLabelCell ()
@property (nonatomic,weak) UILabel *textLabel;
@end

@implementation BarrageLabelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        [self addTextLabel];
    }
    return self;
}

- (void)addTextLabel
{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    [self addSubview:label];
    _textLabel = label;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _textLabel.frame = self.bounds;
}

@end
