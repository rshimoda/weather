	//
	//  CityTableViewCell.h
	//  Weather
	//
	//  Created by Sergey on 7/22/16.
	//  Copyright © 2016 Sergey Popov. All rights reserved.
	//

#import <UIKit/UIKit.h>

@interface CityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UILabel *forecast;

@end
