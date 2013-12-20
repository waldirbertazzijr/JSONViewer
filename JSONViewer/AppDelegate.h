//
//  AppDelegate.h
//  JSONViewer
//
//  Created by Waldir Bertazzi Junior on 12/17/13.
//  Copyright (c) 2013 Waldir Bertazzi Junior. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// JSON Data
@property (strong, nonatomic) NSArray *jsonData;

// Other
@property (assign) IBOutlet NSWindow *window;
@property IBOutlet NSTextField *jsonArea;

// Table
@property(weak) IBOutlet NSOutlineView *tableView;
@property(weak) IBOutlet NSTableColumn *jsonObjectName;
@property(weak) IBOutlet NSTableColumn *jsonObjectType;
@property(weak) IBOutlet NSTableColumn *jsonObjectLength;

// buttons
@property(weak) IBOutlet NSButton *clearJsonArea;
@property(weak) IBOutlet NSButton *parseJsonArea;

// actions
- (IBAction)clearJsonAreaButtonClicked:(NSButton *)sender;

// Methods
- (void)parseJSONTree:(NSArray *)jsonArray identLevel:(NSInteger)integer;
@end
