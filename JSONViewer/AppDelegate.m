//
//  AppDelegate.m
//  JSONViewer
//
//  Created by Waldir Bertazzi Junior on 12/17/13.
//  Copyright (c) 2013 Waldir Bertazzi Junior. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

// Instantiation of json array.
-(NSMutableArray*)jsonData
{
    if (_jsonData == nil) _jsonData = [[NSMutableArray alloc]init];
    return _jsonData;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.jsonArea setString:@"Paste your JSON here..."];
    [self.statusText setStringValue:@""];
}


// Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.jsonData.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[self.jsonData objectAtIndex:row] objectAtIndex:1];
}


// Actions
- (IBAction)clearJsonAreaButtonClicked:(id)sender
{
    [self.jsonArea setString:@"Paste your JSON here..."];
}

- (IBAction)parseJsonButtonClicked:(id)sender
{
    NSError *jsonParsingError = nil;
    NSData  *jsonString = [[self.jsonArea string] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonStructure = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:&jsonParsingError];
    
    NSDictionary *structure;
    
    // Is this the right way to "try-catch" on objective-c?
    if (jsonParsingError != nil){
        // Show error alert
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"There is an error in your JSON"];
        [alert setInformativeText:[[jsonParsingError userInfo] objectForKey:@"NSDebugDescription"]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        [alert runModal];
        
        return;
        
    } else {
        printf("%s - %lu", [[self.jsonArea string] UTF8String], (unsigned long)[jsonStructure count]);
        printf("\n");
        
        // Parses JSON object
        for(int i=0; i < [jsonStructure count];i++) {
            structure = [jsonStructure objectAtIndex:i];
            [self.jsonData addObject:[structure objectForKey:@"test"]];
        }
        
        [self.tableView reloadData];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[NSApplication sharedApplication] stopModal];
}

@end
