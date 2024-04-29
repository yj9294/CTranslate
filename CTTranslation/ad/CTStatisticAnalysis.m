//
//  CTStatisticAnalysis.m
//  CTTranslation
//
//  Created by  CTTranslation on 2024/3/8.
//

#import "CTStatisticAnalysis.h"
#import <FirebaseAnalytics/FirebaseAnalytics.h>

@implementation CTStatisticAnalysis

+ (void)saveEvent:(NSString *)event params:(nullable NSDictionary *)params {
    [FIRAnalytics logEventWithName:event parameters:params];
    NSLog(@"\n<User Event> event:%@, params:%@", event, params);
}

@end
