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

@interface WeatherTableViewController ()

@property NSMutableArray *cities;
@property NSUserDefaults *defaults;

@end

@implementation WeatherTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.cities = [[NSMutableArray alloc] init];
	self.defaults = [NSUserDefaults standardUserDefaults];
	
//	self.cities = [NSMutableArray arrayWithArray:[self.defaults arrayForKey:@"cities"]];
	
	[self updateForecast];
	
	self.tableView.allowsMultipleSelectionDuringEditing = NO;
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
	
		// Uncomment the following line to preserve selection between presentations.
		// self.clearsSelectionOnViewWillAppear = NO;
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
	cell.cityName.text = city.name;
	cell.temperature.text = [city.temperature stringByAppendingString:@"°"];
	cell.forecast.text = city.currentWeatherForecast;
	cell.backgroundImage.image = [UIImage animatedImageNamed:city.currentWeatherForecast duration:1.0f];
	
	return cell;
}

 // Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
		// Return NO if you do not want the specified item to be editable.
 return YES;
}

 // Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
		 // Delete the row from the data source
	 [self.cities removeObjectAtIndex:[indexPath row]];
//	 [self saveUserDefaults];
	 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	 [tableView reloadData];
	 
 } 
}

#pragma mark - Update Forecast
- (void)updateForecast {
	for (NSInteger i = 0; i < self.cities.count; i++) {
		City *city = self.cities[i];
		
			//-- Make URL request with server
		NSHTTPURLResponse *response = nil;
		NSString *requestString = [NSString stringWithFormat:@"https://api.worldweatheronline.com/premium/v1/weather.ashx?key=5ac27e6fc5644463968124227162207&q="];
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
		city.temperature = currentTemperature;
		city.currentWeatherForecast = weatherDescription;
		
		self.cities[i] = city;
	}
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)addCity:(UIBarButtonItem *)sender {
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add a new city" message:@"" preferredStyle:UIAlertControllerStyleAlert];
	[alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) { textField.placeholder = @"Type city here";}];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Add City" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		City *newCity = [[City alloc]init];
		newCity.name = alertController.textFields.firstObject.text;
		[self.cities addObject:newCity];
//		[self saveUserDefaults];
		[self updateForecast];
		[self.tableView reloadData];
	}]];
	[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alertController animated:YES completion:nil];
}

- (void) saveUserDefaults {
	
	NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:self.cities.count];
	for (City *city in self.cities) {
		NSData *cityEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:city];
		[archiveArray addObject:cityEncodedObject];
	}
	[self.defaults setObject:archiveArray forKey:@"cities"];
}

@end
