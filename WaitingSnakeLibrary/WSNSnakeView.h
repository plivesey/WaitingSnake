//
//  WSNSnakeView.h
//  WaitingSnake
//
//  Created by Peter Livesey on 3/21/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WSNSnakeView : UIView

/// Used to color the snake. Setting this property will redraw the screen.
@property (nonatomic, strong) NSArray *snakePoints;
/// Used to color special squares such as snake collisions. Takes precedence over other points. Setting this property will redraw the screen.
@property (nonatomic, strong) NSArray *highlightedPoints;
/// Used to color food points. Setting this property will redraw the screen.
@property (nonatomic, strong) NSArray *foodPoints;

/// Width of a game point. Should be set once at the start. The width and height of the view must be divisible by this number.
@property (nonatomic) NSUInteger pointWidth;

@end
