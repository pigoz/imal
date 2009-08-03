//
//  MALHandler.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "MALHandler.h"
#import <RegexKit/RegexKit.h>


@implementation MALHandler
@synthesize queue;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self->queue = [NSOperationQueue new];
		[self->queue setMaxConcurrentOperationCount:4];
	}
	return self;
}

+ (MALHandler *)sharedHandler
{
	static MALHandler *sharedSingleton;
	
	@synchronized(self)
	{
		if (!sharedSingleton)
			sharedSingleton = [[MALHandler alloc] init];
		
		return sharedSingleton;
	}
	
}


- (NSData *) search:(NSString *) query type:(NSString *) type
{
	return [self get:[NSString stringWithFormat:@"/%@/search.xml?q=%@", type, 
			   [query stringByMatching:@" " withReferenceString:@"+"]]];
}

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
	NSData* _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
	[req release];
	[resp release];
	[error release];
	return _r;
}
- (NSData *) post:(NSString *) resource data:(NSString *) data{
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
	[req setHTTPMethod:@"POST"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[req setHTTPBody:[data dataUsingEncoding:NSASCIIStringEncoding]];
	
	// Sending Synch Request: this method will only be used in secondary thread to not block the UI (using NSOperation)
	NSData * _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
	[req release];
	[resp release];
	[error release];
	return _r;
}

@end
