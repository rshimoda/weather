	//
	//  WeatherTableViewController.h
	//  Weather
	//
	//  Created by Sergey on 7/22/16.
	//  Copyright © 2016 Sergey Popov. All rights reserved.
	//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherTableViewController: UITableViewController <CLLocationManagerDelegate>

- (IBAction)addCity:(UIBarButtonItem *)sender;

@end
