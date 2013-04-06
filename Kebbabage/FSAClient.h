//
//  FSAClient.h
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "AFHTTPClient.h"
#import "KBBNetworkProtocol.h"

@interface FSAClient : AFHTTPClient

@property (nonatomic, weak) id <KBBNetworkProtocol> delegate;

+(FSAClient *)sharedClient;
-(id)initWithBaseURL:(NSURL *)url;
-(void)getOutletsForPostcode:(NSString *)postcode;


@end



