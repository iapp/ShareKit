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


-(void)startRequestWithLogin:(NSString *)login password:(NSString *)password {
	
	
	if (!quiet) {
		[[SHKActivityIndicator currentIndicator] displayActivity:@"Aktualizacja Blipa"];
	}
		
	NSString *whatToShare;
	
	if (item.URL != nil) {
		
		NSURL *url = item.URL;
		
		whatToShare = [url relativeString];
		//NSLog(whatToShare);
		
	}
	
	if (item.text != nil) {
		
		whatToShare = item.text;
		
	}
	
	
	NSString *authHeader = [NSString stringWithFormat:@"%@:%@", login, password];
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
	
	[self sendDidStart];
	
	
	
}


- (BOOL)send {
	

	if ([self validateItem]) {
		
		
		[self startRequestWithLogin:[self getAuthValueForKey:@"user"] password:[self getAuthValueForKey:@"pass"]];		
		
	}
	
	
}



- (void)authorizationFormValidate:(SHKFormController *)form {
	
	
	if (!quiet) {
		[[SHKActivityIndicator currentIndicator] displayActivity:@"Aktualizacja Blipa"];
	}
	
	NSDictionary *formValues = [form formValues];

	[self startRequestWithLogin:[formValues valueForKey:@"user"] password:[formValues valueForKey:@"pass"]];
	
	
	
	
	
	
}

-(void)sendFinished:(SHKRequest *)request {
	
	NSLog([request getResult]);
	
	[[SHKActivityIndicator currentIndicator] hide];
	
	if (self.request.success) {
		
		
		[self sendDidFinish];		
		
	}
	
	else {
		
		NSString *msg;
		
		if ([[request getResult] isEqualToString:@"401 Unauthorized"]) {
			
			msg = [NSString stringWithString:@"Błędne dane logowania!"];
			
		}
		
		else {
			
			msg = [NSString stringWithString:@"Próba połączenia z serwisem blip.pl nieudana."];
			
		}

		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Błąd" 
								   message:msg
								  delegate:nil 
						 cancelButtonTitle:@"OK" 
						 otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}

	

	[self dismissModalViewControllerAnimated:YES];
	
	
}




@end
