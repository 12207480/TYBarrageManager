//
//  GrowingTextView.m
//  ImgoTV-ipad
//
//  Created by tany on 16/12/5.
//  Copyright © 2016年 Hunantv. All rights reserved.
//

#import "GrowingTextView.h"

@interface GrowingTextView ()

@property (nonatomic, weak) UILabel *placeHolderLabel;

@property (nonatomic, assign) CGFloat textHeight;

@property (nonatomic, assign) CGFloat maxTextHeight;

@end

@implementation GrowingTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self configureInputView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self configureInputView];
    }
    return self;
}

- (void)configureInputView
{
    self.scrollEnabled = NO;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
    
    [self addPlaceHolderLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:self];
}

- (void)addPlaceHolderLabel
{
    UILabel *placeHolderLabel = [[UILabel alloc]init];
    placeHolderLabel.userInteractionEnabled = NO;
    placeHolderLabel.font = self.font;
    [self addSubview:placeHolderLabel];
    _placeHolderLabel = placeHolderLabel;
}

- (void)setMaxNumOfLines:(NSUInteger)maxNumOfLines
{
    _maxNumOfLines = maxNumOfLines;
    _maxTextHeight = ceil(self.font.lineHeight * maxNumOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
}

#pragma mark - Notification

- (void)textDidChange:(NSNotification *)notification
{
    if (notification.object != self) {
        return;
    }
    // 占位文字是否显示
    self.placeHolderLabel.hidden = self.text.length > 0;
    
    if (self.text.length == 1) {
        if ([self.text isEqualToString:@" "] || [self.text isEqualToString:@"\n"]) {
            self.text = @"";
        }
    }
    
    if (_maxTextLength > 0) { // 只有当maxLength字段的值不为无穷大整型也不为0时才计算限制字符数.
        NSString    *toBeString    = self.text;
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position   = [self positionFromPosition:selectedRange.start offset:0];
        if (!position) {
            if (toBeString.length > _maxTextLength) {
                self.text = [toBeString substringToIndex:_maxTextLength]; // 截取最大限制字符数.
            }
        }
    }
    
    if ([_growingTextDelegate respondsToSelector:@selector(growingTextViewDidChangeText:)]) {
        [_growingTextDelegate growingTextViewDidChangeText:self];
    }

    
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
    
    if (_textHeight != height) { // 高度不一样，就改变了高度
        
        // 最大高度，可以滚动
        self.scrollEnabled = _maxNumOfLines > 0 && height > _maxTextHeight && _maxTextHeight > 0;
        
        _textHeight = height;
        
        if (!self.scrollEnabled && [_growingTextDelegate respondsToSelector:@selector(growingTextView:didChangeTextHeight:)]) {
            [_growingTextDelegate growingTextView:self didChangeTextHeight:height];
        }
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_placeHolderLabel.hidden) {
        _placeHolderLabel.frame = CGRectMake(_placeHolderEdge.left, _placeHolderEdge.top, CGRectGetWidth(self.frame)-_placeHolderEdge.left- _placeHolderEdge.right, CGRectGetHeight(self.frame) - _placeHolderEdge.top - _placeHolderEdge.bottom);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
