//
//  WSNPoint.h
//  WaitingSnake
//
//  Created by Peter Livesey on 3/21/14.
//  Copyright (c) 2014 Peter Livesey & Austin Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WSNPoint : NSObject

@property (nonatomic, readonly) NSInteger x;
@property (nonatomic, readonly) NSInteger y;

+ (instancetype)pointWithX:(NSInteger)x y:(NSInteger)y;

@end
