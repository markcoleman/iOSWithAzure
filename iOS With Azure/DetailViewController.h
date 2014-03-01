//
//  DetailViewController.h
//  iOS With Azure
//
//  Created by Coleman, Mark on 3/1/14.
//  Copyright (c) 2014 Coleman, Mark. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
