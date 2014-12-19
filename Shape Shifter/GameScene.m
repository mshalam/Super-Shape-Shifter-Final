//
//  GameScene.m
//  Super Shape Shifter
//
// GameScene controls the various layers of the game. It reads and loads the current level,
// controls the tapping functionality, the random spawning of bombs, updating points, as well
// as recognizing the tapped shapes.
//
//

#import "GameScene.h"
#import "Shapes.h"
#import "Level.h"
#import "GameData.h"
#import "GameViewController.h"

#define random(min,max) ((arc4random () % (max - min +1))+min)

@import AVFoundation;

static const CGFloat TileWidth = 32.0;
static const CGFloat TileHeight = 36.0;

@interface GameScene ()

@property (assign, nonatomic) NSInteger tappedTile;
@property (assign, nonatomic) NSTimer* resetTimer;
@property (assign, nonatomic) BOOL testTime;
@property (strong, nonatomic) SKCropNode *cropLayer;
@property (strong, nonatomic) SKNode *maskLayer;
@property (strong, nonatomic) GameViewController *gameView;

@end

@implementation GameScene

//SKLabelNode* _score;
SKLabelNode* _currentLevel;

//Configures score and level text
-(void)setupHUD
{
    self.score = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.score.fontSize = 16.0;
    self.score.position = CGPointMake(-1, -261);
    self.score.fontColor = [SKColor orangeColor];
    [self addChild:_score];
    
    /* This will be shown in future implementation of the game that allows for level functionality
    _currentLevel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-Medium"];
    _currentLevel.fontSize = 17.0;
    _currentLevel.position = CGPointMake(-1, 217);
    _currentLevel.fontColor = [SKColor whiteColor];
    [self addChild:_currentLevel];*/
}

//Initializes game board as a scene with multiple layers
- (id)initWithSize:(CGSize)size {
    if ((self = [super initWithSize:size])) {
        
        self.anchorPoint = CGPointMake(0.5, 0.5);
        
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
        [self addChild:background];

        self.testTime = YES;
        
        self.gameLayer = [SKNode node];
        [self addChild:self.gameLayer];
        
        CGPoint layerPosition = CGPointMake(-TileWidth*NumColumns/2, -TileHeight*NumRows/2);
        
        self.tilesLayer = [SKNode node];
        
        self.tilesLayer.position = layerPosition;
        [self.gameLayer addChild:self.tilesLayer];
        
        self.cropLayer = [SKCropNode node];
        [self.gameLayer addChild:self.cropLayer];
        
        self.maskLayer = [SKNode node];
        self.maskLayer.position = layerPosition;
        self.cropLayer.maskNode = self.maskLayer;
        
        self.shapesLayer = [SKNode node];
        self.shapesLayer.position = layerPosition;
        
        [self.cropLayer addChild:self.shapesLayer];
        
        self.tappedTile = NSNotFound;
        
        [self setupHUD];
        
        self.currentScore = 0;
        
        //triggers bomb spawning (changeInvalid) at 1-second intervals
        self.resetTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(changeInvalid) userInfo:nil repeats:YES];
        
    }
    
    _score.text = @"0";
    
    return self;
}

//Chooses a random tile and replaces the current shape with a bomb shape
//Changes two shapes to bombs at the same time
-(void) changeInvalid{
    
    if(self.timeLeft != self.level.maximumTime )
    {
        self.timeLeft++;
        
        Shapes *shape = [self.level shapeAtColumn:random(0,6) row:random(0,6)];
        Shapes *shape2 = [self.level shapeAtColumn:random(0,6) row:random(0,6)];
        
        //shapes must be different
        while (shape2 == shape) {
            shape2 = [self.level shapeAtColumn:random(0,6) row:random(0,6)];
        }
        
        [shape.sprite removeFromParent];
        [shape2.sprite removeFromParent];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Invalid"];
        sprite.position = [self pointForColumn:shape.column row:shape.row];
        
        SKSpriteNode *sprite2 = [SKSpriteNode spriteNodeWithImageNamed:@"Invalid"];
        sprite2.position = [self pointForColumn:shape2.column row:shape2.row];
        
        [self.shapesLayer addChild:sprite];
        [self.shapesLayer addChild:sprite2];
        
        shape.sprite = sprite;
        shape2.sprite = sprite2;
        
        //changes the shape type to a 5 (bomb) so that it can be changes again
        if(shape.shapeType!=5){
            shape.shapeType = 5;
        } else {
            shape.shapeType = 1;
        }
        
        if(shape2.shapeType!=5){
            shape2.shapeType = 5;
        } else {
            shape2.shapeType = 1;
        }
    }
}

