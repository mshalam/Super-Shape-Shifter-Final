//
//  Level.h
//  Shape Shifter
//
//  This file holds information for level functionality. Each level is a 9x9 grid, with tiles
// either turned on or off as read from a JSON file. 
//

#import <Foundation/Foundation.h>
#import "Shapes.h"
#import "Tile.h"
#import "Chain.h"

static const NSInteger NumColumns = 9;
static const NSInteger NumRows = 9;

@interface Level : NSObject

@property (assign, nonatomic) NSUInteger targetScore;
@property (assign, nonatomic) NSUInteger maximumTime;
@property (assign, nonatomic) NSString* levelNumber;

- (NSSet *)shuffle;

- (Shapes *)shapeAtColumn:(NSInteger)column row:(NSInteger)row;

- (Shapes *)createShapeAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)shapeType;

- (instancetype)initWithFile:(NSString *)filename;

- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row;

- (void)removeShape: (Shapes *) shape;

@end
