//
//  Shapes.h
//  Shape Shifter
//
//  This file holds the data and images for the shapes
//

#import <Foundation/Foundation.h>

@import SpriteKit;

static const NSUInteger NumShapeTypes = 4;

@interface Shapes : NSObject

@property (assign, nonatomic) NSInteger column;
@property (assign, nonatomic) NSInteger row;
@property (assign, nonatomic) NSUInteger shapeType;
@property (assign, nonatomic) SKSpriteNode *sprite;

- (NSString *)spriteName;

@end
