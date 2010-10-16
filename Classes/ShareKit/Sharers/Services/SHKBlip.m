//
//  SHKBlip.m
//  ShareKit
//
//  Created by Tuszy on 10/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SHKBlip.h"
#import "NSData+Base64.h"


@implementation SHKBlip


#pragma mark Configuration

+ (NSString *)sharerTitle
{
	return @"Blip.pl";
}


// What types of content can the action handle?

// If the action can handle URLs, uncomment this section

 + (BOOL)canShareURL
 {
 return YES;
 }
 

// If the action can handle images, uncomment this section
/*
 + (BOOL)canShareImage
 {
 return YES;
 }
 */

// If the action can handle text, uncomment this section

 + (BOOL)canShareText
 {
 return YES;
 }
 

// If the action can handle files, uncomment this section
/*
 + (BOOL)canShareFile
 {
 return YES;
 }
 */


// Does the service require a login?  If for some reason it does NOT, uncomment this section:
/*
 + (BOOL)requiresAuthentication
 {
 return NO;
 }
 */

+ (BOOL)canShare
{
	return YES;
}


#pragma mark Authorization

+ (NSArray *)authorizationFormFields
{
	// See http://getsharekit.com/docs/#forms for documentation on creating forms
	
	// This example form shows a username and password and stores them by the keys 'username' and 'password'.

	return [NSArray arrayWithObjects:
			[SHKFormFieldSettings label:@"Login" key:@"user" type:SHKFormFieldTypeText start:nil],
			[SHKFormFieldSettings label:@"Hasło" key:@"pass" type:SHKFormFieldTypePassword start:nil],			
			nil];
} 


+ (NSString *)authorizationFormCaption {
	

	
	
	return SHKLocalizedString(@"Załóż darmowe konto @ %@", @"www.blip.pl");

	
}




- (void)authorizationFormValidate:(SHKFormController *)form {
	
	
	if (!quiet) {
		[[SHKActivityIndicator currentIndicator] displayActivity:@"Aktualizacja Blipa"];
	}
	
	NSDictionary *formValues = [form formValues];

	//NSLog([item customValueForKey:@"username"]);
	//NSLog([pendingForm valueForKey:@"username"]);
	
	NSString *whatToShare;
	
	if (item.URL != nil) {
		
		NSLog(@"url not nil");
		NSURL *url = item.URL;
		
		whatToShare = [url relativeString];
		//NSLog(whatToShare);
		
	}
	
	if (item.text != nil) {
		
		whatToShare = item.text;
		
	}
	
	
	NSString *authHeader = [NSString stringWithFormat:@"%@:%@", [formValues valueForKey:@"user"], [formValues valueForKey:@"pass"]];
	NSData *authData = [authHeader dataUsingEncoding:NSUTF8StringEncoding];
	NSString *base64EncodedString = [authData base64EncodedString];
	NSURL *url = [NSURL URLWithString:@"http://api.blip.pl/updates"];
	self.request = [[[SHKRequest alloc] initWithURL:url 
											 params:[NSString stringWithFormat:@"update[body]=%@", whatToShare]										   delegate:self 
								 isFinishedSelector:@selector(sendFinished:) 
											 method:@"POST" 
										  autostart:NO] autorelease];
		
	
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"0.02", @"X-Blip-API", @"ShareKit iPhone", @"User-Agent", [NSString stringWithFormat:@"Basic %@", base64EncodedString], @"Authorization",
							 @"application/json", @"Accept", nil];
	
	[request setHeaderFields:headers];
	
	[request start];
	
	
	
	
	
	
	
}

-(void)sendFinished:(SHKRequest *)request {
	
	[[SHKActivityIndicator currentIndicator] hide];
	
	if (self.request.success) {
		
		[pendingForm saveForm];
		
		
	}
	
	else {
		
		if (self.request.success) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Błąd" 
															message:@"Status zaktualizowany pomyślnie!" 
														   delegate:nil 
												  cancelButtonTitle:@"OK" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
			
			
		}
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Błąd" 
								   message:@"Nastąpił błąd z połączeniem do serwisu blip.pl." 
								  delegate:nil 
						 cancelButtonTitle:@"OK" 
						 otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}

	

	//NSLog([request getResult]);
	
	
}




@end
