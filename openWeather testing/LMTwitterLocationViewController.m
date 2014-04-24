//
//  LMTwitterLocationViewController.m
//  LMAlertViewDemo
//
//  Created by Lee McDermott on 07/12/2013.
//  Copyright (c) 2013 Bestir Ltd. All rights reserved.
//

#import "LMTwitterLocationViewController.h"
#import "LMTwitterComposeViewController.h"

@interface LMTwitterLocationViewController ()

@end

@implementation LMTwitterLocationViewController

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.mapView.centerCoordinate = CLLocationCoordinate2DMake(51.511214, -0.119824);
	
	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.mapView.centerCoordinate;
    annotation.title = @"London";
	
    [self.mapView addAnnotation:annotation];
	[self.mapView selectAnnotation:annotation animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(BOOL)!indexPath.row inSection:0]];
	lastCell.accessoryType = UITableViewCellAccessoryNone;
	
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	LMTwitterComposeViewController *twitterViewController = (LMTwitterComposeViewController *)[self backViewController];
	[twitterViewController setLocationTitle:selectedCell.textLabel.text];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.row == 0) {
		[self.mapView deselectAnnotation:self.mapView.annotations.firstObject animated:YES];
	}
	else {
		[self.mapView selectAnnotation:self.mapView.annotations.firstObject animated:YES];
	}
}

#pragma mark - Other methods

- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
	
    if (numberOfViewControllers < 2) {
        return nil;
	}
    else {
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
	}
}

@end
