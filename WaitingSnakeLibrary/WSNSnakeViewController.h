//
//  WSNSnakeViewController.h
//  WaitingSnake
//
//  Created by Peter Livesey on 3/21/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol WSNSnakeDelegate;

/*
 Ideas:
 
 By default, tap to start the game. Should have a label telling users thats what they need to do.
 
 Pause = Freeze the game, tap to restart? Registers for app background notification to automatically pause?
 Maybe tap also pauses the game? Not sure if that'll interfere with the swipe but I'm guessing not.
 */

@interface WSNSnakeViewController : UIViewController

@property (nonatomic) BOOL wallsWrapAround;
@property (nonatomic) BOOL tapControlsEnabled;
// By default the 'center' of the screen is in the middle. But you can change this if you want.
@property (nonatomic) CGPoint tapControlsScreenCenter;
@property (nonatomic, weak) id<WSNSnakeDelegate> delegate;

@property (nonatomic, readonly) NSInteger score;

+ (instancetype)snakeViewControllerWithSquareSize:(NSInteger)squareSize;

- (void)pause;
- (void)unPause;

@end

@protocol WSNSnakeDelegate <NSObject>

- (void)snakeViewController:(WSNSnakeViewController *)snakeViewController
     didFinishGameWithScore:(double)score;

@end
