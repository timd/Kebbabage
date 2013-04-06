//
//  KBBOutlet.h
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KBBOutlet : NSObject

@property (nonatomic, strong) NSString *businessName;
@property (nonatomic, strong) NSString *businessType;
@property (nonatomic, strong) NSString *addressLine2;
@property (nonatomic, strong) NSString *ratingDate;
@property (nonatomic, strong) NSString *postCode;

@property (nonatomic) int ratingValue;
@property (nonatomic) int confidenceValue;
@property (nonatomic) int hygieneValue;
@property (nonatomic) int structureValue;

@property (nonatomic) float latitude;
@property (nonatomic) float longitude;

@end
