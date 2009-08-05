//
//  MALHandler.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/2/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "MALHandler.h"
#import "NSString+Base64.h"

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
	
	return sharedSingleton;
}


- (NSData *) search:(NSString *) query type:(NSString *) type
{
	NSString * _q = [query stringByMatching:@" " replace: 50 withReferenceString:@"+"];
	return [self get:[NSString stringWithFormat:@"/%@/search.xml?q=%@", type, _q]];
}

- (NSData *) get:(NSString *) resource 
{
	NSURLResponse* resp;
	NSError* error;
	
	NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
	
	// Building authorization field, for basic http auth
	NSString *format = [NSString stringWithFormat:@"%@:%@", [preferences stringForKey:@"mal_username"], 
															[preferences stringForKey:@"mal_password"]];	
	
	// Making request
	NSString * url = [[preferences stringForKey:@"mal_api_address"] stringByAppendingString:resource];
	NSMutableURLRequest *req =	[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[req setHTTPMethod:@"GET"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[req setValue:[NSString stringWithFormat:@"Basic %@", [format base64Encoding]]
				forHTTPHeaderField:@"Authorization"];
	
	// Sending Synch Request: this method will only be used in secondary thread to not block the UI (using NSOperation)
	NSData* _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
//	[req release];
//	[resp release];
//	[error release];
	return _r;
}
- (NSData *) post:(NSString *) resource data:(NSData *) data{
	NSURLResponse* resp;
	NSError* error;
	
	NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
	
	// Building authorization field, for basic http auth
	NSString *format = [NSString stringWithFormat:@"%@:%@", [preferences stringForKey:@"mal_username"], 
						[preferences stringForKey:@"mal_password"]];
	
	// Making request
	NSString * url = [[preferences stringForKey:@"mal_api_address"] stringByAppendingString:resource];
	NSMutableURLRequest *req =	[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[req setHTTPMethod:@"POST"];
	[req setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[req setValue:[NSString stringWithFormat:@"Basic %@", [format base64Encoding]]
				forHTTPHeaderField:@"Authorization"];
	[req setHTTPBody:data]; //data to post
	
	// Sending Synch Request: this method will only be used in secondary thread to not block the UI (using NSOperation)
	NSData * _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
//	[req release];
//	[resp release];
//	[error release];
	return _r;
}

@end