//runs when a shape is tapped
//only valid when time != 0
//shape changes depending on current shape tapped
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(self.timeLeft == 0 && self.testTime == YES){
        self.timeLeft = self.level.maximumTime;
    }
    
    else if(self.timeLeft == 0)
    {
        [_resetTimer invalidate];
        [self.shapesLayer setUserInteractionEnabled:NO];
        [self.scene setUserInteractionEnabled:NO];
        self.timeLeft = 0;
        self.testTime = NO;
        //NSLog(@"TIME IS NEGATIVE: %li",(long) self.timeLeft);
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.shapesLayer];
    
    //sound is played when user taps a shape
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"tapsound2" withExtension:@"wav"];
    self.tapSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    

    //Convert the tapped location to a grid location
    NSInteger column, row;
    if ([self convertPoint:location toColumn:&column row:&row]) {
        
        //Determines if touch is on a shape rather than an empty square
        Shapes *shape = [self.level shapeAtColumn:column row:row];
        
        // Figure out what the midpoint of the shape is.
        CGPoint centerPosition = CGPointMake(shape.sprite.position.x, shape.sprite.position.y);
        
        // Add a label for the score that slowly floats up.
        SKLabelNode *scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        scoreLabel.fontSize = 10;
        
        if (shape != nil) {
            if(shape.shapeType == 1){
                //Shape is a Square

                if(self.tapOn == false){
                    [self.tapSound play];
                }
                
                //remove current shape image
                [shape.sprite removeFromParent];
                
                //Replace square with a pentagon
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Pentagon"];
                sprite.position = [self pointForColumn:shape.column row:shape.row];
                
                //add new shape image
                [self.shapesLayer addChild:sprite];
                
                //update shape type
                shape.sprite = sprite;
                shape.shapeType = 2;
                
                //Squares are worth 20 points
                self.currentScore += 20;
                scoreLabel.text = [NSString stringWithFormat:@"%d", 20];
                
                //update score in saved game file
                [GameData sharedGameData].score +=20;
                _score.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].score];
                
            } else if(shape.shapeType == 2){
                //Shape is a Pentagon
                
                if(self.tapOn == false){
                    [self.tapSound play];
                }
                
                [shape.sprite removeFromParent];
                
                //Replace pentagon with a hexagon
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Hexagon"];
                sprite.position = [self pointForColumn:shape.column row:shape.row];
                
                //add new shape image
                [self.shapesLayer addChild:sprite];
                
                //update shape type
                shape.sprite = sprite;
                shape.shapeType = 3;
                
                //Pentagons are worth 40 points
                self.currentScore += 40;
                scoreLabel.text = [NSString stringWithFormat:@"%d", 40];
                
                //update score in saved game file
                [GameData sharedGameData].score +=40;
                _score.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].score];
                
            } else if (shape.shapeType == 3){
                //Shape is a Hexagon
                
                if(self.tapOn == false){
                    [self.tapSound play];
                }
                
                [shape.sprite removeFromParent];
                
                //Replace hexagon with a circle
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Circle"];
                sprite.position = [self pointForColumn:shape.column row:shape.row];
                
                //add new shape image
                [self.shapesLayer addChild:sprite];
                
                //update shape type
                shape.sprite = sprite;
                shape.shapeType = 4;
                
                //Hexagons are worth 60 points
                self.currentScore += 60;
                scoreLabel.text = [NSString stringWithFormat:@"%d", 60];
                
                //update score in saved game file
                [GameData sharedGameData].score +=60;
                _score.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].score];
                
            } else if(shape.shapeType == 4){
                //Shape is a circle
                
                if(self.tapOn == false){
                    [self.tapSound play];
                }
                
                [shape.sprite removeFromParent];

                //Replace circle with a square
                SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Square"];
                sprite.position = [self pointForColumn:shape.column row:shape.row];
                
                //add new shape image
                [self.shapesLayer addChild:sprite];
                
                //update shape type
                shape.sprite = sprite;
                shape.shapeType = 1;
                
                //Circles are worth 80 points
                self.currentScore += 80;
                scoreLabel.text = [NSString stringWithFormat:@"%d", 80];
                
                //update score in saved game file
                [GameData sharedGameData].score +=80;
                _score.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].score];
                
            } else if(shape.shapeType == 5){
                //Shape is a bomb
                
                //Bombs subtract 100 points
                self.currentScore -=100 ;
                scoreLabel.text = [NSString stringWithFormat:@"%d", -100];
                
                //update score in saved game file
                [GameData sharedGameData].score -=100;
                _score.text = [NSString stringWithFormat:@"%li", [GameData sharedGameData].score];
                
                //update shape type
                shape.shapeType = 1;
            }
            
        }else{
         
            
        }
        
        //Animation for floating score on tap
        scoreLabel.position = centerPosition;
        scoreLabel.fontColor = [SKColor orangeColor];
        scoreLabel.zPosition = 300;
        [self.shapesLayer addChild:scoreLabel];
        
        SKAction *moveAction = [SKAction moveBy:CGVectorMake(0, 3) duration:0.7];
        moveAction.timingMode = SKActionTimingEaseOut;
        [scoreLabel runAction:[SKAction sequence:@[
                                                   moveAction,
                                                   [SKAction removeFromParent]
                                                   ]]];
    }
}

