//
//  KBBNetworkProtocol.h
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KBBNetworkProtocol <NSObject>

-(void)handlePostcode:(NSString *)postcode;
-(void)handlePostcodeError:(NSError *)error;

-(void)handleOutlets:(NSDictionary *)outletJson;
-(void)handleOutletError:(NSError *)error;

@end
