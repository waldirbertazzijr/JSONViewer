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
    [self.jsonData addObject:[[NSArray alloc] initWithObjects:@"Linha 1 - Coluna 1",@"Linha 1 - Coluna 2", nil]];
    [self.jsonData addObject:[[NSArray alloc] initWithObjects:@"Linha 2 - Coluna 1",@"Linha 2 - Coluna 2", nil]];
    [self.jsonData addObject:[[NSArray alloc] initWithObjects:@"Linha 3 - Coluna 1",@"Linha 3 - Coluna 2", nil]];
    [self.jsonData addObject:[[NSArray alloc] initWithObjects:@"Linha 4 - Coluna 1",@"Linha 4 - Coluna 2", nil]];
    [self.jsonData addObject:[[NSArray alloc] initWithObjects:@"Linha 5 - Coluna 1",@"Linha 5 - Coluna 2", nil]];
    
    [self.jsonArea setString:@"Paste your JSON here..."];
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
    NSData * jsonString = (NSData *) [self.jsonArea string];
    printf("%s", [(NSString *) jsonString UTF8String]);
    
    [self.tableView reloadData];
}

@end
