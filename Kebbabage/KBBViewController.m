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
#import "MBProgressHUD.h"
#import "PopoverView.h"

@interface KBBViewController ()
@property (nonatomic, strong) PostcodeClient *postcodeClient;
@property (nonatomic, strong) FSAClient *fsaClient;
@property (nonatomic, strong) JsonParser *jsonParser;

@property (nonatomic, strong) CLLocationManager *locManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic) BOOL isLocating;

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
    
    [self.mapView setShowsUserLocation:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Interaction methods

- (IBAction)didTapGetPostcode:(id)sender {
    
    NSArray *annotations = [self.mapView annotations];
    for (id annotation in annotations) {
        
        if (![annotation isKindOfClass:[MKUserLocation class]]) {
            KBBMapAnnotation *kbbAnnotation = (KBBMapAnnotation *)annotation;
            [self.mapView removeAnnotation:kbbAnnotation];
        }
        
    }
    
    // 53.374288 -1.538863
    
    CLLocation *currentLocation = [self.locManager location];
    CLLocationCoordinate2D currentCoordinates = currentLocation.coordinate;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //[self.postcodeClient getPostcodeForLat:53.374288 andLong:-1.538863];
    [self.postcodeClient getPostcodeForLat:currentCoordinates.latitude andLong:currentCoordinates.longitude];
    
}
- (IBAction)didTapLocateMe:(id)sender {
    
    if (self.isLocating == YES) {
        self.isLocating = NO;
        [self.locManager stopUpdatingLocation];
    } else {
        self.isLocating = YES;
        [self.locManager startUpdatingLocation];
    }
    
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
    JsonParser *jsonParser = [JsonParser sharedClient];
    NSArray *outlets = [jsonParser parseOutletsFromJson:outletJson];
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
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

#pragma mark -
#pragma mark MKMapView delegate methods

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation {
    
    static NSString *parkingAnnotationIdentifier=@"OutletAnnotationIdentifier";
    
    if ([annotation isKindOfClass:[KBBMapAnnotation class]]){

        //Try to get an unused annotation, similar to uitableviewcells
        MKAnnotationView *annotationView=[mapView dequeueReusableAnnotationViewWithIdentifier:parkingAnnotationIdentifier];
        
        //If one isn’t available, create a new one
        if(!annotationView){
        
            annotationView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:parkingAnnotationIdentifier];
            //Here’s where the magic happens
            annotationView.image=[UIImage imageNamed:@"kebab_pin"];
            
        }
        
        return annotationView;
    }
    
    return nil;
    
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {

    for (MKAnnotationView *aV in views) {
        
        // Don't pin drop if annotation is user location
        if ([aV.annotation isKindOfClass:[MKUserLocation class]]) {
            continue;
        }
        
        // Check if current annotation is inside visible map rect, else go to next one
        MKMapPoint point =  MKMapPointForCoordinate(aV.annotation.coordinate);
        if (!MKMapRectContainsPoint(self.mapView.visibleMapRect, point)) {
            continue;
        }
        
        CGRect endFrame = aV.frame;
        
        // Move annotation out of view
        aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - self.view.frame.size.height, aV.frame.size.width, aV.frame.size.height);
        
        // Animate drop
        [UIView animateWithDuration:0.5 delay:0.04*[views indexOfObject:aV] options: UIViewAnimationOptionCurveLinear animations:^{
            
            aV.frame = endFrame;
            // Animate squash
            
        } completion:^(BOOL finished){
            if (finished) {
                [UIView animateWithDuration:0.05 animations:^{
                    
                    aV.transform = CGAffineTransformMakeScale(1.0, 0.5);
                    
                }completion:^(BOOL finished){
                    if (finished) {
                        [UIView animateWithDuration:0.2 animations:^{
                            aV.transform = CGAffineTransformIdentity;
                        }];
                    }
                }];
            }
        }];
    }
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
    KBBMapAnnotation *annotation = view.annotation;
    
    CGPoint point = [self.mapView convertCoordinate:annotation.coordinate toPointToView:self.view];
    
    KBBOutlet *outlet = annotation.outlet;
    NSString *outletName = outlet.businessName;
    
    [PopoverView showPopoverAtPoint:point inView:self.view withText:outletName delegate:nil];
    
}



@end
