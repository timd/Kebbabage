//
//  JsonParser.h
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBBParsingProtocol.h"

@interface JsonParser : NSObject <KBBParsingProtocol>

+(JsonParser *)sharedClient;
-(NSString *)parsePostcodeFromJson:(NSData *)json;

-(NSArray *)parseOutletsFromJson:(NSDictionary *)jsonDictionary;

@end
