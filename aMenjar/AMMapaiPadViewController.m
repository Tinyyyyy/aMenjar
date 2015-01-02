//
//  AMMapaiPadViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 10/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMMapaiPadViewController.h"
#import "AMMapViewController.h"
#import <MapKit/MapKit.h>
#import "MBProgressHUD.h"
#import "SWRevealViewController.h"
#import "AMPreRutaViewController.h"

@interface AMMapaiPadViewController ()<MKMapViewDelegate,MBProgressHUDDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *map;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property UIColor *colorRuta;
@property BOOL enrutado;
@property UIActivityIndicatorView *spinner;
@property MKPointAnnotation *annotationPoint;
@property MBProgressHUD *HUD;

@end

@implementation AMMapaiPadViewController

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.map.delegate = self;
    self.locationManager.delegate = self;
    self.locationManager = [[CLLocationManager alloc] init];
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    
    self.map.showsUserLocation = YES;
    [self.map setMapType:MKMapTypeStandard];
    [self.map setZoomEnabled:YES];
    [self.map setScrollEnabled:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.locationManager.distanceFilter = kCLDistanceFilterNone; //Whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    //View Area
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = 41.40392019999999;
    annotationCoord.longitude = 2.1967128000000002;
    self.annotationPoint = [[MKPointAnnotation alloc] init];
    self.annotationPoint.coordinate = annotationCoord;
    self.annotationPoint.title = @"A Menjar";
    self.annotationPoint.subtitle = @"C/Sancho de Ávila Nº 173, 08018, Barcelona";
    [self.map addAnnotation:self.annotationPoint];
    
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (annotationCoord, 6000, 6000);
    [self.map setRegion:region animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.map selectAnnotation:self.annotationPoint animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return nil;
}

- (IBAction)tipoMapa:(id)sender
{
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.map.mapType = MKMapTypeStandard;
}

- (IBAction)tipoSatelite:(id)sender
{
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.map.mapType = MKMapTypeSatellite;
}

- (IBAction)tipoHibrido:(id)sender
{
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.map.mapType = MKMapTypeHybrid;
}

- (IBAction)calcularRuta:(id)sender
{
    self.enrutado = !self.enrutado;
    if (self.enrutado) {
        self.HUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        self.HUD.delegate = self;
        [self.view.window addSubview:self.HUD];
        [self.HUD show:YES];
        [self descargarRutas];
    }
    else {
        [self.map removeOverlays:self.map.overlays];
        self.rutas = nil;
    }
}

-(void)descargarRutas
{
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = 41.40392019999999;
    annotationCoord.longitude = 2.1967128000000002;
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:annotationCoord addressDictionary:nil];
    MKMapItem *carPosition = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    MKMapItem *actualPosition = [MKMapItem mapItemForCurrentLocation];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = actualPosition;
    request.destination = carPosition;
    request.requestsAlternateRoutes = YES;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            [self.HUD hide:YES];
            if (nil != NSClassFromString(@"UIAlertController")) {
                //show alertcontroller
                UIAlertController * alert=   [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"Mapas fuera de servicio. Vuelva a intentarlo más tarde."
                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         //Do some thing here
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
                [alert addAction:ok]; // add action to uialertcontroller
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                //show alertview
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Mapas fuera de servicio. Vuelva a intentarlo más tarde."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        else  [self showDirections:response]; //response is provided by the CompletionHandler
    }];
}

- (void)showDirections:(MKDirectionsResponse *)response
{
    self.rutas = response.routes;
    
    for (int i = ((int)[response.routes count] - 1); i >= 0; --i) {
        MKRoute *route = [response.routes objectAtIndex:i];
        if (i == 0) self.colorRuta = [UIColor greenColor];
        if (i == 1) self.colorRuta = [UIColor redColor];
        else if (i == 2) self.colorRuta = [UIColor blueColor];
        [self.map addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
    [self.HUD hide:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        [routeRenderer setLineWidth:3.0f];
        routeRenderer.strokeColor = self.colorRuta;
        return routeRenderer;
    }
    else return nil;
}

- (IBAction)showRouteDetails:(id)sender {
    [self performSegueWithIdentifier:@"segueRutas" sender:self];
}

-(void)salir
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AMPreRutaViewController *routeVC = segue.destinationViewController;
    routeVC.papi = self;
}


@end