//
//  Hachidori+Update.m
//  Hachidori
//
//  Created by 高町なのは on 2015/02/11.
//  Copyright 2009-2015 Atelier Shiori. All rights reserved. Code licensed under New BSD License
//

#import "Hachidori+Update.h"
#import "EasyNSURLConnection.h"

@implementation Hachidori (Update)
-(int)updatetitle:(NSString *)titleid {
    NSLog(@"Updating Title");
    if (LastScrobbledTitleNew && [[NSUserDefaults standardUserDefaults] boolForKey:@"ConfirmNewTitle"] && !confirmed && !correcting) {
        // Confirm before updating title
        LastScrobbledTitle = DetectedTitle;
        LastScrobbledEpisode = DetectedEpisode;
        LastScrobbledSource = DetectedSource;
        LastScrobbledActualTitle = [NSString stringWithFormat:@"%@",LastScrobbledInfo[@"title"]];
        return 3;
    }
    if ([DetectedEpisode intValue] <= DetectedCurrentEpisode ) {
        // Already Watched, no need to scrobble
        // Store Scrobbled Title and Episode
        LastScrobbledTitle = DetectedTitle;
        LastScrobbledEpisode = DetectedEpisode;
        LastScrobbledSource = DetectedSource;
        LastScrobbledActualTitle = [NSString stringWithFormat:@"%@",LastScrobbledInfo[@"title"]];
        confirmed = true;
        return 2;
    }
    else if (!LastScrobbledTitleNew && [[NSUserDefaults standardUserDefaults] boolForKey:@"ConfirmUpdates"] && !confirmed && !correcting) {
        // Confirm before updating title
        LastScrobbledTitle = DetectedTitle;
        LastScrobbledEpisode = DetectedEpisode;
        LastScrobbledSource = DetectedSource;
        LastScrobbledActualTitle = [NSString stringWithFormat:@"%@",LastScrobbledInfo[@"title"]];
        return 3;
    }
    else {
        return [self performupdate:titleid];
    }
}
-(int)performupdate:(NSString *)titleid{
    // Update the title
    //Set library/scrobble API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://hummingbird.me/api/v1/libraries/%@", titleid]];
    EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
    //Ignore Cookies
    [request setUseCookies:NO];
    //Set Token
    [request addFormData:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Token"]] forKey:@"auth_token"];
    //Set Timeout
    //[request setRequestMethod:@"PUT"];
    [request addFormData:DetectedEpisode forKey:@"episodes_watched"];
    //Set Status
    if([DetectedEpisode intValue] == TotalEpisodes) {
        //Set Title State
        WatchStatus = @"completed";
        // Since Detected Episode = Total Episode, set the status as "Complete"
        [request addFormData:WatchStatus forKey:@"status"];
    }
    else {
        //Set Title State to currently watching
        WatchStatus = @"currently-watching";
        // Still Watching
        [request addFormData:WatchStatus forKey:@"status"];
    }
    // Set existing score to prevent the score from being erased.
    [request addFormData:[NSNumber numberWithFloat:TitleScore] forKey:@"rating"];
    //Privacy
    if (isPrivate)
        [request addFormData:@"private" forKey:@"privacy"];
    else
        [request addFormData:@"public" forKey:@"privacy"];
    // Do Update
    [request startFormRequest];
    // Set correcting status to off
    correcting = false;
    switch ([request getStatusCode]) {
        case 201:
            // Store Scrobbled Title and Episode
            LastScrobbledTitle = DetectedTitle;
            LastScrobbledEpisode = DetectedEpisode;
            DetectedCurrentEpisode = [LastScrobbledEpisode intValue];
            LastScrobbledSource = DetectedSource;
            if (confirmed) { // Will only store actual title if confirmation feature is not turned on
                // Store Actual Title
                LastScrobbledActualTitle = [NSString stringWithFormat:@"%@",LastScrobbledInfo[@"title"]];
            }
            confirmed = true;
            if (LastScrobbledTitleNew) {
                return 21;
            }
            // Update Successful
            return 22;
        default:
            // Update Unsuccessful
            if (LastScrobbledTitleNew) {
                return 52;
            }
            return 53;
    }
    
}
-(BOOL)updatestatus:(NSString *)titleid
            episode:(NSString *)episode
              score:(float)showscore
        watchstatus:(NSString*)showwatchstatus
              notes:(NSString*)note
          isPrivate:(BOOL)privatevalue
{
    NSLog(@"Updating Status for %@", titleid);
    // Update the title
    //Set library/scrobble API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://hummingbird.me/api/v1/libraries/%@",  titleid]];
    EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
    //Ignore Cookies
    [request setUseCookies:NO];
    //Set Token
    [request addFormData:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Token"]] forKey:@"auth_token"];
    //Set current episode
    if ([episode intValue] != DetectedCurrentEpisode) {
        [request addFormData:episode forKey:@"episodes_watched"];
    }
    //Set new watch status
    [request addFormData:showwatchstatus forKey:@"status"];
    //Set new score.
    [request addFormData:[NSString stringWithFormat:@"%f", showscore] forKey:@"rating"];
    //Set new note
    [request addFormData:note forKey:@"notes"];
    //Privacy
    if (privatevalue)
        [request addFormData:@"private" forKey:@"privacy"];
    else
        [request addFormData:@"public" forKey:@"privacy"];
    // Do Update
    [request startFormRequest];
    switch ([request getStatusCode]) {
        case 200:
        case 201:
            //Set New Values
            TitleScore = showscore;
            WatchStatus = showwatchstatus;
            TitleNotes = note;
            isPrivate = privatevalue;
            LastScrobbledEpisode = episode;
            DetectedCurrentEpisode = [episode intValue];
            return true;
        default:
            // Update Unsuccessful
            return false;
            break;
    }
    return false;
}
-(bool)removetitle:(NSString *)titleid{
    NSLog(@"Removing %@", titleid);
    // Update the title
    //Set library/scrobble API
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://hummingbird.me/api/v1/libraries/%@/remove", titleid]];
    EasyNSURLConnection *request = [[EasyNSURLConnection alloc] initWithURL:url];
    //Ignore Cookies
    [request setUseCookies:NO];
    //Set Token
    [request addFormData:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Token"]] forKey:@"auth_token"];
    // Do Update
    [request startFormRequest];
    switch ([request getStatusCode]) {
        case 200:
        case 201:
            return true;
        default:
            // Update Unsuccessful
            return false;
    }
    return false;
}
@end