//
//  FixSearchDialog.h
//  Hachidori
//
//  Created by 高町なのは on 2014/11/15.
//  Copyright (c) 2014年 Atelier Shiori. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>

@interface FixSearchDialog : NSWindowController{
    IBOutlet NSArrayController * arraycontroller;
    IBOutlet NSTextField *search;
    IBOutlet NSButton * deleteoncorrection;
    IBOutlet NSTableView *tb;
    NSString * selectedtitle;
    bool correction;
}
-(id)init;
-(void)setCorrection:(BOOL)correct;
-(NSString *)getSelectedTitle;
-(bool)getdeleteTitleonCorrection;
@end
