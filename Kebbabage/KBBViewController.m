//
//  KBBViewController.m
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "KBBViewController.h"
#import "PostcodeClient.h"
#import "FSAClient.h"
#import "JsonParser.h"


@interface KBBViewController ()
@property (nonatomic, strong) PostcodeClient *postcodeClient;
@property (nonatomic, strong) FSAClient *fsaClient;
@property (nonatomic, strong) JsonParser *jsonParser;
@end

@implementation KBBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.postcodeClient = [[PostcodeClient alloc] initWithBaseURL:[NSURL URLWithString:kPostcodeApiUrl]];
    [self.postcodeClient setDelegate:self];
    
    self.fsaClient = [[FSAClient alloc] initWithBaseURL:[NSURL URLWithString:kFSAApiUrl]];
    [self.fsaClient setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapGetPostcode:(id)sender {
    
    // 53.374288 -1.538863
    [self.postcodeClient getPostcodeForLat:53.374288 andLong:-1.538863];
    
}

- (IBAction)didTapGetOutlets:(id)sender {
}

-(void)handlePostcode:(NSString *)postcode {
    NSLog(@"postcode = %@", postcode);
    [self.fsaClient getOutletsForPostcode:postcode];
}

-(void)handlePostcodeError:(NSError *)error {
    NSLog(@"error retrieving postcode: %@", error);
}

-(void)handleOutlets:(NSDictionary *)outletJson {
    NSLog(@"outletJson = %@", outletJson);
}

-(void)handleOutletError:(NSError *)error {
    NSLog(@"error retrieving outlets: %@", error);
}



@end
