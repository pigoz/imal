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
@synthesize dl_queue;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.queue = [NSOperationQueue new];
		[self.queue setMaxConcurrentOperationCount:2];
		
		self.dl_queue = [NSOperationQueue new];
		[self.dl_queue setMaxConcurrentOperationCount:2];
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

- (NSData *) getList:(NSString *)type
{
	NSURLResponse* resp;
	NSError* error;
	
	NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
	
	// Making request
	NSString * url = [NSString stringWithFormat:@"http://myanimelist.net/malappinfo.php?u=%@&status=all&type=%@", 
					  [preferences stringForKey:@"mal_username"], type];
	NSMutableURLRequest *req =	[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	[req setHTTPMethod:@"GET"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	// Sending Synch Request: this method will only be used in secondary thread to not block the UI (using NSOperation)
	NSData* _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
	//	[req release];
	//	[resp release];
	//	[error release];
	return _r;
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
	[req setHTTPBody:data];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[req setValue:[NSString stringWithFormat:@"Basic %@", [format base64Encoding]] forHTTPHeaderField:@"Authorization"];
	
	// Sending Synch Request: this method will only be used in secondary thread to not block the UI (using NSOperation)
	NSData * _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
//	[req release];
//	[resp release];
//	[error release];
	return _r;
}


// Helper method: finds out if we have MAL cookies (only used to scrape HTML)
- (BOOL) isLoggedIn
{
	BOOL _yflag = NO;
	BOOL _zflag = NO;
	NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://myanimelist.net"]];
	for(NSHTTPCookie * cookie in cookies){
		if([[cookie name] isEqualToString:@"Y"])
			_yflag = YES;
		if([[cookie name] isEqualToString:@"Z"])
			_zflag = YES;
	}
	if(_yflag==YES && _zflag==YES){
		return YES;
	} else {
		return NO;
	}
}

- (void) login
{	
	NSURLResponse* resp;
	NSError* error;
	NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
	
	NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: @"http://myanimelist.net/login.php"]];
	
	NSString * data = [NSString stringWithFormat:@"username=%@&password=%@&cookie=true", 
					   [preferences stringForKey:@"mal_username"], [preferences stringForKey:@"mal_password"]];
	
	[req setHTTPMethod:@"POST"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[req setHTTPBody:[data dataUsingEncoding:NSASCIIStringEncoding]];
	
	[NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];	
}

// using html parsing because Xinil is a lazy motherfucker
-(void)increaseRewatchedValue:(int)my_id anime_id:(int)anime_id
{
	if(![self isLoggedIn]) [self login]; // let's login?
	
	NSURLResponse* resp;
	NSError* error;
	
	// scraping HTML page
	NSString * url = [NSString stringWithFormat:@"http://myanimelist.net/panel.php?go=edit&id=%d", my_id];
	NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:url]];
		
	[req setHTTPMethod:@"GET"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	NSData * _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
	NSString * _resp = [[NSString alloc] initWithData:_r encoding:NSUTF8StringEncoding];
	
	NSString * value = [_resp stringByMatching:@"<input type=\"text\" name=\"list_times_watched\" value=\"([0-9]+)\" size=\"4\" class=\"inputtext\">"
						   withReferenceFormat:@"$1"];
	
	NSString *new_value = [NSString stringWithFormat:@"%d",[value intValue]+1];
	
	// Building XML to post with normal API
	NSXMLElement *entry = (NSXMLElement *)[NSXMLNode elementWithName:@"entry"];
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithRootElement:entry];
	[xml setVersion:@"1.0"];
	[xml setCharacterEncoding:@"UTF-8"];
	[entry addChild:[NSXMLNode elementWithName:@"times_rewatched" stringValue:new_value]];
	NSData *xmldata = [xml XMLDataWithOptions:NSXMLDocumentTidyXML];
	NSLog(@"%@", [[[NSString alloc]initWithData:xmldata encoding:NSUTF8StringEncoding] autorelease]);
	
	// Send post request
	NSString * resource = [NSString stringWithFormat:@"/%@list/update/%d.xml", @"anime", anime_id];
	NSString * xmlstr = [[[NSString alloc] initWithData:xmldata encoding:NSUTF8StringEncoding] autorelease];
	xmldata = [[NSString stringWithFormat:@"data=%@", xmlstr] dataUsingEncoding:NSUTF8StringEncoding];
	[self post:resource data:xmldata];
	[xml release];
	
	[_resp release];
}

-(void)increaseRereadValue:(int)my_id manga_id:(int)manga_id
{
	if(![self isLoggedIn]) [self login]; // let's login?
	
	NSURLResponse* resp;
	NSError* error;
	
	// scraping HTML page
	NSString * url = [NSString stringWithFormat:@"http://myanimelist.net/panel.php?go=editmanga&id=%d", my_id];
	NSMutableURLRequest * req = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:url]];
	
	[req setHTTPMethod:@"GET"];
	[req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[req setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	NSData * _r = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&error];
	NSString * _resp = [[NSString alloc] initWithData:_r encoding:NSUTF8StringEncoding];
	
	NSString * value = [_resp stringByMatching:@"<input type=\"text\" class=\"inputtext\" size=\"4\" value=\"([0-9]+)\" name=\"times_read\"/>"
						   withReferenceFormat:@"$1"];
	
	NSString *new_value = [NSString stringWithFormat:@"%d",[value intValue]+1];
	
	// Building XML to post with normal API
	NSXMLElement *entry = (NSXMLElement *)[NSXMLNode elementWithName:@"entry"];
	NSXMLDocument *xml = [[NSXMLDocument alloc] initWithRootElement:entry];
	[xml setVersion:@"1.0"];
	[xml setCharacterEncoding:@"UTF-8"];
	[entry addChild:[NSXMLNode elementWithName:@"times_reread" stringValue:new_value]];
	NSData *xmldata = [xml XMLDataWithOptions:NSXMLDocumentTidyXML];
	NSLog(@"%@", [[[NSString alloc]initWithData:xmldata encoding:NSUTF8StringEncoding] autorelease]);
	
	// Send post request
	NSString * resource = [NSString stringWithFormat:@"/%@list/update/%d.xml", @"manga", manga_id];
	NSString * xmlstr = [[[NSString alloc] initWithData:xmldata encoding:NSUTF8StringEncoding] autorelease];
	xmldata = [[NSString stringWithFormat:@"data=%@", xmlstr] dataUsingEncoding:NSUTF8StringEncoding];
	[self post:resource data:xmldata];
	[xml release];
	
	[_resp release];
}

@end
