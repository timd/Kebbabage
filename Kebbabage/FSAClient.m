//
//  FSAClient.m
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "FSAClient.h"
#import "AFHTTPClient.h"
#import "AFNetworking.h"
#import "OHHTTPStubs.h"

@implementation FSAClient

+(FSAClient *)sharedClient {
    
    static FSAClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[FSAClient alloc] initWithBaseURL:[NSURL URLWithString:kFSAApiUrl]];
    });
    
    return _sharedClient;
    
}

-(void)stubNetworkCalls {
    [OHHTTPStubs addRequestHandler:^OHHTTPStubsResponse*(NSURLRequest *request, BOOL onlyCheck) {
        return [OHHTTPStubsResponse responseWithFile:@"fsa.json" contentType:@"text/json" responseTime:0.5];
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
    
    if (kStubFSANetworkCalls) {
        [self stubNetworkCalls];
    }
    
    return self;
}

-(void)getOutletsForPostcode:(NSString *)postcode {
    
    // GET http://ratings.food.gov.uk/search/^/<postcode>/1/999/json
    
//    NSString *encodedPostcode = [postcode stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];

    NSString *queryString = [NSString stringWithFormat:@"search/^/%@/1/999/json", postcode];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kFSAApiUrl, queryString];
    
    NSString *encodedURLString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
    
    NSURL *url = [NSURL URLWithString:encodedURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // SUCCESS
        NSLog(@"Received %@", [JSON class]);
        [self.delegate handleOutlets:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // FAILURE
        NSLog(@"Error in Outlets: %@", error);
        [self.delegate handleOutletError:error];
    }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
    
    [operation start];
 
}

@end
