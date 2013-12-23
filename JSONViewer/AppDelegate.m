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
    [self.jsonArea setStringValue:@"[{\"a\":10, \"b\": 20, \"c\": [10, 20, 30, 40, {\"t\": 10}], \"z\": {\"y\": [10, 200]}}]"];
    
    for (NSTableColumn *tableColumn in self.tableView.tableColumns ) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:tableColumn.identifier ascending:YES selector:@selector(compare:)];
        [tableColumn setSortDescriptorPrototype:sortDescriptor];
    }
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
    
    if ([[theColumn identifier] isEqualToString:@"itemlength"]) { // length
        
        if (dataType == JSON_ARRAY || dataType == JSON_OBJECT){
            return [NSString stringWithFormat:@"%lu", (unsigned long)[item count]];
        }
        return @"-";
        
    } else if([[theColumn identifier] isEqualToString:@"itemtype"]) { // type
        
        return [self getDataStructureName:dataType];
        
    } else { // name
        if (dataType == JSON_ARRAY || dataType == JSON_OBJECT)
            return [NSString stringWithFormat:@"%@ (%lu)", [self getDataStructureName:dataType], (unsigned long)[item count]];
        if (dataType == JSON_BOOL){
            return ([item boolValue] == YES) ? @"TRUE" : @"FALSE";
        }
        return item;
        
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    
    if (item == nil){
        //NSLog(@"%@", self.jsonData);
        
        JSONELement dataType = [self getDataStructureCode: NSStringFromClass([self.jsonData class])];
        if (dataType == JSON_ARRAY) {
            return [self.jsonData objectAtIndex:index];
        }
        if (dataType == JSON_OBJECT){
            NSArray *values = [[self.jsonData objectAtIndex:0] allValues];
            return [values objectAtIndex:index];
        }
    }
    
    JSONELement dataType = [self getDataStructureCode: NSStringFromClass([item class])];
    if (dataType == JSON_ARRAY) {
        //NSLog(@"Array: %@", item);
        return [item objectAtIndex:index];
    }
    if (dataType == JSON_OBJECT) {
        //NSLog(@"Object: %@", item);
        NSArray *values = [item allValues];
        return [values objectAtIndex:index];
    }
    
    return nil;
}




// Helpers
- (void)parseJSONTree:(NSArray *)jsonData identLevel:(NSInteger)identation {
    // Debug
    //printf("%s - %lu (%s)", [[self.jsonArea stringValue] UTF8String], (unsigned long)[jsonData count], [NSStringFromClass([jsonData class]) UTF8String]);
    //printf("\n");
    
    // Single Item
    NSDictionary *structure;
    
    // Parses JSON object
    for(int i=0; i < [jsonData count];i++) {
        structure = [jsonData objectAtIndex:i];
        //[self.jsonData addObject:structure];
    }
}

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




// Actions
- (IBAction)clearJsonAreaButtonClicked:(id)sender
{
    [self.jsonArea setStringValue:@""];
    self.jsonData = nil;
    self.jsonData = [[NSArray alloc] init];
    [self.tableView reloadData];
    
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
        
    } else {
        
        // No errors so let's empty the _jsonData array...
        self.jsonData = nil;
        
        // Add the received data to the JsonData variable
        self.jsonData = [[NSArray alloc] initWithObjects:jsonStructure, nil];
        
        // ... and of course reload table data.
        [self.tableView reloadData];
    }
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
    self.jsonData = [self.jsonData sortedArrayUsingDescriptors: [self.tableView sortDescriptors]];
    [aTableView reloadData];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[NSApplication sharedApplication] stopModal];
}

@end
