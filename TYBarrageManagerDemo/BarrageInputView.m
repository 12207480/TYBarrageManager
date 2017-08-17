//
//  BarrageInputView.m
//  ImgoTV-ipad
//
//  Created by tany on 16/12/5.
//  Copyright © 2016年 Hunantv. All rights reserved.
//

#import "BarrageInputView.h"

@interface BarrageInputView () <GrowingTextViewDelegate, UITextViewDelegate>

@property (nonatomic, weak) GrowingTextView *textView;

@property (nonatomic, weak) UIImageView *backgroundImageView;

@property (nonatomic, weak) UILabel *textLengthLabel;

@end

@implementation BarrageInputView

#pragma mark - life cycle

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
    _textViewEdge = UIEdgeInsetsMake(7, 10, 7, 10);
    
    [self addBackgroundImageView];
    
    [self addGrowingTextView];
    
    [self addTextLengthLabel];
}

- (void)addGrowingTextView
{
    GrowingTextView *textView = [[GrowingTextView alloc]init];
    textView.returnKeyType = UIReturnKeySend;
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:16];
    textView.textColor = [UIColor whiteColor];
    textView.maxNumOfLines = 2;
    textView.maxTextLength = 50;
    textView.clipsToBounds = YES;
    textView.growingTextDelegate = self;
    textView.delegate = self;
    textView.keyboardAppearance = UIKeyboardAppearanceDark;
    textView.placeHolderEdge = UIEdgeInsetsMake(0, 10, 0, 0);
    textView.placeHolderLabel.text = @"在此输入想法";
    textView.placeHolderLabel.font = [UIFont systemFontOfSize:16];
    textView.placeHolderLabel.textColor = [UIColor colorWithRed:174/255.0 green:175/255.0 blue:177/255.0 alpha:1.0];
    [self addSubview:textView];
    _textView = textView;
}

- (void)addBackgroundImageView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    UIImage *image = [UIImage imageNamed:@"full_input"] ;
    imageView.image = [image stretchableImageWithLeftCapWidth:image.size.width*0.5 topCapHeight:image.size.height*0.5];
    [self addSubview:imageView];
    _backgroundImageView = imageView;
}

- (void)addTextLengthLabel
{
    UILabel *label = [[UILabel alloc]init];
    label.textColor = [UIColor colorWithRed:174/255.0 green:175/255.0 blue:177/255.0 alpha:1.0];
    label.font = [UIFont systemFontOfSize:16];
    label.textAlignment = NSTextAlignmentRight;
    label.userInteractionEnabled = NO;
    label.text = [NSString stringWithFormat:@"%d/%d",0,(int)_textView.maxTextLength];
    [self addSubview:label];
    _textLengthLabel = label;
}

#pragma mark - GrowingTextViewDelegate

- (void)growingTextView:(GrowingTextView *)growingTextView didChangeTextHeight:(CGFloat)textHeight
{
    CGFloat bottomSpace = CGRectGetHeight(self.superview.frame) - CGRectGetMaxY(self.frame);
    CGFloat height = textHeight + _textViewEdge.top + _textViewEdge.bottom;
    CGFloat orignY = CGRectGetHeight(self.superview.frame) - bottomSpace - height;
    self.frame = CGRectMake(self.frame.origin.x, orignY, self.frame.size.width, height);
}

- (void)growingTextViewDidChangeText:(GrowingTextView *)growingTextView
{
    _textLengthLabel.text = [NSString stringWithFormat:@"%d/%d",(int)growingTextView.text.length,(int)growingTextView.maxTextLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if ([_delegate respondsToSelector:@selector(barrageInputView:didSendedMessage:)]) {
            [_delegate barrageInputView:self didSendedMessage:textView.text];
        }
        return NO;
    }
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _backgroundImageView.frame = self.bounds;
    _textLengthLabel.frame = CGRectMake(CGRectGetWidth(self.frame)- 80 - 15, 0, 80, 50);
    _textView.frame = CGRectMake(_textViewEdge.left, _textViewEdge.top, CGRectGetWidth(self.frame)-_textViewEdge.left- _textViewEdge.right, CGRectGetHeight(self.frame) - _textViewEdge.top - _textViewEdge.bottom);
}

@end
