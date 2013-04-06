//
//  PostcodeClient.m
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "PostcodeClient.h"
#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "OHHTTPStubs.h"
#import "JsonParser.h"

@implementation PostcodeClient

+ (PostcodeClient *)sharedClient {
    
    static PostcodeClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[PostcodeClient alloc] initWithBaseURL:[NSURL URLWithString:kPostcodeApiUrl]];
    });
    
    return _sharedClient;
    
}

-(void)stubNetworkCalls {
    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse*(NSURLRequest *request, BOOL onlyCheck) {
        NSString* basename = request.URL.absoluteString.lastPathComponent;
        if ([basename.pathExtension isEqualToString:@"json"]) {
            return [OHHTTPStubsResponse responseWithFile:basename contentType:@"text/json" responseTime:2.0];
        } else {
            return nil; // Don't stub
        }
    }];
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    // Accept HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.1
	[self setDefaultHeader:@"Accept" value:@"application/json"];
    [self setDefaultHeader:@"Content-Type" value:@"application/json"];
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    if (kStubPostcodeNetworkCalls) {
        [self stubNetworkCalls];
    }
    
    return self;
}

-(void)getPostcodeForLat:(float)latitude andLong:(float)longitude {

    // GET http://uk-postcodes.com/latlng/latitude,longitude.json
    
    NSString *queryString = [NSString stringWithFormat:@"/latlng/%f,%f.json", latitude, longitude];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kPostcodeApiUrl, queryString];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // SUCCESS
        NSLog(@"Received %@", [JSON class]);
        [self.delegate handlePostcode:@"e8"];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // FAILURE
        NSLog(@"Error in PostCode: %@", error);
        [self.delegate handlePostcodeError:error];
    }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
    
    [operation start];
    
}

-(void)getLatLongForArrayOfObjects:(NSArray *)outletsArray {
    
    NSMutableArray *operationsArray = [[NSMutableArray alloc] init];
    
    for (KBBOutlet *outlet in outletsArray) {
    
        // GET http://uk-postcodes.com/postcode/<postcode>.json
        
        NSString *postcode = [outlet postCode];
        
        NSString *urlString = [NSString stringWithFormat:@"%@postcode/%@.json", kPostcodeApiUrl, postcode];
        NSString *encodedURLString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSURL *url = [NSURL URLWithString:encodedURLString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            // SUCCESS
            
            NSLog(@"success parsing postcode");
            
            NSDictionary *geoDictionary = [JSON objectForKey:@"geo"];
            
            NSString *latString = [geoDictionary objectForKey:@"lat"];
            NSString *lngString = [geoDictionary objectForKey:@"lng"];
            
            [outlet setLatitude:[latString floatValue]];
            [outlet setLongitude:[lngString floatValue]];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            // FAILURE
            NSLog(@"Error in PostCode: %@", error);
            
        }];
        
        [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
        
        [operationsArray addObject:operation];
    
    }
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:kPostcodeApiUrl]];
    
    [client enqueueBatchOfHTTPRequestOperations:operationsArray progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        //
    } completionBlock:^(NSArray *operations) {
        
        [self.delegate plotOutlets:outletsArray];
        
    }];
    
}

@end
