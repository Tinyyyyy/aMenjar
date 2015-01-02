//
//  AMQRConfigViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 06/04/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMQRConfigViewController.h"
#import "SevenSwitch.h"

@interface AMQRConfigViewController ()

@property (weak, nonatomic) IBOutlet UIView *switchView;
@property BOOL QRpermitido;
@property (weak, nonatomic) IBOutlet UIImageView *QR;

@end

@implementation AMQRConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) { }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    NSData *data1 = [[NSUserDefaults standardUserDefaults] objectForKey:@"QRboolKey"];
    if(data1 == nil){
        self.QRpermitido = YES;
        [[NSUserDefaults standardUserDefaults] setBool:self.QRpermitido forKey:@"QRboolKey"];
    }
    else {
        self.QRpermitido = (BOOL)[[NSUserDefaults standardUserDefaults] boolForKey:@"QRboolKey"];
    }
    
    SevenSwitch *mySwitch2 = [[SevenSwitch alloc] initWithFrame:CGRectMake(0, 0, 65, 30)];
    mySwitch2.center = CGPointMake(277.50f,44);
    [mySwitch2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    mySwitch2.offImage = [UIImage imageNamed:@"cross"];
    mySwitch2.onImage = [UIImage imageNamed:@"check"];
    mySwitch2.onTintColor = [UIColor colorWithRed:(66.0f/255.0f) green:(198.0f/255.0f) blue:(64.0f/255.0f) alpha:1.0f];
    mySwitch2.isRounded = NO;
    //[self.switchView addSubview:mySwitch2];
    [mySwitch2 setOn:self.QRpermitido animated:YES];
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSString *ejemploPedido = @"Menú 1\n\nNombre: Mauro\n\nHora de recogida: 14:00\n\nPlato 1: Ensalada de lentejas\n\nPlato 2: Escalopines de ternera al gorgonzola\n\nPostre: Crema de limón\n\nBebida: Agua con gas\n\nPara llevar: SI\n\nFecha: 7/4/2014";
    NSData *data = [ejemploPedido dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    CIImage *outputImage = [filter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage
                                    fromRect:[outputImage extent]];
    UIImage *image = [UIImage imageWithCGImage:cgImage
                                         scale:1.
                                   orientation:UIImageOrientationUp];
    UIImage *resized = [self resizeImage:image
                             withQuality:kCGInterpolationNone
                                    rate:5.0];
    self.QR.image = resized;
}

- (void)switchChanged:(SevenSwitch *)sender {
    self.QRpermitido = !self.QRpermitido;
	[[NSUserDefaults standardUserDefaults] setBool:self.QRpermitido forKey:@"QRboolKey"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)exit:(id)sender {
    [self.anterior exit];
}

// =============================================================================
#pragma mark - Private

- (UIImage *)resizeImage:(UIImage *)image
             withQuality:(CGInterpolationQuality)quality
                    rate:(CGFloat)rate
{
	UIImage *resized = nil;
	CGFloat width = image.size.width * rate;
	CGFloat height = image.size.height * rate;
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(context, quality);
	[image drawInRect:CGRectMake(0, 0, width, height)];
	resized = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resized;
}

@end
