//
//  WSNSnakeView.m
//  WaitingSnake
//
//  Created by Peter Livesey on 3/21/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import "WSNSnakeView.h"

#import "WSNPoint.h"

#define STARTUP_FRAME CGRectMake(0, 0, 100, 100)

@interface WSNSnakeView ()

@property (nonatomic, readwrite) NSUInteger rows;
@property (nonatomic, readwrite) NSUInteger columns;
@property (nonatomic) CGFloat squareWidth;
// Padding between the top/bottom of the square grid and the view boundaries
@property (nonatomic) CGFloat verticalPadding;
// Padding between the left/right of the square grid and the view boundaries
@property (nonatomic) CGFloat horizontalPadding;
@end

@implementation WSNSnakeView

+ (instancetype)snakeViewWithSquareWidth:(CGFloat)width
                                delegate:(id<WSNSnakeViewProtocol>)delegate {
    if (width > 50) {
        width = 50;
    }
    WSNSnakeView *view = [[[self class] alloc] initWithFrame:STARTUP_FRAME];
    view.backgroundColor = [UIColor whiteColor];
    view.squareWidth = floorf(width);
    view.delegate = delegate;
    [view updateGrid];
    return view;
}

- (void)updateGrid {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.rows = (NSUInteger)(height/self.squareWidth);
    self.columns = (NSUInteger)(width/self.squareWidth);

    self.verticalPadding = floorf(0.5*(height - self.rows*self.squareWidth));
    self.horizontalPadding = floorf(0.5*(width - self.columns*self.squareWidth));
    
    [self setNeedsLayout];
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"drawRect called...");
    CGFloat xCursor;
    CGFloat yCursor = self.verticalPadding;
    CGFloat squareWidth = self.squareWidth;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorRef emptySquareColor = [self.emptySquareColor CGColor];
    
    CGRect squareRect;
    
    // Draw the background squares first
    for (NSInteger i=0; i<self.rows; i++) {
        xCursor = self.horizontalPadding;
        for (NSInteger j=0; j<self.columns; j++) {
            // Draw square at (i, j)
            squareRect = CGRectMake(xCursor, yCursor, squareWidth, squareWidth);
            CGContextSetFillColorWithColor(ctx, emptySquareColor);
            CGContextFillRect(ctx, squareRect);
            // Advance X cursor
            xCursor += self.squareWidth;
        }
        // Advance Y cursor
        yCursor += self.squareWidth;
    }
    id<WSNSnakeViewProtocol> sd = self.delegate;
    if (!sd) {
        NSLog(@"Warning: no delegate set. No special points will be drawn");
        return;
    }

    // Draw the squares in foodPoints
    NSUInteger idx = 0;
    for (WSNPoint *pt in self.foodPoints) {
        if (!(pt.y < self.rows && pt.x < self.columns)) {
            idx++;
            NSLog(@"Warning: out of bounds food point detected");
            continue;
        }
        xCursor = self.horizontalPadding + pt.x*squareWidth;
        yCursor = self.verticalPadding + pt.y*squareWidth;
        squareRect = CGRectMake(xCursor, yCursor, squareWidth, squareWidth);
        CGColorRef c = [[sd colorForFoodPointAtIndex:idx] CGColor];
        CGContextSetFillColorWithColor(ctx, c);
        CGContextFillRect(ctx, squareRect);
        idx++;
    }

    // Draw the squares in snakePoints
    idx = 0;
    for (WSNPoint *pt in self.snakePoints) {
        if (!(pt.y < self.rows && pt.x < self.columns)) {
            idx++;
            NSLog(@"Warning: out of bounds snake point detected");
            continue;
        }
        xCursor = self.horizontalPadding + pt.x*squareWidth;
        yCursor = self.verticalPadding + pt.y*squareWidth;
        squareRect = CGRectMake(xCursor, yCursor, squareWidth, squareWidth);
        CGColorRef c = [[sd colorForSnakePointAtIndex:idx] CGColor];
        CGContextSetFillColorWithColor(ctx, c);
        CGContextFillRect(ctx, squareRect);
        idx++;
    }

    // Draw the squares in highlightedPoints
    idx = 0;
    for (WSNPoint *pt in self.highlightedPoints) {
        if (!(pt.y < self.rows && pt.x < self.columns)) {
            idx++;
            NSLog(@"Warning: out of bounds highlighted point detected");
            continue;
        }
        xCursor = self.horizontalPadding + pt.x*squareWidth;
        yCursor = self.verticalPadding + pt.y*squareWidth;
        squareRect = CGRectMake(xCursor, yCursor, squareWidth, squareWidth);
        CGColorRef c = [[sd colorForHighlightedPointAtIndex:idx] CGColor];
        CGContextSetFillColorWithColor(ctx, c);
        CGContextFillRect(ctx, squareRect);
        idx++;
    }
}

- (void)setFoodPoints:(NSArray *)foodPoints {
    _foodPoints = foodPoints;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setSnakePoints:(NSArray *)snakePoints {
    _snakePoints = snakePoints;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setHighlightedPoints:(NSArray *)highlightedPoints {
    _highlightedPoints = highlightedPoints;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    if (frame.size.width < self.squareWidth || frame.size.height < self.squareWidth) {
        return;
    }
    CGSize size = self.frame.size;
    [super setFrame:frame];
    if (frame.size.height != size.height || frame.size.width != size.width) {
        [self updateGrid];
    }
}

- (void)setBounds:(CGRect)bounds {
    if (bounds.size.width < self.squareWidth || bounds.size.height < self.squareWidth) {
        return;
    }
    CGSize size = self.bounds.size;
    [super setBounds:bounds];
    if (bounds.size.height != size.height || bounds.size.width != size.width) {
        [self updateGrid];
    }
}

- (UIColor *)emptySquareColor {
    if (!_emptySquareColor) {
        _emptySquareColor = [UIColor whiteColor];
    }
    return _emptySquareColor;
}

@end
