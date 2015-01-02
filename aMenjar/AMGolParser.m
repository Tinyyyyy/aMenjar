//
//  AMGolParser.m
//  aMenjar
//
//  Created by Mauro Vime Castillo on 01/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import "AMGolParser.h"

@interface AMGolParser () <NSXMLParserDelegate>

@property int nivel;

@property BOOL plato;

@property NSString *palabra;

@property BOOL diaB;
@property BOOL mesB;
@property BOOL anoB;
@property BOOL numeroB;

@end

@implementation AMGolParser

-(BOOL)parseDocumentWithURL:(NSURL *)url
{
    if (url == nil) return NO;
    self.nivel = 1;
    self.plato = NO;
    self.diaB = false;
    self.mesB = false;
    self.anoB = false;
    self.numeroB = false;
    self.dia = @"ERROR";
    self.mes = @"";
    self.ano = @"";
    self.numero = @"";
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    BOOL ok = [xmlparser parse];
    if(!ok) {
    }
    return ok;
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
    else if([elementName isEqualToString:@"noche"]) {
        self.nivel = 2;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.palabra = [self.palabra stringByAppendingString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([elementName isEqualToString:@"plato"]) {
        self.plato = false;
        if(![self.palabra isEqualToString:@""]) {
            if (self.nivel == 1) [self.mediodia addObject:self.palabra];
            else [self.noche addObject:self.palabra];
        }
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
