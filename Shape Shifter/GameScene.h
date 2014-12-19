//
//  GameScene.h
//  Shape Shifter
//

//  Copyright (c) 2014 llp260. All rights reserved.
//

@import SpriteKit;
@import AVFoundation;

@class Level;

@interface GameScene : SKScene

@property (strong, nonatomic) Level *level;
@property (strong, nonatomic) AVAudioPlayer *tapSound;
@property (assign, nonatomic) BOOL tapOn;
@property (assign, nonatomic) NSUInteger currentScore;
@property (strong, nonatomic) SKLabelNode *score;
@property (strong, nonatomic) SKNode *shapesLayer;
@property (strong, nonatomic) SKNode *tilesLayer;
@property (strong, nonatomic) SKNode *gameLayer;
@property (assign, nonatomic) NSUInteger timeLeft;

- (void)addSpritesForShapes:(NSSet *)shapes;

- (void)addTiles;

@end
