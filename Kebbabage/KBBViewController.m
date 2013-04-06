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
#import "KBBMapAnnotation.h"

@interface KBBViewController ()
@property (nonatomic, strong) PostcodeClient *postcodeClient;
@property (nonatomic, strong) FSAClient *fsaClient;
@property (nonatomic, strong) JsonParser *jsonParser;

@property (nonatomic, strong) CLLocationManager *locManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;


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
    
    self.locManager = [[CLLocationManager alloc] init];
    [self.locManager setDelegate:self];
    [self.locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [self.locManager startUpdatingLocation];
    
    [self.mapView setShowsUserLocation:YES];
    
    // Plot test point
    CLLocationCoordinate2D location;
	location.latitude = (double) 51.501468;
	location.longitude = (double) -0.141596;
    
	// Add the annotation to our map view
    KBBOutlet *outlet = [[KBBOutlet alloc] init];
	KBBMapAnnotation *newAnnotation = [[KBBMapAnnotation alloc] initWithOutlet:outlet andCoordinate:location];
	[self.mapView addAnnotation:newAnnotation];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Interaction methods

- (IBAction)didTapGetPostcode:(id)sender {
    
    // 53.374288 -1.538863
    [self.postcodeClient getPostcodeForLat:53.374288 andLong:-1.538863];
    
}

- (IBAction)didTapGetOutlets:(id)sender {
}

#pragma mark -
#pragma mark Delegate callbacks

-(void)handlePostcode:(NSString *)postcode {
    NSLog(@"postcode = %@", postcode);
    [self.fsaClient getOutletsForPostcode:postcode];
}

-(void)handlePostcodeError:(NSError *)error {
    NSLog(@"error retrieving postcode: %@", error);
}

-(void)handleOutlets:(NSDictionary *)outletJson {
    NSLog(@"outletJson = %@", outletJson);
    
    JsonParser *jsonParser = [JsonParser sharedClient];
    
    NSArray *outlets = [jsonParser parseOutletsFromJson:outletJson];
    
    NSLog(@"outlets = %@", outlets);
    
    [self.postcodeClient getLatLongForArrayOfObjects:outlets];
    
}

-(void)handleOutletError:(NSError *)error {
    NSLog(@"error retrieving outlets: %@", error);
}

#pragma mark -
#pragma mark CLLocationManager delegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = newLocation.coordinate;
    
    [self.mapView setCenterCoordinate:newLocation.coordinate animated:YES];
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView regionThatFits:region];
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}

-(void)plotOutlets:(NSArray *)outletsArray {
    
    NSMutableArray *annotationsArray = [[NSMutableArray alloc] init];
    
    for (KBBOutlet *outlet in outletsArray) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([outlet latitude], [outlet longitude]);
        KBBMapAnnotation *annotation = [[KBBMapAnnotation alloc] initWithOutlet:outlet andCoordinate:coordinate];
        [annotationsArray addObject:annotation];
    }
    
    for (KBBMapAnnotation *annotation in annotationsArray) {
        [self.mapView addAnnotation:annotation];
    }

}



@end
