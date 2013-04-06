//
//  KBBMapAnnotation.h
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class KBBOutlet;

@interface KBBMapAnnotation : NSObject <MKAnnotation>

-(id)initWithOutlet:(KBBOutlet *)outlet andCoordinate:(CLLocationCoordinate2D)coordinate;

@end
