//
//  JsonParser.m
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "JsonParser.h"

@implementation JsonParser

+(JsonParser *)sharedClient {
    
    static JsonParser *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JsonParser alloc] init];
    });
    
    return _sharedClient;
    
}

-(id)init {
    if (self = [super init]) {
        // Configure stuff
        return self;
    }
    return nil;
}

#pragma mark -
#pragma mark Parsing methods

-(NSString *)parsePostcodeFromJson:(NSData *)json {
    return @"foo";
}


@end
