//
//  Level.m
//  Shape Shifter
//
//  Created by Loriah Pope on 12/5/14.
//  Copyright (c) 2014 llp260. All rights reserved.
//

#import "Level.h"

@implementation Level {
    Shapes *_shapes[NumColumns][NumRows];
    Tile *_tiles[NumColumns][NumRows];
}

- (instancetype)initWithFile:(NSString *)filename {
    self = [super init];
    if (self != nil) {
        NSDictionary *dictionary = [self loadJSON:filename];
        
        // Loop through the rows
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            // Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                // so we need to read this file upside down.
                NSInteger tileRow = NumRows - row - 1;
                
                // If the value is 1, create a tile object.
                if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[Tile alloc] init];
                }
            }];
        }];
        self.targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
        self.maximumTime = [dictionary[@"time"] unsignedIntegerValue];
    }
    return self;
}



- (Tile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _tiles[column][row];
}

- (Shapes *)shapeAtColumn:(NSInteger)column row:(NSInteger)row{
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _shapes[column][row];
}

- (NSSet *)shuffle {
    return [self createInitialShapes];
}

//Places a random shapes throughout the board
- (NSSet *)createInitialShapes {
    NSMutableSet *set = [NSMutableSet set];
    
    // 1
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            if (_tiles[column][row] != nil) {
                // 2
                NSUInteger shapeType;
                do {
                    shapeType = arc4random_uniform(NumShapeTypes) + 1;
                }
                while (shapeType == 4);
            
                // 3
                Shapes *shape = [self createShapeAtColumn:column row:row withType:shapeType];
            
                // 4
                [set addObject:shape];
            }
        }
    }
    return set;
}

- (Shapes *)createShapeAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)shapeType {
    Shapes *shape = [[Shapes alloc] init];
    shape.shapeType = shapeType;
    shape.column = column;
    shape.row = row;
    _shapes[column][row] = shape;
    return shape;
}

//Loads data from JSON file
- (NSDictionary *)loadJSON:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    if (path == nil) {
        NSLog(@"Could not find level file: %@", filename);
        return nil;
    }
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (data == nil) {
        NSLog(@"Could not load level file: %@, error: %@", filename, error);
        return nil;
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Level file '%@' is not valid JSON: %@", filename, error);
        return nil;
    }
    
    return dictionary;
}

- (void)removeShape: (Shapes *) shape{
    _shapes[shape.column][shape.row] = nil;
}

@end

