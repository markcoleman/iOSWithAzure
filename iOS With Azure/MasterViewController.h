//
//  MasterViewController.h
//  iOS With Azure
//
//  Created by Coleman, Mark on 3/1/14.
//  Copyright (c) 2014 Coleman, Mark. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
