//
//  AMGolViewController.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 01/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMGolViewController.h"
#import "AMGolParser.h"
#import "AMGolDetalleViewController.h"

@interface AMGolViewController ()

@property int sender;
@property AMGolDetalleViewController *editVC;

@end

@implementation AMGolViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	NSURL *url = [[NSURL alloc]initWithString:@"http://www.amenjar.com/menuGol.xml"];
    AMGolParser *parser = [[AMGolParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    parser.mediodia = [[NSMutableArray alloc] init];
    parser.noche = [[NSMutableArray alloc] init];
    self.leido = [parser parseDocumentWithURL:url];
    self.mediodia = parser.mediodia;
    self.noche = parser.noche;
    
    NSString *title = @"";
    title = [[[title stringByAppendingString:parser.dia] stringByAppendingString:@" "] stringByAppendingString:parser.numero];
    title = [[[title stringByAppendingString:@"/"] stringByAppendingString:parser.mes] stringByAppendingString:@"/"];
    title = [title stringByAppendingString:parser.ano];
    [self.navigationItem setTitle:title];
    
    [self.tableView reloadData];
}

- (IBAction)reloadXML:(id)sender {
    NSURL *url = [[NSURL alloc]initWithString:@"http://www.amenjar.com/menuGol.xml"];
    AMGolParser *parser = [[AMGolParser alloc]initWithContentsOfURL:url];
    [parser setDelegate:self];
    parser.mediodia = [[NSMutableArray alloc] init];
    parser.noche = [[NSMutableArray alloc] init];
    self.leido = [parser parseDocumentWithURL:url];
    self.mediodia = parser.mediodia;
    self.noche = parser.noche;
    
    NSString *title = @"";
    title = [[[title stringByAppendingString:parser.dia] stringByAppendingString:@" "] stringByAppendingString:parser.numero];
    title = [[[title stringByAppendingString:@"/"] stringByAppendingString:parser.mes] stringByAppendingString:@"/"];
    title = [title stringByAppendingString:parser.ano];
    [self.navigationItem setTitle:title];
    
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellGol";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSString *plato = @"";
    
    if (indexPath.row == 0) plato = @"Mediodía";
    else plato = @"Noche";
    
    cell.textLabel.text = plato;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.sender = indexPath.row;
    if (self.sender == 0) {
        self.editVC.platos = self.mediodia;
        [self.editVC.navigationItem setTitle:@"Menú Mediodía"];
    }
    else {
        self.editVC.platos = self.noche;
        [self.editVC.navigationItem setTitle:@"Menú Noche"];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.editVC = segue.destinationViewController;
}

@end
