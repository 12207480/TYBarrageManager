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

- (void)growingTextView:(GrowingTextView *)growingTextView didChangeTextHeight:(CGFloat)textHeight;

- (void)growingTextViewDidChangeText:(GrowingTextView *)growingTextView;

@end

@interface GrowingTextView : UITextView

@property (nonatomic, weak) id<GrowingTextViewDelegate> growingTextDelegate;

@property (nonatomic, weak, readonly) UILabel *placeHolderLabel;

@property (nonatomic, assign) UIEdgeInsets placeHolderEdge;

@property (nonatomic, assign) NSUInteger maxNumOfLines;

@property (nonatomic, assign) NSInteger maxTextLength;

@end
