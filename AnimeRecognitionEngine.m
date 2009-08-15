//
//  AnimeRecognitionEngine.m
//  iMAL
//
//  Created by Stefano Pigozzi on 8/15/09.
//  Copyright 2009 Stefano Pigozzi. All rights reserved.
//

#import "AnimeRecognitionEngine.h"


@implementation AnimeRecognitionEngine

-(void)awakeFromNib
{
	[mph addObserver:self forKeyPath:@"playingPath" options:(NSKeyValueObservingOptionNew |
															   NSKeyValueObservingOptionOld) context:NULL];
}

- (NSString *) sanitize: (NSString *) string
{
	NSString * _sanitized_name;
	
	_sanitized_name = [string stringByMatching:@"(\\.mkv$|\\.avi$)" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\[.+?\\]" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\(.+?\\)" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"[\\_|\\-|\\.]" replace:50 withReferenceString:@" "];
	_sanitized_name = [_sanitized_name stringByMatching:@"\\s\\s+" replace:50 withReferenceString:@" "];
	_sanitized_name = [_sanitized_name stringByMatching:@"^\\s" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"v\\d+" replace:50 withReferenceString:@""];
	_sanitized_name = [_sanitized_name stringByMatching:@"(XviD|DivX|H264|H\\.264|h264|h\\.264|AVI|MP4|x264|x\\.264)" replace:50 withReferenceString:@""];
	
	return _sanitized_name;
} 

- (void) scrobble: (NSString *)path
{
	//NSString * _dir = ([path stringByMatching:@"(/.+/)" withReferenceFormat:@"$1"]);
	NSString * _f_name = ([path stringByMatching:@"/.+/(.+$)" withReferenceFormat:@"$1"]);
	NSLog(@"Detected file to scrobble: %@", [self sanitize:_f_name]);
	
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if(![[change valueForKey:NSKeyValueChangeOldKey] isEqual:[change valueForKey:NSKeyValueChangeNewKey]] && [change valueForKey:NSKeyValueChangeNewKey])
		[self scrobble:[change valueForKey:NSKeyValueChangeNewKey]];
}

@end
