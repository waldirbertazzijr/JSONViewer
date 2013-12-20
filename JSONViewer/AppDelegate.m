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
    JSON_STRING,
    JSON_BOOL
} JSONELement;


// JSON Data MutabeArray
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
        
        if (dataType == JSON_ARRAY || dataType == JSON_OBJECT) return [NSString stringWithFormat:@"%lu", (unsigned long)[item count]];
        return @"-";
        
    } else if([[theColumn identifier] isEqualToString:@"itemtype"]) { // type
        
        return [self getDataStructureName:dataType];
        
    } else { // name
        
        if (dataType == JSON_ARRAY || dataType == JSON_OBJECT)
            return [NSString stringWithFormat:@"%@ (%lu)", [self getDataStructureName:dataType], (unsigned long)[item count]];
        return item;
        
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    JSONELement dataType = [self getDataStructureCode: NSStringFromClass([item class])];
    
    if (item == nil){
        return [self.jsonData objectAtIndex:index];
    }
    if (dataType == JSON_ARRAY || dataType == JSON_OBJECT) {
        NSLog(@"%@", item);
        return [item objectAtIndex:index];
    }
    return nil;
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
        [self.jsonData addObject:structure];
    }
}

- (JSONELement)getDataStructureCode:(NSString *)structureName {
    NSLog(@"%@", structureName);
    if ([structureName isEqualToString:@"__NSCFNumber"])            return JSON_INTEGER;
    if ([structureName isEqualToString:@"__NSArrayI"])              return JSON_ARRAY;
    if ([structureName isEqualToString:@"__NSCFDictionary"])        return JSON_OBJECT;
    if ([structureName isEqualToString:@"__NSCFString"])            return JSON_STRING;
    if ([structureName isEqualToString:@"__NSCFBoolean"])           return JSON_BOOL;
    
    return -1;
}

- (NSString *)getDataStructureName:(NSInteger)structureCode {
    switch ((int) structureCode) {
        case JSON_INTEGER:
            return @"Integer";
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
