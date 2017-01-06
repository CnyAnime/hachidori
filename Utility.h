//
//  Utility.h
//  Hachidori
//
//  Created by Tail Red on 1/31/15.
//
//

#import <Foundation/Foundation.h>
#import <OgreKit/OgreKit.h>
#import "string_score.h"
#import "AppDelegate.h"

@interface Utility : NSObject
+(int)checkMatch:(NSString *)title
         alttitle:(NSString *)atitle
            regex:(OGRegularExpression *)regex
           option:(int)i;
+(NSString *)desensitizeSeason:(NSString *)title;
+(void)showsheetmessage:(NSString *)message
           explaination:(NSString *)explaination
                 window:(NSWindow *)w;
+(NSString *)urlEncodeString:(NSString *)string;
+(void)donateCheck:(AppDelegate*)delegate;
+(void)showDonateReminder:(AppDelegate*)delegate;
+(void)setReminderDate;
+(int)checkDonationKey:(NSString *)key name:(NSString *)name;
@end
