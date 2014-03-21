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
// Models
#import "WSNPoint.h"
// Random
#import <stdlib.h>


#define STARTING_LENGTH 5
#define SECONDS_PER_MOVE .25
#define FINAL_SECONDS_PER_MOVE  0.10


typedef enum {
  WSNSnakeDirectionRight,
  WSNSnakeDirectionDown,
  WSNSnakeDirectionLeft,
  WSNSnakeDirectionUp
} WSNSnakeDirection;

typedef enum {
  WSNGameStatusSetup,
  WSNGameStatusPlaying,
  WSNGameStatusPaused,
  WSNGameStatusFinished
} WSNGameStatus;

@interface WSNSnakeViewController () <WSNSnakeViewProtocol>

@property (nonatomic, strong) WSNSnakeView *snakeView;

@property (nonatomic) NSInteger squareSize;
@property (nonatomic, strong) NSMutableArray *snakeArray;
@property (nonatomic, strong) WSNPoint *currentPoint;
@property (nonatomic, strong) WSNPoint *foodPoint;

@property (nonatomic) WSNSnakeDirection direction;
@property (nonatomic) WSNGameStatus gameStatus;

@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, strong) NSTimer *speedupTimer;
@property (nonatomic) NSUInteger speedupCount;
@property (nonatomic) NSTimeInterval currentDelay;

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic) BOOL initialized;

@property (nonatomic, strong) NSArray *possibleSnakeColors;
@property (nonatomic, strong) NSArray *currentSnakeColors;

@property (nonatomic) NSTimeInterval startingDelay;
@property (nonatomic) NSTimeInterval endingDelay;
@property (nonatomic) NSTimeInterval speedupDelay;
@property (nonatomic) NSUInteger numberOfSpeedups;

@end

@implementation WSNSnakeViewController

@dynamic view;

#pragma mark - Life Cycle

+ (instancetype)snakeViewControllerWithSquareSize:(NSInteger)squareSize
{
    WSNSnakeViewController *viewController = [[[self class] alloc] init];
    viewController.squareSize = squareSize;
    
    viewController.startingDelay = SECONDS_PER_MOVE;
    viewController.speedupDelay = 5.0;
    viewController.numberOfSpeedups = 10;
    viewController.endingDelay = FINAL_SECONDS_PER_MOVE;

    return viewController;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(swipedDown:)];
  swipe.direction = UISwipeGestureRecognizerDirectionDown;
  [self.view addGestureRecognizer:swipe];
  
  swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(swipedUp:)];
  swipe.direction = UISwipeGestureRecognizerDirectionUp;
  [self.view addGestureRecognizer:swipe];
  
  swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(swipedLeft:)];
  swipe.direction = UISwipeGestureRecognizerDirectionLeft;
  [self.view addGestureRecognizer:swipe];
  
  swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(swipedRight:)];
  swipe.direction = UISwipeGestureRecognizerDirectionRight;
  [self.view addGestureRecognizer:swipe];
  
  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(tappedScreen:)];
  [self.view addGestureRecognizer:tap];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(pause)
                                               name:UIApplicationWillResignActiveNotification
                                             object:nil];
  
  // These colors are hilariously ugly
  NSMutableArray *possibleSnakeColors = [NSMutableArray array];
  [possibleSnakeColors addObject:[UIColor purpleColor]];
  [possibleSnakeColors addObject:[UIColor yellowColor]];
  [possibleSnakeColors addObject:[UIColor greenColor]];
  [possibleSnakeColors addObject:[UIColor blueColor]];
  [possibleSnakeColors addObject:[UIColor cyanColor]];
  [possibleSnakeColors addObject:[UIColor orangeColor]];
  [possibleSnakeColors addObject:[UIColor magentaColor]];
  self.possibleSnakeColors = possibleSnakeColors;
    
    self.speedupCount = 0;
    self.currentDelay = self.startingDelay;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  // Let's do setup win view will appear so we have an accurate idea of our view height
  if (!self.initialized)
  {
    [self setupNewGame];
  }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (void)pause
{
    self.gameStatus = WSNGameStatusPaused;
    self.infoLabel.text = @"Game Paused.\nTap screen to continue.";
    [self.snakeView addSubview:self.infoLabel];
    [self.gameTimer invalidate];
    [self.speedupTimer invalidate];
}

- (void)unPause
{
  [self resumeGame];
}

#pragma mark - Helpers

