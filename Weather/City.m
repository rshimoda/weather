	//
	//  City.m
	//  Weather
	//
	//  Created by Sergey on 7/22/16.
	//  Copyright © 2016 Sergey Popov. All rights reserved.
	//

#import "City.h"

@implementation City

- (void)encodeWithCoder:(NSCoder *)encoder {
		//Encode properties, other class variables, etc
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.forecast forKey:@"forecast"];
}

- (id)initWithCoder:(NSCoder *)decoder {
	if((self = [super init])) {
			//decode properties, other class vars
		self.name = [decoder decodeObjectForKey:@"name"];
		self.forecast = [decoder decodeObjectForKey:@"forecast"];
	}
	return self;
}

@end