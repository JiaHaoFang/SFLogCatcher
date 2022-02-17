//
//  UIWindow+swizzle.m
//  SFAPPRealTimeLogCaughter
//
//  Created by StephenFang on 2022/1/10.
//

#import "UIResponder+swizzle.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@implementation UIResponder (swizzle)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass =  [self class];
        NSString * originSelectorString = @"motionBegan:withEvent:";
        NSString * swizzleSelectorString = @"swizzled_motionBegan:withEvent:";

        SEL originSelector = NSSelectorFromString(originSelectorString);
        SEL swizzleSelector = NSSelectorFromString(swizzleSelectorString);

        Method originMethd = class_getInstanceMethod(aClass, originSelector);
        Method swizzleMethod = class_getInstanceMethod(aClass, swizzleSelector);
        method_exchangeImplementations(originMethd, swizzleMethod);
    });
}

- (void)swizzled_motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event API_AVAILABLE(ios(3.0)) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AAAAA" object:nil];
    if ([self respondsToSelector:@selector(swizzled_motionBegan:withEvent:)]) {
        [self swizzled_motionBegan: motion withEvent: event];
    }
}
@end
