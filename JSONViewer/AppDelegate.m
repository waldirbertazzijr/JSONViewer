//
//  AppDelegate.m
//  JSONViewer
//
//  Created by Waldir Bertazzi Junior on 12/17/13.
//  Copyright (c) 2013 Waldir Bertazzi Junior. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

// Type of JSON elements
typedef enum JSONELement{
    JSON_NUMBER,
    JSON_ARRAY,
    JSON_OBJECT,
    JSON_STRING,
    JSON_BOOL
} JSONELement;


// JSON Data MutabeArray
-(NSArray*)jsonData

{
    if (_jsonData == nil) _jsonData = [[NSArray alloc]init];
    return _jsonData;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    for (NSTableColumn *tableColumn in self.tableView.tableColumns ) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES selector:@selector(compare:)];
        [tableColumn setSortDescriptorPrototype:sortDescriptor];
    }
    
    [self.jsonArea setStringValue:@"[true, true, false, 10.401, {\"a\":10, \"b\": 20, \"c\": [10, 20, 30, 40, {\"t\": 10}], \"z\": {\"y\": [10, 200]}}]"];
}


// Table View
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    JSONELement dataType = [self getDataStructureCode: NSStringFromClass([item class])];
    
    if (dataType == JSON_ARRAY || dataType == JSON_OBJECT) return YES;
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    JSONELement dataType = [self getDataStructureCode: NSStringFromClass([item class])];

    if (item == nil) { //item is nil when the outline view wants to inquire for root level items
        return [self.jsonData count];
    }
    
    if (dataType == JSON_ARRAY || dataType == JSON_OBJECT) {
        return [item count];
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)theColumn byItem:(id)item
{
    JSONELement dataType = [self getDataStructureCode: NSStringFromClass([item class])];
    
    NSLog(@"[>>]%@", self.jsonData);
    NSLog(@"[>>>]%@", item);
    
    if (dataType == JSON_ARRAY || dataType == JSON_OBJECT)
        return [NSString stringWithFormat:@"%@ (%lu)", [self getDataStructureName:dataType], (unsigned long)[item count]];
    if (dataType == JSON_BOOL){
        return ([item boolValue] == YES) ? @"TRUE" : @"FALSE";
    }
    
    return item;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    // There is always one item on jsonData array
    if (item == nil){
        return [self.jsonData objectAtIndex:index];
    }
    
    JSONELement dataType = [self getDataStructureCode: NSStringFromClass([item class])];
    if (dataType == JSON_ARRAY) {
        return [item objectAtIndex:index];
    }
    if (dataType == JSON_OBJECT) {
        return [[item allValues] objectAtIndex:index];
    }
    
    return nil;
}




// Helpers
- (JSONELement)getDataStructureCode:(NSString *)structureName {
    if ([structureName isEqualToString:@"__NSCFNumber"])            return JSON_NUMBER;
    if ([structureName isEqualToString:@"__NSArrayI"])              return JSON_ARRAY;
    if ([structureName isEqualToString:@"__NSCFDictionary"])        return JSON_OBJECT;
    if ([structureName isEqualToString:@"__NSCFString"])            return JSON_STRING;
    if ([structureName isEqualToString:@"__NSCFBoolean"])           return JSON_BOOL;
    
    return -1;
}

- (NSString *)getDataStructureName:(NSInteger)structureCode {
    switch ((int) structureCode) {
        case JSON_NUMBER:
            return @"Number";
            break;
        case JSON_STRING:
            return @"String";
            break;
        case JSON_BOOL:
            return @"Boolean";
            break;
        case JSON_ARRAY:
            return @"Array";
            break;
        case JSON_OBJECT:
            return @"Object";
            break;
    }
    
    return @"Unknown";
}

// Function that unloads the JSON data from main window.
- (void) unloadJson
{
    self.jsonData = nil;
    [self.jsonArea setStringValue:@"[true, true, false, 10.401, {\"a\":10, \"b\": 20, \"c\": [10, 20, 30, 40, {\"t\": 10}], \"z\": {\"y\": [10, 200]}}]"];
    [self.tableView reloadData];
}




// Actions
- (IBAction)clearJsonAreaButtonClicked:(id)sender
{
    [self unloadJson];
}

- (IBAction)parseJsonButtonClicked:(id)sender
{
    NSError *jsonParsingError = nil;
    NSData  *jsonString = [[self.jsonArea stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *jsonStructure = [NSJSONSerialization JSONObjectWithData:jsonString options:0 error:&jsonParsingError];
    
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
    }
    
    // No errors so let's empty the _jsonData array...
    self.jsonData = nil;
    
    // Add the received data to the JsonData variable
    self.jsonData = [[NSArray alloc] initWithObjects:jsonStructure, nil];
    
    // ... and of course reload table data.
    [self.tableView reloadData];
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    self.jsonData = [self.jsonData sortedArrayUsingDescriptors: [self.tableView sortDescriptors]];
    [aTableView reloadData];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[NSApplication sharedApplication] stopModal];
}

// Shows the window if it has been closed and the user click on Dock Icon
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    
    // Resets the window content
    [self unloadJson];
    
	if( flag == NO ){
		[self.window makeKeyAndOrderFront:nil];
	}
    
	return YES;
}

@end