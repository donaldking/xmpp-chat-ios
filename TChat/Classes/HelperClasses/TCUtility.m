//
//  TCUtility.m
//  TChat
//
//  Created by SWATI KIRVE on 08/07/2014.
//  Copyright (c) 2014 Tusk Solutions. All rights reserved.
//

#import "TCUtility.h"
#import "NSDate+Utilities.h"
#import "TCAppDelegate.h"

@implementation TCUtility

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert
{
    NSString *noHashString = [stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@""]; // remove the #
    NSScanner *scanner = [NSScanner scannerWithString:noHashString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet symbolCharacterSet]]; // remove + and $
    unsigned hex;
    if (![scanner scanHexInt:&hex]) return nil;
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
}

+(NSString *)dayLabelForMessage:(NSDate *)msgDate
{
    NSString *retStr = @"";
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *time = [formatter stringFromDate:msgDate];
    
    if ([msgDate isToday])
    {
        retStr = [NSString stringWithFormat:@"today %@",time];
    }
    else if ([msgDate isYesterday])
    {
        retStr = [NSString stringWithFormat:@"yesterday %@" ,time];
    }
    else
    {
        [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *time = [formatter stringFromDate:msgDate];
        retStr = [NSString stringWithFormat:@"%@" ,time];
    }
    return retStr;
}
+ (NSString*) createUniqueFileNameWithoutExtension {
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"ddmmyyyy-HHmmssSSS"];
    NSString *ret = [formatter stringFromDate:[NSDate date]];
    return ret;
    
}


+ (BOOL)saveToKeyChain:(NSString*)username andPassword:(NSString*)password
{
    if ([username length]>=1) {
        [XAppDelegate.keyChain setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    }
    if ([password length] >=1) {
        [XAppDelegate.keyChain setObject:password forKey:(__bridge id)kSecValueData];
    }
    
    return YES;
}


+(NSString*) formattedDateFor:(NSDate*)msg_date
{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:msg_date];
    return  stringFromDate;
}

+(NSString *)getDateFromString:(NSString *)string
{
    
    NSString * dateString = [NSString stringWithFormat: @"%@",string];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* myDate = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:myDate];
    
    NSLog(@"%@", stringFromDate);
    return stringFromDate;
}

+(NSInteger) numberOfDaysBetDates:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *startDate = [NSDate date];
    NSLog(@"%@",startDate);
    
    NSDate *endDate =  [dateFormatter dateFromString:dateString];
    
    NSLog(@"%@",endDate);
    
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    return components.day;
}

+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
