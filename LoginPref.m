//
//  LoginPref.m
//  Hachidori
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 Atelier Shiori. All rights reserved.
//

#import "LoginPref.h"


@implementation LoginPref

- (id)init
{
	return [super initWithNibName:@"LoginView" bundle:nil];
}
-(void)loadView{
    [super loadView];
	[self loadlogin];
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"LoginPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameUser];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"Login", @"Toolbar item name for the Login preference pane");
}

-(void)showsheetmessage:(NSString *)message
		   explaination:(NSString *)explaination
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:message];
	[alert setInformativeText:explaination];
	// Set Message type to Warning
	[alert setAlertStyle:1];
	// Show as Sheet on Preference Window
	[alert runModal];
	/*[alert beginSheetModalForWindow:[self window]
					  modalDelegate:self
					 didEndSelector:nil
						contextInfo:NULL];*/
}
-(void)loadlogin
{
	// Load Username
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *Token = [defaults objectForKey:@"Token"];
	if (Token.length > 0) {
		[clearbut setEnabled: YES];
		[savebut setEnabled: NO];
	}
	else {
		//Disable Clearbut
		[clearbut setEnabled: NO];
		[savebut setEnabled: YES];
	}
}
-(IBAction)startlogin:(id)sender
{
	{
		//Start Login Process
		//Disable Login Button
		[savebut setEnabled: NO];
		[savebut displayIfNeeded];
		if ( [[fieldusername stringValue] length] == 0) {
			//No Username Entered! Show error message
			[self showsheetmessage:@"Hachidori was unable to log you in since you didn't enter a username" explaination:@"Enter a valid username and try logging in again"];
			[savebut setEnabled: YES];
		}
		else {
			if ( [[fieldpassword stringValue] length] == 0 ) {
				//No Password Entered! Show error message.
				[self showsheetmessage:@"Hachidori was unable to log you in since you didn't enter a password" explaination:@"Enter a valid password and try logging in again."];
				[savebut setEnabled: YES];
			}
			else {
				//Set Login URL
				NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://hbrd-v1.p.mashape.com/users/authenticate"]];
                NSLog(@"%@", mashapekey);
				ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
                [request addRequestHeader:@"X-Mashape-Key" value:mashapekey];
				//Ignore Cookies
				[request setUseCookiePersistence:NO];
				//Set Username
                [request setPostValue:[fieldusername stringValue] forKey:@"username"];
                [request setPostValue:[fieldpassword stringValue] forKey:@"password"];
                [request setRequestMethod:@"POST"];
				//Vertify Username/Password
				[request startSynchronous];
				// Get Status Code
				int statusCode = [request responseStatusCode];
				switch (statusCode) {
					case 201:{
						//Login successful
						[self showsheetmessage:@"Login Successful" explaination: @"Login Token has been recieved."];
						// Generate API Key
						NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
						[defaults setObject:[[request responseString] stringByReplacingOccurrencesOfString:@"\"" withString:@""] forKey:@"Token"];
						[defaults setObject:[fieldusername stringValue] forKey:@"Username"];
						[clearbut setEnabled: YES];
						break;}
					case 401:{
						//Login Failed, show error message
						[self showsheetmessage:@"Hachidori was unable to log you in since you don't have the correct username and/or password." explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again."];
						[savebut setEnabled: YES];
						[savebut setKeyEquivalent:@"\r"];
						break;}
					default:{
						//Login Failed, show error message
						[self showsheetmessage:@"Hachidori was unable to log you in because of an unknown error." explaination:[NSString stringWithFormat:@"Error %i", statusCode]];
						[savebut setEnabled: YES];
						[savebut setKeyEquivalent:@"\r"];
						break;}
				}
				//release
				request = nil;
				url = nil;
			}
		}
	}
}
-(IBAction)registerhummingbird:(id)sender
{
	//Show MAL Registration Page
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://hummingbird.me/users/sign_up"]];
}
-(IBAction)clearlogin:(id)sender
{
	// Set Up Prompt Message Window
	NSAlert * alert = [[NSAlert alloc] init] ;
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert setMessageText:@"Do you want to log out?"];
	[alert setInformativeText:@"Once you logged out, you need to log back in before you can use this application."];
	// Set Message type to Warning
	[alert setAlertStyle:NSWarningAlertStyle];	
	if ([alert runModal]== NSAlertFirstButtonReturn) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:@"" forKey:@"Token"];
		// Clear Username
		[defaults setObject:@"" forKey:@"Username"];
		//Disable Clearbut
		[clearbut setEnabled: NO];
		[savebut setEnabled: YES];
	}
}

@end
