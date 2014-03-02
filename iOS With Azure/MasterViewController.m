//
//  MasterViewController.m
//  iOS With Azure
//
//  Created by Coleman, Mark on 3/1/14.
//  Copyright (c) 2014 Coleman, Mark. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <WindowsAzureMobileServices.h>
#import "AppDelegate.h"
#import <ATMHud.h>

@interface MasterViewController () {
    NSMutableArray *_objects;
    ATMHud *hud;
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Keep a strong ivar reference to it (ie, "ATMHud *hud")
    hud = [[ATMHud alloc] initWithDelegate:self];
    // or  hud = [ATMHud new]; using the block delegate
    

    [hud setActivity:YES];
    [hud showInView:self.view];


    
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    addButton.enabled = NO;
    
    //get data from azure mobile services
    [hud setCaption:@"Getting guids from azure"];
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    MSTable *itemTable = [client tableWithName:@"Item"];
    [itemTable readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        if (!_objects) {
           _objects = [[NSMutableArray alloc] init];
        }
        
        for(NSDictionary* object in items){
            [_objects insertObject: object atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        addButton.enabled = YES;
        [hud hide];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    
    [hud setCaption:@"Sending Guid to Azure"];
    
    NSString *UUID = [[NSUUID UUID] UUIDString];
    
    //insert data into mobile services
    MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
    NSDictionary *item = @{ @"text" : UUID };
    MSTable *itemTable = [client tableWithName:@"Item"];
    [itemTable insert:item completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
            
            [_objects insertObject: insertedItem atIndex:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

        }
        [hud hide];
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *item = _objects[indexPath.row];
    
    NSString* itemText = [item valueForKey:@"text"];
    
    
    cell.textLabel.text = [itemText description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [hud setCaption:@"Removing guid from azure."];
        //remove the item from mobile services
        MSClient *client = [(AppDelegate *) [[UIApplication sharedApplication] delegate] client];
        MSTable *itemTable = [client tableWithName:@"Item"];
        
        NSDictionary* item = _objects[indexPath.row];
        NSString* itemId = [item valueForKey:@"id"];
        
        [itemTable deleteWithId:itemId completion:^(id itemId, NSError *error) {
           
            [_objects removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [hud hide];
        }];
        

    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        NSDictionary *item = _objects[indexPath.row];
        NSString* itemText = [item valueForKey:@"text"];
        
        self.detailViewController.detailItem = itemText;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSDictionary *item = _objects[indexPath.row];
        NSString* itemText = [item valueForKey:@"text"];
        
        [[segue destinationViewController] setDetailItem:itemText];
    }
}

@end
