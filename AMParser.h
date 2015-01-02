//
//  AMParser.h
//  aMenjar
//
//  Created by Mauro Vime Castillo on 31/01/14.
//  Copyright (c) 2014 Mauro Vime Castillo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMParser : NSXMLParser

@property NSMutableArray *primeros;
@property NSMutableArray *segundos;
@property NSMutableArray *postres;
@property NSString *dia;
@property NSString *mes;
@property NSString *ano;
@property NSString *numero;

-(BOOL)parseDocumentWithURL:(NSURL *)url;

@end
