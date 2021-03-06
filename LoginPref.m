//
//  LoginPref.m
//  Hachidori
//
//  Created by Nanoha Takamachi on 2014/10/18.
//  Copyright 2014 MAL Updater OS X Group and James Moy All rights reserved. Code licensed under New BSD License
//

#import "LoginPref.h"
#import "AniListAuthWindow.h"
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import <AFNetworking/AFOAuth2Manager.h>
#import "ClientConstants.h"
#import "AppDelegate.h"
#import "Hachidori.h"

@implementation LoginPref

- (instancetype)init
{
    return [super initWithNibName:@"LoginView" bundle:nil];
}
- (id)initwithAppDelegate:(AppDelegate *)adelegate{
    
    _appdelegate = adelegate;
    _haengine = _appdelegate.haengine;
    return [super initWithNibName:@"LoginView" bundle:nil];
    
}
- (void)loadView{
    [super loadView];
    // Set Logo
    _logo.image = NSApp.applicationIconImage;
    // Load Login State
    [self loadlogin];
}

- (Hachidori *)hachidori {
    return _appdelegate.haengine;
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

- (void)loadlogin
{
    // Load Username
    if ([Hachidori getFirstAccount:0]) {
        [_clearbut setEnabled: YES];
        [_savebut setEnabled: NO];
        [_loggedinview setHidden:NO];
        [_loginview setHidden:YES];
        _loggedinuser.stringValue = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"loggedinusername"]];
    }
    else {
        //Disable Clearbut
        [_clearbut setEnabled: NO];
        [_savebut setEnabled: YES];
    }
    // Anilist
    if ([Hachidori getFirstAccount:1]) {
        [_anilistclearbut setEnabled: YES];
        [_anilistauthorizebtn setEnabled: NO];
        [_anilistloggedinview setHidden:NO];
        [_anilistloginview setHidden:YES];
        _anilistloggedinuser.stringValue = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"loggedinusername-anilist"]];
    }
    else {
        //Disable Clearbut
        [_anilistclearbut setEnabled: NO];
        [_anilistauthorizebtn setEnabled: YES];
    }
}
- (IBAction)startlogin:(id)sender
{
    {
        //Start Login Process
        //Disable Login Button
        [_savebut setEnabled: NO];
        [_savebut displayIfNeeded];
        if (_fieldusername.stringValue.length == 0) {
            //No Username Entered! Show error message
            [Utility showsheetmessage:@"Hachidori was unable to log you in since you didn't enter a username" explaination:@"Enter a valid username and try logging in again" window:self.view.window];
            [_savebut setEnabled: YES];
        }
        else {
            if (_fieldpassword.stringValue.length == 0 ) {
                //No Password Entered! Show error message.
                [Utility showsheetmessage:@"Hachidori was unable to log you in since you didn't enter a password" explaination:@"Enter a valid password and try logging in again." window:self.view.window];
                [_savebut setEnabled: YES];
            }
            else {
                    [self login:_fieldusername.stringValue password:_fieldpassword.stringValue];
                }
        }
           }
}
- (IBAction)authorize:(id)sender {
    if (!_anilistauthw) {
        _anilistauthw = [AniListAuthWindow new];
    }
    else {
        [_anilistauthw.window makeKeyAndOrderFront:self];
        [_anilistauthw loadAuthorization];
        [_anilistauthw close];
    }
    _anilistauthorizebtn.enabled = NO;
    [self.view.window beginSheet:_anilistauthw.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            NSString *pin = _anilistauthw.pin.copy;
            _anilistauthw.pin = nil;
            [self authorizeWithPin:pin withService:1];
        }
        else {
            _anilistauthorizebtn.enabled = YES;
        }
    }];
}
- (void)login:(NSString *)username password:(NSString *)password{
    NSURL *baseURL = [NSURL URLWithString:kBaseURL];
    AFOAuth2Manager *OAuth2Manager =
    [[AFOAuth2Manager alloc] initWithBaseURL:baseURL
                                    clientID:kclient
                                      secret:ksecretkey];
        [OAuth2Manager authenticateUsingOAuthWithURLString:kTokenURL parameters:@{@"grant_type":@"password", @"username":username, @"password":password} success:^(AFOAuthCredential *credential) {
        // Update your UI
        [Utility showsheetmessage:@"Login Successful" explaination: @"Your account has been authenticated." window:self.view.window];
            [self showServiceMenuReminder:0];
        [AFOAuthCredential storeCredential:credential
                                withIdentifier:@"Hachidori"];
            [_haengine retrieveUserID:^(int userid, NSString *username, NSString *scoreformat) {
                [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"loggedinusername"];
                [[NSUserDefaults standardUserDefaults] setValue:@(userid) forKey:@"UserID"];
                [_clearbut setEnabled: YES];
                _loggedinuser.stringValue = username;
                [_loggedinview setHidden:NO];
                [_loginview setHidden:YES];
                _fieldusername.stringValue = @"";
                _fieldpassword.stringValue = @"";
            } error:^(NSError *error) {
                NSLog(@"Error: %@", error);
                // Do something with the error
                //Login Failed, show error message
                [Utility showsheetmessage:@"Hachidori was unable to log you in since it can't retrieve user metadata." explaination:@"Please try again later." window:self.view.window];
                NSLog(@"%@",error);
                [_savebut setEnabled: YES];
                _savebut.keyEquivalent = @"\r";
                [_loggedinview setHidden:YES];
                [_loginview setHidden:NO];
                [AFOAuthCredential deleteCredentialWithIdentifier:@"Hachidori"];
            } withService:0];

    }
    failure:^(NSError *error) {
                                                   NSLog(@"Error: %@", error);
                                                   // Do something with the error
                                                   //Login Failed, show error message
                                                   [Utility showsheetmessage:@"Hachidori was unable to log you in since you don't have the correct username and/or password." explaination:@"Check your username and password and try logging in again. If you recently changed your password, enter your new password and try again." window:self.view.window];
                                                   NSLog(@"%@",error);
                                                   [_savebut setEnabled: YES];
                                                   _savebut.keyEquivalent = @"\r";
                                                   [_loggedinview setHidden:YES];
                                                   [_loginview setHidden:NO];
                                               }];
}
- (void)authorizeWithPin:(NSString *)pin withService: (int)service {
    AFOAuth2Manager *OAuth2Manager =
    [[AFOAuth2Manager alloc] initWithBaseURL:[NSURL URLWithString:@"https://anilist.co/"]
                                    clientID:kanilistclient
                                      secret:kanilistsecretkey];
    [OAuth2Manager authenticateUsingOAuthWithURLString:@"api/v2/oauth/token" parameters:@{@"grant_type":@"authorization_code", @"code" : pin, @"redirect_uri" : @"hachidoriauth://anilistauth/"} success:^(AFOAuthCredential *credential) {
        // Update your UI
        [Utility showsheetmessage:@"Login Successful" explaination: @"Your account has been authenticated." window:self.view.window];
        [self showServiceMenuReminder:1];
        [AFOAuthCredential storeCredential:credential
                            withIdentifier:@"Hachidori - AniList"];
        [_haengine retrieveUserID:^(int userid, NSString *username, NSString *scoreformat) {
            [[NSUserDefaults standardUserDefaults] setValue:@(userid) forKey:@"UserID-anilist"];
            [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"loggedinusername-anilist"];
            [_anilistauthorizebtn setEnabled: YES];
            [_anilistclearbut setEnabled: YES];
            _anilistloggedinuser.stringValue = username;
            [_anilistloggedinview setHidden:NO];
            [_anilistloginview setHidden:YES];
        } error:^(NSError *error) {
            NSLog(@"Error: %@", error);
            // Do something with the error
            //Login Failed, show error message
            [Utility showsheetmessage:@"Hachidori was unable to authorize your account." explaination:@"Please try again later." window:self.view.window];
            NSLog(@"%@",error);
            [_anilistauthorizebtn setEnabled: YES];
            _anilistauthorizebtn.keyEquivalent = @"\r";
            [_anilistloggedinview setHidden:YES];
            [_anilistloginview setHidden:NO];
        } withService:1];

    }
                                               failure:^(NSError *error) {
                                                   NSLog(@"Error: %@", error);
                                                   // Do something with the error
                                                   //Login Failed, show error message
                                                   [Utility showsheetmessage:@"Hachidori was unable to log you in since it can't retrieve user metadata." explaination:@"Please try again later." window:self.view.window];
                                                   NSLog(@"%@",error);
                                                   NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                                   NSLog(@"%@",errResponse);
                                                   [_anilistauthorizebtn setEnabled: YES];
                                                   _anilistauthorizebtn.keyEquivalent = @"\r";
                                                   [_anilistloggedinview setHidden:YES];
                                                   [_anilistloginview setHidden:NO];
                                                   [AFOAuthCredential deleteCredentialWithIdentifier:@"Hachidori - AniList"];
                                               }];
}

