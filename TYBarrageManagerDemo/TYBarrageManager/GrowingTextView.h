//
//  GrowingTextView.h
//  ImgoTV-ipad
//
//  Created by tany on 16/12/5.
//  Copyright © 2016年 Hunantv. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GrowingTextView;
@protocol GrowingTextViewDelegate <NSObject>

// 文本高度改变
- (void)growingTextView:(GrowingTextView *)growingTextView didChangeTextHeight:(CGFloat)textHeight;

// 文本改变
- (void)growingTextViewDidChangeText:(GrowingTextView *)growingTextView;

@end

@interface GrowingTextView : UITextView

@property (nonatomic, weak) id<GrowingTextViewDelegate> growingTextDelegate;
// placeHolder 文本
@property (nonatomic, weak, readonly) UILabel *placeHolderLabel;
// placeHolder边距
@property (nonatomic, assign) UIEdgeInsets placeHolderEdge;
// 文本最大行
@property (nonatomic, assign) NSUInteger maxNumOfLines;
// 文本最大字数
@property (nonatomic, assign) NSInteger maxTextLength;

@end
