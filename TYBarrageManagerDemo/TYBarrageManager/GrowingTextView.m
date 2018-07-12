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

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self configureInputView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configureInputView];
    }
    return self;
}

- (void)configureInputView {
    self.scrollEnabled = ![_growingTextDelegate respondsToSelector:@selector(growingTextView:didChangeTextHeight:)];
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.enablesReturnKeyAutomatically = YES;
    
    [self addPlaceHolderLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)addPlaceHolderLabel {
    UILabel *placeHolderLabel = [[UILabel alloc]init];
    placeHolderLabel.userInteractionEnabled = NO;
    placeHolderLabel.font = self.font;
    [self addSubview:placeHolderLabel];
    _placeHolderLabel = placeHolderLabel;
}

- (void)setMaxNumOfLines:(NSUInteger)maxNumOfLines {
    _maxNumOfLines = maxNumOfLines;
    _maxTextHeight = ceil(self.font.lineHeight * maxNumOfLines + self.textContainerInset.top + self.textContainerInset.bottom);
}

#pragma mark - Notification

- (void)textDidChange:(NSNotification *)notification {
    // 占位文字是否显示
    self.placeHolderLabel.hidden = self.text.length > 0;
    if (self.text.length == 1) {
        if ([self.text isEqualToString:@" "] || [self.text isEqualToString:@"\n"]) {
            self.text = @"";
        }
    }
    
    if (_maxTextLength > 0) {
        // 只有当maxLength字段的值不为无穷大整型也不为0时才计算限制字符数.
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
    
    if (![_growingTextDelegate respondsToSelector:@selector(growingTextView:didChangeTextHeight:)]) {
        return;
    }
    CGFloat height = ceilf([self sizeThatFits:CGSizeMake(self.bounds.size.width, MAXFLOAT)].height);
    if (_textHeight != height) { // 高度不一样，就改变了高度
        // 最大高度，可以滚动
        self.scrollEnabled = _maxNumOfLines > 0 && height > _maxTextHeight && _maxTextHeight > 0;
        _textHeight = height;
        if (!self.scrollEnabled) {
            [_growingTextDelegate growingTextView:self didChangeTextHeight:height];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _placeHolderLabel.hidden = self.text.length > 0;
    CGRect beginRect = [self caretRectForPosition:self.beginningOfDocument];
    _placeHolderLabel.frame = CGRectMake(beginRect.origin.x + _placeHolderEdge.left, beginRect.origin.y + _placeHolderEdge.top, CGRectGetWidth(self.frame)-_placeHolderEdge.left- _placeHolderEdge.right - beginRect.origin.x - beginRect.origin.y, beginRect.size.height - _placeHolderEdge.bottom);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
