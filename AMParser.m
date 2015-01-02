//
//  AMParser.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 31/01/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMParser.h"

@interface AMParser () <NSXMLParserDelegate>

@property NSUInteger *count;

@property BOOL plato;

@property BOOL festivo;

@property BOOL diaB;
@property BOOL mesB;
@property BOOL anoB;
@property BOOL numeroB;

@property int nivel;

@property NSString *palabra;

@end

@implementation AMParser

-(BOOL)parseDocumentWithURL:(NSURL *)url
{
    if (url == nil) return NO;
    self.nivel = 1;
    self.count = 0;
    self.plato = false;
    self.diaB = false;
    self.mesB = false;
    self.anoB = false;
    self.numeroB = false;
    self.festivo = false;
    self.dia = @"ERROR";
    self.mes = @"";
    self.ano = @"";
    self.numero = @"";
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    BOOL ok = [xmlparser parse];
    if(!ok) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Conexión no disponible"
                                                        message:@"Esta función necesita conexión a internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return self.festivo;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {}

-(void)parserDidEndDocument:(NSXMLParser *)parser {}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    self.palabra = @"";
    if([elementName isEqualToString:@"plato"]) {
        self.plato = true;
    }
    else if([elementName isEqualToString:@"dia"]) {
        self.diaB = true;
    }
    else if([elementName isEqualToString:@"mes"]) {
        self.mesB = true;
    }
    else if([elementName isEqualToString:@"ano"]) {
        self.anoB = true;
    }
    else if([elementName isEqualToString:@"numero"]) {
        self.numeroB = true;
    }
    else if([elementName isEqualToString:@"segundos"]) {
        self.nivel = 2;
    }
    else if([elementName isEqualToString:@"postres"]) {
        self.nivel = 3;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.count == 0) {
        if ([string isEqualToString: @"FESTIVO"]) self.festivo = true;
        else self.festivo = false;
    }
    if (self.plato) {
        self.count += 1;
    }
    self.palabra = [self.palabra stringByAppendingString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"plato"]) {
        if (![self.palabra isEqualToString:@"FESTIVO"] && ![self.palabra isEqualToString:@"NO FESTIVO"]) {
            if (self.nivel == 1) [self.primeros addObject:self.palabra];
            else if (self.nivel == 2) [self.segundos addObject:self.palabra];
            else [self.postres addObject:self.palabra];
        }
        self.plato = false;
    }
    else if([elementName isEqualToString:@"dia"]) {
        self.dia = self.palabra;
        self.diaB = false;
    }
    else if([elementName isEqualToString:@"mes"]) {
        self.mes = self.palabra;
        self.mesB = false;
    }
    else if([elementName isEqualToString:@"ano"]) {
        self.ano = self.palabra;
        self.anoB = false;
    }
    else if([elementName isEqualToString:@"numero"]) {
        self.numero = self.palabra;
        self.numeroB = false;
    }
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"XMLParser error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    NSLog(@"XMLParser error: %@", [validationError localizedDescription]);
}

@end
