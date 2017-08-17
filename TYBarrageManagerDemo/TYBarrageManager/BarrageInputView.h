//
//  BarrageInputView.h
//  ImgoTV-ipad
//
//  Created by tany on 16/12/5.
//  Copyright © 2016年 Hunantv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrowingTextView.h"

@class BarrageInputView;
@protocol BarrageInputViewDelegate <NSObject>

- (void)barrageInputView:(BarrageInputView *)barrageInputView DidSendText:(NSString *)text;

@end

@interface BarrageInputView : UIView

@property (nonatomic,weak) id<BarrageInputViewDelegate> delegate;

@property (nonatomic, weak, readonly) GrowingTextView *textView;

@property (nonatomic, weak, readonly) UIImageView *backgroundImageView;

@property (nonatomic, assign) UIEdgeInsets textViewEdge;

@end
