//
//  SHKBlip.h
//  ShareKit
//
//  Created by Michał Tuszyński on 10/14/10.
//  Copyright 2010 iapp.pl. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to towhom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
			[SHKFormFieldSettings label:SHKLocalizedString(@"Username") key:@"user" type:SHKFormFieldTypeText start:nil],
			[SHKFormFieldSettings label:SHKLocalizedString(@"Password") key:@"pass" type:SHKFormFieldTypePassword start:nil],			
			nil];
} 


+ (NSString *)authorizationFormCaption {
	
	
	
	
	return SHKLocalizedString(@"Create a free account at %@", @"www.blip.pl");
	
	
}


-(void)startRequestWithLogin:(NSString *)login password:(NSString *)password {
	
	
	if (!quiet) {
		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Update status")];
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
	
	
	NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:@"0.02", @"X-Blip-API", @"ShareKit", @"User-Agent", [NSString stringWithFormat:@"Basic %@", base64EncodedString], @"Authorization",
							 @"application/json", @"Accept", nil];
	
	[request setHeaderFields:headers];
	
	[request start];
	
	[self sendDidStart];
	
	
	
}


- (BOOL)send {
	
	
	if ([self validateItem]) {
		
		
		[self startRequestWithLogin:[self getAuthValueForKey:@"user"] password:[self getAuthValueForKey:@"pass"]];	
		
		return YES;
		
	}
	
	else {
		return NO;
	}

	
	
}



- (void)authorizationFormValidate:(SHKFormController *)form {
	
	
	if (!quiet) {
		
		[[SHKActivityIndicator currentIndicator] displayActivity:SHKLocalizedString(@"Updating status")];
	}
	
	NSDictionary *formValues = [form formValues];
	
	[self startRequestWithLogin:[formValues valueForKey:@"user"] password:[formValues valueForKey:@"pass"]];
	
	
	
	
	
	
}

-(void)sendFinished:(SHKRequest *)request {
	
	//NSLog([self.request getResult]);
	
	[[SHKActivityIndicator currentIndicator] hide];
	
	if (self.request.success) {
		
		
		[self sendDidFinish];		
		
	}
	
	else {
		
		NSString *msg;
		
		if ([[self.request getResult] isEqualToString:@"401 Unauthorized"]) {
			
			msg = [NSString stringWithString:SHKLocalizedString(@"Incorrect username and password")];
			
		}
		
		else {
			
			msg = [NSString stringWithString:SHKLocalizedString(@"Unable to connect to blip.pl. Try again later.")];
			
		}
		
		
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:SHKLocalizedString(@"Error") 
														message:msg
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	
	
	
}




@end