//
//  JsonParser.m
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "JsonParser.h"
#import "KBBOutlet.h"

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

-(NSArray *)parseOutletsFromJson:(NSDictionary *)jsonDictionary {
    
    if (!jsonDictionary) {
        return nil;
    }
    

    
    NSDictionary *fhrsEstablishmentDictionary = [jsonDictionary valueForKey:@"FHRSEstablishment"];
    
    NSDictionary *establishmentCollectionDictionary = [fhrsEstablishmentDictionary valueForKey:@"EstablishmentCollection"];
    
    NSArray *establishmentDetailArray = [establishmentCollectionDictionary valueForKey:@"EstablishmentDetail"];

    NSMutableArray *establishmentsArray = [[NSMutableArray alloc] initWithCapacity:[establishmentDetailArray count]];
    
    for (NSDictionary *establishment in establishmentDetailArray) {

        KBBOutlet *outlet = [[KBBOutlet alloc] init];
        
        NSString *businessName = [establishment valueForKey:@"BusinessName"];
        NSLog(@"businessName = %@", businessName);
        [outlet setBusinessName:businessName];
        
        // Trap for <null> scores
        if ([[establishment objectForKey:@"Scores"] isKindOfClass:[NSDictionary class]]) {
        
            NSDictionary *scoresDictionary = [establishment objectForKey:@"Scores"];
            
            if (scoresDictionary) {
            
                int confidence = [[scoresDictionary objectForKey:@"ConfidenceInManagement"] intValue];
                int hygiene = [[scoresDictionary objectForKey:@"Hygiene"] intValue];
                int structural = [[scoresDictionary objectForKey:@"Structural"] intValue];
                
                [outlet setConfidenceValue:confidence];
                [outlet setHygieneValue:hygiene];
                [outlet setStructureValue:structural];
                
                [establishmentsArray addObject:outlet];
                
            }
        }
        
    }
    
    return establishmentsArray;
}




@end