//Registers users' finger has left the screen
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.tappedTile = NSNotFound;
}

//Touch is not registered in the event the OS stops the app (e.g. for a phone call)
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (BOOL)convertPoint:(CGPoint)point toColumn:(NSInteger *)column row:(NSInteger *)row {
    NSParameterAssert(column);
    NSParameterAssert(row);
    
    // Is this a valid location within the cookies layer? If yes,
    // calculate the corresponding row and column numbers.
    if (point.x >= 0 && point.x < NumColumns*TileWidth &&
        point.y >= 0 && point.y < NumRows*TileHeight) {
        
        *column = point.x / TileWidth;
        *row = point.y / TileHeight;
        return YES;
        
    } else {
        *column = NSNotFound;  // invalid location
        *row = NSNotFound;
        return NO;
    }
}

- (void)addTiles {
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            if ([self.level tileAtColumn:column row:row] != nil) {
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:@"MaskTile"];
                tileNode.position = [self pointForColumn:column row:row];
                [self.maskLayer addChild:tileNode];
            }
        }
    }
}

- (void)addSpritesForShapes:(NSSet *)shapes {
    for (Shapes *shape in shapes) {
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:[shape spriteName]];
        sprite.position = [self pointForColumn:shape.column row:shape.row];
        [self.shapesLayer addChild:sprite];
        shape.sprite = sprite;
    }
    
    //used for rounding tile layers
    for (NSInteger row = 0; row <= NumRows; row++) {
        for (NSInteger column = 0; column <= NumColumns; column++) {
            
            BOOL topLeft     = (column > 0) && (row < NumRows)
            && [self.level tileAtColumn:column - 1 row:row];
            
            BOOL bottomLeft  = (column > 0) && (row > 0)
            && [self.level tileAtColumn:column - 1 row:row - 1];
            
            BOOL topRight    = (column < NumColumns) && (row < NumRows)
            && [self.level tileAtColumn:column row:row];
            
            BOOL bottomRight = (column < NumColumns) && (row > 0)
            && [self.level tileAtColumn:column row:row - 1];

            NSUInteger value = topLeft | topRight << 1 | bottomLeft << 2 | bottomRight << 3;
            
            if (value != 0 && value != 6 && value != 9) {
                NSString *name = [NSString stringWithFormat:@"Tile_%lu", (long)value];
                SKSpriteNode *tileNode = [SKSpriteNode spriteNodeWithImageNamed:name];
                CGPoint point = [self pointForColumn:column row:row];
                point.x -= TileWidth/2;
                point.y -= TileHeight/2;
                tileNode.position = point;
                [self.tilesLayer addChild:tileNode];
            }
        }
    }
    
}

- (CGPoint)pointForColumn:(NSInteger)column row:(NSInteger)row {
    return CGPointMake(column*TileWidth + TileWidth/2, row*TileHeight + TileHeight/2);
}

@end