- (IBAction)registerhummingbird:(id)sender
{
    //Show Kitsu Registration Page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://kitsu.io"]];
}

- (IBAction)registerAnilist:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://anilist.co/register"]];
}

- (IBAction) showgettingstartedpage:(id)sender
{
    //Show Getting Started help page
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/chikorita157/hachidori/wiki/Getting-Started"]];
}

- (IBAction)clearlogin:(id)sender
{
    long service = ((NSButton *)sender).tag;
    if (!_appdelegate.scrobbling && !_appdelegate.scrobbleractive) {
        // Set Up Prompt Message Window
        NSAlert * alert = [[NSAlert alloc] init] ;
        [alert addButtonWithTitle:NSLocalizedString(@"Yes",nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"No",nil)];
        [alert setMessageText:NSLocalizedString(@"Do you want to remove this account?",nil)];
        [alert setInformativeText:NSLocalizedString(@"Once you remove this account, you need to reauthorize your account before you can use this application.",nil)];
        // Set Message type to Warning
        alert.alertStyle = NSWarningAlertStyle;
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode== NSAlertFirstButtonReturn) {
                switch (service) {
                    case 0: {
                        // Remove Oauth Account
                        [AFOAuthCredential deleteCredentialWithIdentifier:@"Hachidori"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"loggedinusername"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"UserID"];
                        //Disable Clearbut
                        [_clearbut setEnabled: NO];
                        [_savebut setEnabled: YES];
                        _loggedinuser.stringValue = @"";
                        [_loggedinview setHidden:YES];
                        [_loginview setHidden:NO];
                        break;
                    }
                    case 1: {
                        // Remove Oauth Account
                        [AFOAuthCredential deleteCredentialWithIdentifier:@"Hachidori - AniList"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"loggedinusername-anilist"];
                        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"UserID-anilist"];
                        //Disable Clearbut
                        [_anilistclearbut setEnabled: NO];
                        [_anilistauthorizebtn setEnabled: YES];
                        _anilistloggedinuser.stringValue = @"";
                        [_anilistloggedinview setHidden:YES];
                        [_anilistloginview setHidden:NO];
                        break;
                    }
                }
                if (service == [Hachidori currentService]) {
                    // Only reset UI if the service id of the account being removed is the same as the current account
                    [NSNotificationCenter.defaultCenter postNotificationName:@"AccountLoggedOut" object:@(service)];
                    [_appdelegate resetUI];
                }
            }
        }];
    }
    else {
        [Utility showsheetmessage:@"Cannot Remove Account" explaination:@"Please turn off automatic scrobbling before removing this account." window:self.view.window];
    }
}

- (NSString *)getUsername{
    return [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"loggedinusername"]];
}

- (void)showServiceMenuReminder:(int)service {
    NSAlert *alert = [NSAlert new];
    NSString *servicename = @"";
    switch (service) {
        case 0:
            servicename = @"Kitsu";
            break;
        case 1:
            servicename = @"AniList";
            break;
        default:
            break;
    }
    alert.messageText = [NSString stringWithFormat:@"To use %@, you can select it from the Service menu", servicename];
    alert.informativeText = @"The service menu allows you to switch between services you wish to automatically update your list with.\n\nThis menu can be accessed by clicking the Hachidori icon on the menubar and moving your mouse pointer to Services sub menu and selecting the desired service to switch to.";
    alert.showsSuppressionButton = true;
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    if (![defaults boolForKey:@"showServiceMenuReminder"]) {
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (alert.suppressionButton.state == 1) {
                [defaults setBool:true forKey:@"showServiceMenuReminder"];
            }
        }];
    }
}
@end
