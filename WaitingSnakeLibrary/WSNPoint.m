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

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[WSNPoint class]])
  {
    return NO;
  }
  WSNPoint *otherPoint = object;
  if (otherPoint.x == self.x && otherPoint.y == self.y)
  {
    return YES;
  }
  return NO;
}

- (NSUInteger)hash
{
  NSUInteger prime = 31;
  return self.x + self.y * prime;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"WSNPoint: (%d, %d)", self.x, self.y];
}

@end
