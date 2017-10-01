//
//  StatusUpdateWindow.h
//  Hachidori
//
//  Created by 桐間紗路 on 2017/06/12.
//  Copyright 2009-2018 Atelier Shiori and James Moy All rights reserved. Code licensed under New BSD License
//

#import <Cocoa/Cocoa.h>
@class Hachidori;
@interface StatusUpdateWindow : NSWindowController
@property (strong) IBOutlet NSTextField *showtitle;
@property (strong) IBOutlet NSPopUpButton *showstatus;
@property (strong) IBOutlet NSPopUpButton *showscore;
@property (strong) IBOutlet NSTextField *episodefield;
@property (strong) IBOutlet NSNumberFormatter *epiformatter;
@property (strong) IBOutlet NSTextView * notes;
@property (strong) IBOutlet NSButton * isPrivate;
@property (strong) IBOutlet NSMenu *simpleratingmenu;
@property (strong) IBOutlet NSMenu *standardratingmenu;
@property (strong) IBOutlet NSMenu *advancedratingmenu;
@property (nonatomic, copy) void (^completion)(int returncode);
- (void)showUpdateDialog:(NSWindow *) w withHachidori:(Hachidori *)haengine;
@end
