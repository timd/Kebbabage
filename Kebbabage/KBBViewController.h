//
//  KBBViewController.h
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "KBBNetworkProtocol.h"


@interface KBBViewController : UIViewController <KBBNetworkProtocol, CLLocationManagerDelegate>

@end
