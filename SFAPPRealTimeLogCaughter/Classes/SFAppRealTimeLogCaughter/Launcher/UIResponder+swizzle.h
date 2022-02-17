//
//  UIWindow+swizzle.h
//  SFAPPRealTimeLogCaughter
//
//  Created by StephenFang on 2022/1/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (swizzle)
- (void)swizzled_motionBegan:(UIEventSubtype)motion withEvent:(nullable UIEvent *)event;
@end

NS_ASSUME_NONNULL_END
