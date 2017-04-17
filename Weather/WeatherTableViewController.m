	//
	//  WeatherTableViewController.m
	//  Weather
	//
	//  Created by Sergey on 7/22/16.
	//  Copyright © 2016 Sergey Popov. All rights reserved.
	//

#import "WeatherTableViewController.h"
#import "CityTableViewCell.h"
#import "City.h"
#import "Forecast.h"

@import CoreLocation;
@import AVFoundation;

@interface WeatherTableViewController () <CLLocationManagerDelegate>

@property NSMutableArray *cities;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property BOOL upToDate;

@end

@implementation WeatherTableViewController

NSUserDefaults *defaults;

CLLocation *currentLocation;


- (void)viewDidLoad {
	[super viewDidLoad];
    
//    NSLog(@"%@", )
	
	defaults = [NSUserDefaults standardUserDefaults];
		
	self.upToDate = NO;
	[self setNeedsStatusBarAppearanceUpdate];
	
	self.cities = [[NSMutableArray alloc] init];
	[self loadUserDefaults];
	if (self.cities.count == 0) {
		City *currentCity = [[City alloc] init];
		Forecast *forecast = [[Forecast alloc]init];
		currentCity.forecast = forecast;
		[self.cities addObject:currentCity];
		[self saveUserDefaults];
	}
	
	self.locationManager = [[CLLocationManager alloc]init];
	self.locationManager.delegate = self;
	self.locationManager.distanceFilter = kCLDistanceFilterNone;
	self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
		[self.locationManager requestWhenInUseAuthorization];
	}
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
	
	self.tableView.allowsMultipleSelectionDuringEditing = NO;
		//	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	
		// Uncomment the following line to preserve selection between presentations.
		// self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[self refresh];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

-(void)refresh {
	self.upToDate = NO;
//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.locationManager startUpdatingLocation];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.cities.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"City";
	CityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
		// Configure the cell...
	
	City *city =  self.cities[indexPath.row];
	NSString *fileName = [city.forecast.currentState stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSURL *videoURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"mov"]; // [city.forecast.currentState stringByReplacingOccurrencesOfString:@" " withString:@""]
	
	NSRange range = [city.name rangeOfString:@","];
	if (range.length > 0) {
		cell.cityName.text = [city.name substringToIndex:range.location];
	} else {
		cell.cityName.text = city.name;
	}
	cell.temperature.text = [city.forecast.currentTemperature stringByAppendingString:@"°"];
	cell.forecast.text = city.forecast.currentState;
	
	if (videoURL != nil && city.forecast.currentState != nil) {
		AVPlayer *avPlayer = [AVPlayer playerWithURL:videoURL];
		AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
		
		avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		avPlayer.volume = 0;
		avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
		avPlayerLayer.frame = cell.contentView.bounds;
		avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(playerItemDidReachEnd:)
													 name:AVPlayerItemDidPlayToEndTimeNotification
												   object:[avPlayer currentItem]];
		
		
		cell.contentView.backgroundColor = [UIColor clearColor];
		[cell.layer insertSublayer:avPlayerLayer atIndex:0];
		[avPlayer seekToTime:kCMTimeZero];
		[avPlayer play];
	} else {
		cell.backgroundImage.image = [UIImage imageNamed:[city.forecast.currentState stringByReplacingOccurrencesOfString:@" " withString:@""]]; //[UIImage animatedImageNamed:@"Sunny-" duration:1.0f];
	}
	
	return cell;
}

 // Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
		// Return NO if you do not want the specified item to be editable.
	if (indexPath.row == 0) {
		return NO;
	} else {
		return YES;
	}
}

 // Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
		 // Delete the row from the data source
	 [self.cities removeObjectAtIndex:[indexPath row]];
	 [self saveUserDefaults];
	 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	 [tableView reloadData];
	 
 } 
}


