//
//  WSNSnakeView.h
//  WaitingSnake
//
//  Created by Peter Livesey on 3/21/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSNSnakeViewProtocol <NSObject>
- (UIColor *)colorForSnakePointAtIndex:(NSUInteger)index;
- (UIColor *)colorForFoodPointAtIndex:(NSUInteger)index;
- (UIColor *)colorForHighlightedPointAtIndex:(NSUInteger)index;
@end

@interface WSNSnakeView : UIView

@property (nonatomic, weak) id<WSNSnakeViewProtocol> delegate;

@property (nonatomic, strong) UIColor *emptySquareColor;

@property (nonatomic, readonly) NSUInteger rows;
@property (nonatomic, readonly) NSUInteger columns;

/// Used to color the snake. Setting this property will redraw the screen.
@property (nonatomic, strong) NSArray *snakePoints;
/// Used to color special squares such as snake collisions. Takes precedence over other points. Setting this property will redraw the screen.
@property (nonatomic, strong) NSArray *highlightedPoints;
/// Used to color food points. Setting this property will redraw the screen.
@property (nonatomic, strong) NSArray *foodPoints;

/*!
 Instantiate and return a new instance of the snake view controller
 */
+ (instancetype)snakeViewWithSquareWidth:(CGFloat)width
                                delegate:(id<WSNSnakeViewProtocol>)delegate;

@end
