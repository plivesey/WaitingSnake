//
//  WSNScoreModule.h
//  WaitingSnake
//
//  Created by Austin Zheng on 5/9/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 A module for handling scoring. Abstracted out into its own class in order to make future feature development such as
 achievements easier.
 */
@interface WSNScoreModule : NSObject

@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, copy) void(^scoreChangeBlock)(NSInteger newScore, NSInteger scoreDelta);

+ (instancetype)scoreModule;

- (void)reset;
- (void)incrementScore;
- (void)decrementScore;
- (void)changeScoreBy:(NSInteger)delta;

@end
