	//
	//  City.h
	//  Weather
	//
	//  Created by Sergey on 7/22/16.
	//  Copyright © 2016 Sergey Popov. All rights reserved.
	//

#import <Foundation/Foundation.h>
#import "Forecast.h"

@interface City : NSObject

@property NSString *name;
@property Forecast *forecast;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
