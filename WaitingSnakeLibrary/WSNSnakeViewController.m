//
//  WSNSnakeViewController.m
//  WaitingSnake
//
//  Created by Peter Livesey on 3/21/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import "WSNSnakeViewController.h"
// View
#import "WSNSnakeView.h"


@interface WSNSnakeViewController ()

@property (nonatomic, strong) WSNSnakeView *view;

@end

@implementation WSNSnakeViewController

@dynamic view;

#pragma mark - Life Cycle

- (void)loadView
{
  self.view = [[WSNSnakeView alloc] init];
}

#pragma mark - Public Methods

- (void)pause
{
  
}

- (void)unPause
{
  
}

@end
