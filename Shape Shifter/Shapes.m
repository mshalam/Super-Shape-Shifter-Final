//
//  Shapes.m
//  Shape Shifter
//
//  
//

#import "Shapes.h"

@implementation Shapes

- (NSString *)spriteName {
    static NSString * const spriteNames[] = {
        @"Square",
        @"Pentagon",
        @"Hexagon",
        @"Circle",
        @"Invalid"
    };
    
    return spriteNames[self.shapeType - 1];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.shapeType,
            (long)self.column, (long)self.row];
}

@end
