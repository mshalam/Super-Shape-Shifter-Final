//
//  Chain.m
//  Shape Shifter
//
//  Created by Loriah Pope on 12/5/14.
//  Copyright (c) 2014 llp260. All rights reserved.
//

#import "Chain.h"

@implementation Chain {
    NSMutableArray *_shapes;
}

- (void)addShape:(Shapes *)shape {
    if (_shapes == nil) {
        _shapes = [NSMutableArray array];
    }
    [_shapes addObject:shape];
}

- (NSArray *)shapes {
    return _shapes;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld shapes:%@", (long)self.chainType, self.shapes];
}
@end
