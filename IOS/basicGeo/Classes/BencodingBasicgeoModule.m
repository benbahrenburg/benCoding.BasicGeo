/**
 * benCoding.basicGeo Project
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

static NSString* _reason = nil;

@implementation BencodingBasicgeoModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"ad4ef595-ff80-429e-81c8-4f7df12ee958";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"bencoding.basicgeo";
}

+(NSString *) reason
{
    return _reason;
}

-(NSString*)purpose
{
	return _reason;
}

-(void)setPurpose:(NSString *)reason
{
	ENSURE_UI_THREAD(setPurpose,reason);
	_reason = reason;    
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];	
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 


#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

@end
