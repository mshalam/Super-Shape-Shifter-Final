//
//  GameData.h
//  Shape Shifter
//
//  Created by Loriah Pope on 12/7/14.
//  Copyright (c) 2014 llp260. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameData : NSObject <NSCoding>

@property (assign, nonatomic) long score;
@property (assign, nonatomic) int currentLevel;

@property (assign, nonatomic) int highestLevel;
@property (assign, nonatomic) long highScore;

+(instancetype)sharedGameData;
-(void)reset;
-(void)save;

@end