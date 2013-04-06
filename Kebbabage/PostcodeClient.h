//
//  PostcodeClient.h
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "AFHTTPClient.h"
#import "KBBNetworkProtocol.h"
#import "KBBOutlet.h"

@interface PostcodeClient : AFHTTPClient

@property (nonatomic, weak) id <KBBNetworkProtocol> delegate;

+ (PostcodeClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;
-(void)getPostcodeForLat:(float)latitude andLong:(float)longitude;

-(void)getLatLongForArrayOfObjects:(NSArray *)outletsArray;

@end
