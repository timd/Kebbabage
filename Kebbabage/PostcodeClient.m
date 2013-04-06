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
        return [OHHTTPStubsResponse responseWithFile:@"test.json" contentType:@"text/json" responseTime:0.5];
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
    
    if (kStubNetworkCalls) {
        [self stubNetworkCalls];
    }
    
    return self;
}

-(void)getPostcodeForLat:(float)latitude andLong:(float)longitude {

    // GET http://uk-postcodes.com/latlng/latitude,longitude.json
    
    NSString *queryString = [NSString stringWithFormat:@"/%f,%f.json", latitude, longitude];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", kPostcodeApiUrl, queryString];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        // SUCCESS
        NSLog(@"Received %@", [JSON class]);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        // FAILURE
        NSLog(@"Error in PostCode: %@", error);
    }];
    
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:nil];
    
    [operation start];
    
}


@end
