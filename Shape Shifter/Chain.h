//
//  Chain.h
//  Shape Shifter
//
//  Created by Loriah Pope on 12/5/14.
//  Copyright (c) 2014 llp260. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Shapes;

typedef NS_ENUM(NSUInteger, ChainType){
    ChainTypeHorizontal,
    ChainTypeVertical
};

@interface Chain : NSObject

@property (strong, nonatomic, readonly) NSArray *shapes;

@property (assign, nonatomic) ChainType chainType;

- (void)addShape:(Shapes *)shape;

@end