- (void)setupNewGame
{
    self.currentDelay = self.startingDelay;
    self.speedupCount = 0;
    
  for (UIView *view in self.view.subviews)
  {
    [view removeFromSuperview];
  }
  self.snakeView = [WSNSnakeView snakeViewWithSquareWidth:self.squareSize delegate:self];
  self.snakeView.frame = self.view.bounds;
  [self.view addSubview:self.snakeView];
  
  // Check the view is good to go.
  NSAssert(self.snakeView.columns >= STARTING_LENGTH * 2, @"The view isn't wide enough. It must be at least ten times as wide as the square width");
  NSAssert(self.snakeView.rows >= 4, @"The view isn't high enough. It must be at least four times as high as the square width");
  
  self.gameStatus = WSNGameStatusSetup;
  
  // Reset all data
  self.snakeArray = [NSMutableArray array];
  self.currentPoint = nil;
  
  [self resetSnakeColors];
  
  NSInteger startingY = self.snakeView.rows / 2;
  for (int i = 0; i<STARTING_LENGTH; i++)
  {
    WSNPoint *point = [WSNPoint pointWithX:i y:startingY];
    // Start of the snake is the front of the array
    [self.snakeArray insertObject:point atIndex:0];
    // This will keep overriding until the last point is the starting point
    self.currentPoint = point;
  }
  self.direction = WSNSnakeDirectionRight;
  
  [self findNewFoodPoint];
  
  self.snakeView.snakePoints = self.snakeArray;
  
  NSAssert(self.foodPoint, @"Why no food?");
  self.snakeView.foodPoints = @[self.foodPoint];
  
  self.infoLabel.text = @"Tap the screen to begin";
  [self.view addSubview:self.infoLabel];
}

- (void)findNewFoodPoint
{
  // Not too efficient, but that's ok
  NSMutableArray *possiblePoints = [NSMutableArray array];
  for (int x = 0; x<self.snakeView.columns; x++)
  {
    for (int y = 0; y<self.snakeView.rows; y++)
    {
      [possiblePoints addObject:[WSNPoint pointWithX:x y:y]];
    }
  }
  
  for (WSNPoint *point in self.snakeArray)
  {
    [possiblePoints removeObject:point];
  }
  
  if ([possiblePoints count] == 0)
  {
    [self endGame:YES];
    return;
  }
  
  NSUInteger index = rand() % [possiblePoints count];
  self.foodPoint = [possiblePoints objectAtIndex:index];
}

- (void)resetSnakeColors
{
  NSUInteger numberOfColors = rand() % 4 + 1;
  NSMutableArray *colors = [NSMutableArray arrayWithCapacity:numberOfColors];
  for (int i = 0; i<numberOfColors; i++)
  {
    NSUInteger index = rand() % [self.possibleSnakeColors count];
    [colors addObject:self.possibleSnakeColors[index]];
  }
  self.currentSnakeColors = colors;
}

- (void)resumeGame
{
    self.gameStatus = WSNGameStatusPlaying;
    
    [self.infoLabel removeFromSuperview];
    
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:self.currentDelay
                                                      target:self
                                                    selector:@selector(timerFired)
                                                    userInfo:nil
                                                     repeats:NO];
    self.speedupTimer = [NSTimer scheduledTimerWithTimeInterval:self.speedupDelay
                                                         target:self
                                                       selector:@selector(speedupTimerFired)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (void)endGame:(BOOL)won
{
  self.gameStatus = WSNGameStatusFinished;
  
  [self.gameTimer invalidate];
  
  if (won)
  {
    self.infoLabel.text = @"Somehow...you won snake. That's epic.\nTap to play again.";
  }
  else
  {
    self.infoLabel.text = [NSString stringWithFormat:@"Score: %lu\nTap to play again.", (unsigned long)[self.snakeArray count]];
  }
  [self.view addSubview:self.infoLabel];
  
  [self.delegate snakeViewController:self didFinishGameWithScore:[self.snakeArray count]];
}
                    
#pragma mark - User Interaction

- (void)swipedUp:(UISwipeGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateEnded &&
      self.gameStatus == WSNGameStatusPlaying &&
      self.direction != WSNSnakeDirectionDown)
  {
    self.direction = WSNSnakeDirectionUp;
  }
}

- (void)swipedRight:(UISwipeGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateEnded &&
      self.gameStatus == WSNGameStatusPlaying &&
      self.direction != WSNSnakeDirectionLeft)
  {
    self.direction = WSNSnakeDirectionRight;
  }
}

- (void)swipedDown:(UISwipeGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateEnded &&
      self.gameStatus == WSNGameStatusPlaying &&
      self.direction != WSNSnakeDirectionUp)
  {
    self.direction = WSNSnakeDirectionDown;
  }
}

- (void)swipedLeft:(UISwipeGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateEnded &&
      self.gameStatus == WSNGameStatusPlaying &&
      self.direction != WSNSnakeDirectionRight)
  {
    self.direction = WSNSnakeDirectionLeft;
  }
}