#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	currentLocation = [locations objectAtIndex:0];
	[self.locationManager stopUpdatingLocation];
	NSLog(@"Detected Location : %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
	CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
	[geocoder reverseGeocodeLocation:currentLocation
				   completionHandler:^(NSArray *placemarks, NSError *error) {
					   if (error){
						   NSLog(@"Geocode failed with error: %@", error);
						   return;
					   }
					   CLPlacemark *placemark = [placemarks objectAtIndex:0];
					   NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
					   
					   City *currentCity = self.cities[0];
					   currentCity.name = [placemark.locality stringByAppendingString:[@", " stringByAppendingString:placemark.country]];
					   self.cities[0] = currentCity;
					   
					   if (!self.upToDate) {
						   dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
							   [self updateForecast];
							   dispatch_async(dispatch_get_main_queue(), ^{
								   [self.tableView reloadData];
							   });
						   });
					   }
					   self.upToDate = YES;
				   }];
	[self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"failed to fetch current location : %@", error);
	
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark Add City

- (IBAction)addCity:(UIButton *)sender {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a new city" message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) { textField.placeholder = @"Type city here";}];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Add City" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		City *newCity = [[City alloc]init];
		Forecast *newForecast = [[Forecast alloc]init];
		newCity.forecast = newForecast;
		newCity.name = alertController.textFields.firstObject.text;
		[self.cities addObject:newCity];
		[self saveUserDefaults];
		[self refresh];
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)addLocation:(UIButton *)sender {
}

#pragma mark NSUserDefaults

- (void) loadUserDefaults {
	NSMutableArray *archievedArray = [defaults objectForKey:@"cities"];
	for (NSData *encodedObject in archievedArray) {
		City *city = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
		[self.cities addObject:city];
	}
}

- (void) saveUserDefaults {
	
	NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:self.cities.count];
	for (City *city in self.cities) {
		NSData *cityEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:city];
		[archiveArray addObject:cityEncodedObject];
	}
	[defaults setObject:archiveArray forKey:@"cities"];
	[defaults synchronize];
}

#pragma mark - Update Forecast
- (void)updateForecast {
	for (NSInteger i = 0; i < self.cities.count; i++) {
		City *city = self.cities[i];
		
		if (city.name != nil) {
			
				//-- Make URL request with server
			NSHTTPURLResponse *response = nil;
			NSString *requestString = [NSString stringWithFormat:@"https://api.worldweatheronline.com/premium/v1/weather.ashx?key=5e266c83810a4e93bd394859170703&q="];
			requestString = [requestString stringByAppendingString:city.name];
			requestString = [requestString stringByAppendingString:@"&date=today&num_of_days=1&show_comments=no&showlocaltime=yes&format=json"];
			
			NSURL *url = [NSURL URLWithString:[requestString stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]]];
			
				//-- Get request and response though URL
			NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
			NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
			
				//-- JSON Parsing
			NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
			NSLog(@"Result = %@",result);
			
			
			NSDictionary *data = result[@"data"];
			
			NSArray *requestArray = data[@"request"];
			NSDictionary *requestDictionary = [requestArray firstObject];
			NSString *cityName = requestDictionary[@"query"];
			
			NSArray *currentConditionArray = data[@"current_condition"];
			NSDictionary *currentConditionDictionary = [currentConditionArray firstObject];
			NSString *currentTemperature = currentConditionDictionary[@"temp_C"];
			
			NSArray *weatherDescriptionArray = currentConditionDictionary[@"weatherDesc"];
			NSDictionary *weatherDescriptionDictionary = [weatherDescriptionArray firstObject];
			NSString *weatherDescription = weatherDescriptionDictionary[@"value"];
			
			city.name = cityName;
			city.forecast.currentTemperature = currentTemperature;
			city.forecast.currentState = weatherDescription;
			
			self.cities[i] = city;
		}
	}
		//	[self.locationManager stopUpdatingLocation];
	[self.refreshControl endRefreshing];
		//	[self.tableView reloadData];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
	AVPlayerItem *p = [notification object];
	[p seekToTime:kCMTimeZero];
}

@end
