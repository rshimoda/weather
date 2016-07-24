	//
	//  Forecast.m
	//  Weather
	//
	//  Created by Sergey on 7/22/16.
	//  Copyright © 2016 Sergey Popov. All rights reserved.
	//

#import "Forecast.h"

@implementation Forecast

- (void)encodeWithCoder:(NSCoder *)encoder {
		//Encode properties, other class variables, etc
	[encoder encodeObject:self.currentState forKey:@"currentState"];
	[encoder encodeObject:self.currentTemperature forKey:@"currentTemperature"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if((self = [super init])) {
			//decode properties, other class vars
		self.currentState = [decoder decodeObjectForKey:@"currentState"];
		self.currentTemperature = [decoder decodeObjectForKey:@"currentTemperature"];
	}
	return self;
}

@end