- (void)tappedScreen:(UITapGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateEnded)
  {
    if (self.gameStatus == WSNGameStatusSetup || self.gameStatus == WSNGameStatusPaused)
    {
      [self resumeGame];
    }
    else if (self.gameStatus == WSNGameStatusPlaying)
    {
      [self pause];
    }
    else if (self.gameStatus == WSNGameStatusFinished)
    {
      [self setupNewGame];
    }
  }
}

#pragma mark - Timer
                    
- (void)timerFired
{
    WSNPoint *firstPoint = [self.snakeArray firstObject];
    
    [self.snakeArray insertObject:[self nextPointFromCurrentPoint:firstPoint]
                          atIndex:0];
    // New current point
    self.currentPoint = [self.snakeArray firstObject];
    
    if ([self.snakeArray containsObject:self.foodPoint])
    {
        // We ate some food. Array is now one longer and we need more food.
        [self findNewFoodPoint];
    }
    else
    {
        // We're moving, so remove last point
        [self.snakeArray removeLastObject];
    }
    
    // Now let's check for collisions. Only the new point can possible collide because the rest haven't moved.
    WSNPoint *collisionPoint = [self collisionPoint];
    if (collisionPoint)
    {
        [self endGame:NO];
        self.snakeView.highlightedPoints = @[collisionPoint];
    }
    
    self.snakeView.snakePoints = self.snakeArray;
    self.snakeView.foodPoints = @[self.foodPoint];
    if ([self.gameTimer isValid]) {
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:self.currentDelay
                                                          target:self
                                                        selector:@selector(timerFired)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)speedupTimerFired {
    // Speed the snake up
    if (self.speedupCount == self.numberOfSpeedups) {
        [self.speedupTimer invalidate];
        return;
    }
    self.speedupCount++;
    self.currentDelay += (self.endingDelay - self.startingDelay)/((CGFloat) self.numberOfSpeedups);
    self.speedupTimer = [NSTimer scheduledTimerWithTimeInterval:self.speedupDelay
                                                         target:self
                                                       selector:@selector(speedupTimerFired)
                                                       userInfo:nil
                                                        repeats:NO];
}

- (WSNPoint *)nextPointFromCurrentPoint:(WSNPoint *)currentPoint
{
    NSInteger nextPointX = currentPoint.x;
    NSInteger nextPointY = currentPoint.y;
    switch (self.direction)
    {
        case WSNSnakeDirectionUp:
            nextPointY--;
            break;
        case WSNSnakeDirectionDown:
            nextPointY++;
            break;
        case WSNSnakeDirectionLeft:
            nextPointX--;
            break;
        case WSNSnakeDirectionRight:
            nextPointX++;
            break;
    }
    if (self.wallsWrapAround) {
        // Wrap the snake around if necessary
        if (nextPointX < 0) {
            nextPointX = self.snakeView.columns - 1;
        }
        else if (nextPointX >= self.snakeView.columns) {
            nextPointX = 0;
        }
        if (nextPointY < 0) {
            nextPointY = self.snakeView.rows - 1;
        }
        else if (nextPointY >= self.snakeView.rows) {
            nextPointY = 0;
        }
    }
    return [WSNPoint pointWithX:nextPointX y:nextPointY];
}

/*!
 Nil if no collision
 */
- (WSNPoint *)collisionPoint
{
  for (NSUInteger i = 1; i<[self.snakeArray count]; i++)
  {
    if ([self.currentPoint isEqual:self.snakeArray[i]])
    {
      // Current point is the same as some other point in the snake
      return self.currentPoint;
    }
  }
  if (self.currentPoint.x < 0)
  {
    return [WSNPoint pointWithX:0 y:self.currentPoint.y];
  }
  if (self.currentPoint.x >= self.snakeView.columns)
  {
    return [WSNPoint pointWithX:self.snakeView.columns-1 y:self.currentPoint.y];
  }
  if (self.currentPoint.y < 0)
  {
    return [WSNPoint pointWithX:self.currentPoint.x y:0];
  }
  if (self.currentPoint.y >= self.snakeView.rows)
  {
    return [WSNPoint pointWithX:self.currentPoint.x y:self.snakeView.rows-1];
  }
  return nil;
}

#pragma mark - Properties

- (UILabel *)infoLabel
{
  if (!_infoLabel)
  {
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, self.view.frame.size.width-40, 200)];
    _infoLabel.backgroundColor = [UIColor colorWithWhite:.5 alpha:.5];
    _infoLabel.numberOfLines = 0;
  }
  return _infoLabel;
}

#pragma mark - Snake View Delegate

- (UIColor *)colorForSnakePointAtIndex:(NSUInteger)index
{
  return self.currentSnakeColors[index % [self.currentSnakeColors count]];
}

- (UIColor *)colorForFoodPointAtIndex:(NSUInteger)index
{
  return [UIColor blackColor];
}

- (UIColor *)colorForHighlightedPointAtIndex:(NSUInteger)index
{
  return [UIColor redColor];
}


@end
