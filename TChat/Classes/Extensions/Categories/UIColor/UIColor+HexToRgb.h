//
//  UIColor+HexToRgb.h
//  Veemer
//
//  Created by Donald King on 11/05/2013.
//  Copyright (c) 2013 SecureSwift Europe Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexToRgb)

// Converts standard Hex code to Rgb and returns
+ (UIColor *) colorFromHexString:(NSString *)hexString;

@end
