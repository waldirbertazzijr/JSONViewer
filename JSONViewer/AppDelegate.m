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
    JSON_INTEGER,
    JSON_ARRAY,
    JSON_OBJECT,
} JSONELement;

// Instantiation of json array.
-(NSMutableArray*)jsonData
{
    if (_jsonData == nil) _jsonData = [[NSMutableArray alloc]init];
    return _jsonData;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.jsonArea setStringValue:@""];
}


// Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.jsonData.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    JSONELement dataType = [self getDataStructureCode: NSStringFromClass([[self.jsonData objectAtIndex:row] class])];
    
    if([[tableColumn identifier] isEqualToString:[self.jsonObjectName identifier]]) { // Name...
        
        if (dataType == 1 || dataType == 2) {
            return [NSString stringWithFormat:@"%@ (%lu)", [self getDataStructureName:dataType], (unsigned long)[[self.jsonData objectAtIndex:row] count]];
        } else {
            return [self.jsonData objectAtIndex:row];
        }
        
    } else if ([[tableColumn identifier] isEqualToString:[self.jsonObjectLength identifier]]) { // Length...
        
        if (dataType == 1 || dataType == 2) {
            return [NSString stringWithFormat:@"(%lu)", (unsigned long)[[self.jsonData objectAtIndex:row] count]];
        } else {
            return @"-";
        }
        
    } else { // Type
        
        return [self getDataStructureName:dataType];
        
    }
}

// Helpers
- (void)parseJSONTree:(NSArray *)jsonArray identLevel:(NSInteger)identation {
    // Debug
    printf("%s - %lu (%s)", [[self.jsonArea stringValue] UTF8String], (unsigned long)[jsonArray count], [NSStringFromClass([jsonArray class]) UTF8String]);
    printf("\n");
    
    // Single Item
    NSDictionary *structure;
    
    // Parses JSON object
    for(int i=0; i < [jsonArray count];i++) {
        structure = [jsonArray objectAtIndex:i];
        
        NSInteger dataType = [self getDataStructureCode: NSStringFromClass([structure class])];
        if (dataType == 1 || dataType == 2) {
            
        } else {
            
        }
        
        [self.jsonData addObject:structure];
    }
}

- (JSONELement)getDataStructureCode:(NSString *)structureName {
    if ([structureName isEqualToString:@"__NSCFNumber"]) {
        return JSON_INTEGER;
    } else if ([structureName isEqualToString:@"__NSArrayI"]) {
        return JSON_ARRAY;
    } else if ([structureName isEqualToString:@"__NSCFDictionary"]) {
        return JSON_OBJECT;
    }
    
    return -1;
}

- (NSString *)getDataStructureName:(NSInteger)structureCode {
    switch ((int) structureCode) {
        case JSON_INTEGER:
            return @"Integer";
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
    [_jsonData removeAllObjects];
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
        [_jsonData removeAllObjects];
        
        // Call recursive parseJsonTree
        [self parseJSONTree:jsonStructure identLevel:0];
        
        // ... and of course reload table data.
        [self.tableView reloadData];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[NSApplication sharedApplication] stopModal];
}

@end
