//
//  AMGolParser.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 01/02/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMGolParser : NSXMLParser

@property NSMutableArray *mediodia;
@property NSMutableArray *noche;
@property NSString *dia;
@property NSString *mes;
@property NSString *ano;
@property NSString *numero;

-(BOOL)parseDocumentWithURL:(NSURL *)url;

@end
