//
//  WSNScoreModule.m
//  WaitingSnake
//
//  Created by Austin Zheng on 5/9/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import "WSNScoreModule.h"

@interface WSNScoreModule ()
@property (nonatomic, readwrite) NSInteger score;
@end

@implementation WSNScoreModule

+ (instancetype)scoreModule {
    WSNScoreModule *module = [[self class] new];
    [module reset];
    return module;
}

- (void)reset {
    self.score = 0;
}

- (void)incrementScore {
    self.score++;
    // Logic for achievements, etc can go here
}

- (void)decrementScore {
    self.score--;
}

- (void)changeScoreBy:(NSInteger)delta {
    self.score += delta;
}


#pragma mark - Properties

- (void)setScore:(NSInteger)score {
    NSInteger oldScore = _score;
    _score = score;
    if (self.scoreChangeBlock) {
        self.scoreChangeBlock(score, score - oldScore);
    }
}

@end
