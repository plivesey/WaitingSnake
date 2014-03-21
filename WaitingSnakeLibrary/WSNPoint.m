//
//  WSNPoint.m
//  WaitingSnake
//
//  Created by Peter Livesey on 3/21/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import "WSNPoint.h"


@interface WSNPoint ()

@property (nonatomic, readwrite) NSInteger x;
@property (nonatomic, readwrite) NSInteger y;

@end

@implementation WSNPoint

+ (instancetype)pointWithX:(NSInteger)x y:(NSInteger)y
{
  WSNPoint *point = [[WSNPoint alloc] init];
  point.x = x;
  point.y = y;
  return point;
}

@end
