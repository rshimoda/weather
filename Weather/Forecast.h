	//
	//  Forecast.h
	//  Weather
	//
	//  Created by Sergey on 7/22/16.
	//  Copyright © 2016 Sergey Popov. All rights reserved.
	//

#import <Foundation/Foundation.h>

@interface Forecast : NSObject

@property NSString *currentState;
@property NSString *currentTemperature;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
