//
//  MALHandler.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MALHandler.h"


@implementation MALHandler

- (NSData *) get:(NSString *) resource 
{
	NSURLResponse* resp;
	NSError* error;
	
	NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
	
	// Setting up the credentials for HTTP Basic Authentication
	NSURLCredential *credential = [NSURLCredential credentialWithUser:[preferences stringForKey:@"mal_username"]
															 password:[preferences stringForKey:@"mal_password"]
														  persistence:NSURLCredentialPersistenceForSession];

	NSURLProtectionSpace *protectionSpace = [[NSURLProtectionSpace alloc]
											 initWithHost:@"myanimelist.net"
											 port:0
											 protocol:@"http"
											 realm:nil
											 authenticationMethod:nil];
	
	[[NSURLCredentialStorage sharedCredentialStorage] setDefaultCredential:credential
														forProtectionSpace:protectionSpace];
	
	// Making request
	NSString * url = [[preferences stringForKey:@"mal_username"] stringByAppendingString:resource];
	NSMutableURLRequest *req =	[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[req setHTTPMethod:@"GET"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	// Sending Synch Request: this method will only be used in secondary thread to not block the UI (using NSOperation)
	NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
	[req release];
	[resp release];
	[error release];
	return data;
}
- (NSData *) post:(NSString *) resource data:(NSString *) data{
	return nil;
}

@end
