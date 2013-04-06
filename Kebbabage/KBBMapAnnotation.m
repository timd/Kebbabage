//
//  KBBMapAnnotation.m
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "KBBMapAnnotation.h"
#import "KBBOutlet.h"

@interface KBBMapAnnotation()

@property (nonatomic, strong) KBBOutlet *outlet;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation KBBMapAnnotation

-(id)initWithOutlet:(KBBOutlet *)outlet andCoordinate:(CLLocationCoordinate2D)coordinate {
    
    if (self = [super init]) {
        
        _coordinate = coordinate;
        _outlet = outlet;
        
        return self;
    }
    
    return nil;
    
}

@end
