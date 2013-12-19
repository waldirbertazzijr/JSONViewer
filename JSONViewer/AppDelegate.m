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
}


// Table View
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.jsonData.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSInteger dataType = [self getDataStructureCode: NSStringFromClass([[self.jsonData objectAtIndex:row] class])];
    
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
- (void)parseJSONTree:(NSArray *)jsonArray {
    // Single Item
    NSDictionary *structure;
    
    // Parses JSON object
    for(int i=0; i < [jsonArray count];i++) {
        structure = [jsonArray objectAtIndex:i];
        NSLog(@"Item: %@ (%s)", structure, [NSStringFromClass([structure class]) UTF8String]);
        [self.jsonData addObject:structure];
    }
}

- (NSInteger)getDataStructureCode:(NSString *)structureName {
    if ([structureName isEqualToString:@"__NSCFNumber"]) {
        return 0;
    } else if ([structureName isEqualToString:@"__NSArrayI"]) {
        return 1;
    } else if ([structureName isEqualToString:@"__NSCFDictionary"]) {
        return 2;
    }
    
    return -1;
}

- (NSString *)getDataStructureName:(NSInteger)structureCode {
    switch ((int) structureCode) {
        case 0:
            return @"Integer";
            break;
        case 1:
            return @"Array";
            break;
        case 2:
            return @"Object";
            break;
    }
    
    return @"Unknown";
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
        // No error so let's empty the _jsonData array...
        [_jsonData removeAllObjects];
        
        // Debug
        printf("%s - %lu (%s)", [[self.jsonArea string] UTF8String], (unsigned long)[jsonStructure count], [NSStringFromClass([jsonStructure class]) UTF8String]);
        printf("\n");
        
        // Call recursive parseJsonTree
        [self parseJSONTree:jsonStructure];
        
        // ... and of course reload table data...
        [self.tableView reloadData];
        
        // that's it!
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [[NSApplication sharedApplication] stopModal];
}

@end
