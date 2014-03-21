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


typedef enum {
  WSNSnakeDirectionRight,
  WSNSnakeDirectionDown,
  WSNSnakeDirectionLeft,
  WSNSnakeDirectionUp
} WSNSnakeDirection;

typedef enum {
  WSNGameStatusSetup,
  WSNGameStatusPlaying,
  WSNGameStatusPaused
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

@property (nonatomic, strong) UILabel *infoLabel;

@property (nonatomic) BOOL initialized;

@end

@implementation WSNSnakeViewController

@dynamic view;

#pragma mark - Life Cycle

+ (instancetype)snakeViewControllerWithSquareSize:(NSInteger)squareSize
{
  WSNSnakeViewController *viewController = [[[self class] alloc] init];
  viewController.squareSize = squareSize;
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

#pragma mark - Public Methods

- (void)pause
{
  
}

- (void)unPause
{
  
}

#pragma mark - Helpers

- (void)setupNewGame
{
  NSAssert(self.snakeView.columns < STARTING_LENGTH * 2, @"The view isn't wide enough. It must be at least ten times as wide as the square width");
  NSAssert(self.snakeView.rows < 4, @"The view isn't high enough. It must be at least four times as high as the square width");
  
  self.gameStatus = WSNGameStatusSetup;
  
  for (UIView *view in self.view.subviews)
  {
    [view removeFromSuperview];
  }
  self.snakeView = [WSNSnakeView snakeViewWithSquareWidth:self.squareSize delegate:self];
  self.snakeView.frame = self.view.bounds;
  [self.view addSubview:self.snakeView];
  
  // Reset all data
  self.snakeArray = [NSMutableArray array];
  self.currentPoint = nil;
  
  NSInteger startingY = self.snakeView.rows / 2;
  for (int i = 0; i<STARTING_LENGTH; i++)
  {
    WSNPoint *point = [WSNPoint pointWithX:i y:startingY];
    [self.snakeArray addObject:point];
    // This will keep overriding until the last point is the starting point
    self.currentPoint = point;
  }
  self.direction = WSNSnakeDirectionRight;
  
  [self findNewFoodPoint];
  
  self.snakeView.snakePoints = self.snakeArray;
  
  NSAssert(self.foodPoint, @"Why no food?");
  self.snakeView.foodPoints = @[self.foodPoint];
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
    // VICTORY!
    NSAssert(NO, @"Too bad...");
  }
  
  NSUInteger index = rand() % [possiblePoints count];
  self.foodPoint = [possiblePoints objectAtIndex:index];
  
  self.infoLabel.text = @"Tap the screen to being";
  [self.view addSubview:self.infoLabel];
}

- (void)startGame
{
  [self.infoLabel removeFromSuperview];
  
  self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:SECONDS_PER_MOVE
                                                    target:self
                                                  selector:@selector(timerFired)
                                                  userInfo:nil
                                                   repeats:YES];
}
                    
#pragma mark - User Interaction

- (void)swipedUp:(UISwipeGestureRecognizer *)gesture
{
  
}

- (void)swipedRight:(UISwipeGestureRecognizer *)gesture
{
  
}

- (void)swipedDown:(UISwipeGestureRecognizer *)gesture
{
  
}

- (void)swipedLeft:(UISwipeGestureRecognizer *)gesture
{
  
}

- (void)tappedScreen:(UITapGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateRecognized)
  {
    if (self.gameStatus == WSNGameStatusSetup)
    {
      [self startGame];
    }
  }
}

#pragma mark - Timer
                    
- (void)timerFired
{
  
}

#pragma mark - Properties

- (UILabel *)infoLabel
{
  if (!_infoLabel)
  {
    _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, self.view.frame.size.width-40, 200)];
    _infoLabel.backgroundColor = [UIColor grayColor];
  }
  return _infoLabel;
}

#pragma mark - Snake View Delegate

- (UIColor *)colorForSnakePointAtIndex:(NSUInteger)index
{
  return [UIColor blackColor];
}

- (UIColor *)colorForFoodPointAtIndex:(NSUInteger)index
{
  return [UIColor blueColor];
}

- (UIColor *)colorForHighlightedPointAtIndex:(NSUInteger)index
{
  return [UIColor redColor];
}


@end
