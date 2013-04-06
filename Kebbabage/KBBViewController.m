//
//  KBBViewController.m
//  Kebbabage
//
//  Created by Tim on 06/04/2013.
//  Copyright (c) 2013 Charismatic Megafauna Ltd. All rights reserved.
//

#import "KBBViewController.h"
#import "PostcodeClient.h"
#import "JsonParser.h"


@interface KBBViewController ()
@property (nonatomic, strong) PostcodeClient *postcodeClient;
@property (nonatomic, strong) JsonParser *jsonParser;
@end

@implementation KBBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.postcodeClient = [[PostcodeClient alloc] initWithBaseURL:[NSURL URLWithString:kPostcodeApiUrl]];
    self.jsonParser = [JsonParser sharedClient];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapGetPostcode:(id)sender {
    
    
    
}

- (IBAction)didTapGetOutlets:(id)sender {
}

@end
