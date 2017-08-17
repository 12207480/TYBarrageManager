//
//  WeakProxy.h
//  TYBarrageManagerDemo
//
//  Created by tany on 16/12/2.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeakProxy : NSProxy

@property (nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;

@end
