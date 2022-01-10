//
//  OCSwizzle.m
//  RealTimeLogCaughter
//
//  Created by StephenFang on 2021/8/23.
//

#import <Foundation/Foundation.h>
#import "Launcher.h"
#import "SFAPPRealTimeLogCaughter/SFAPPRealTimeLogCaughter-Swift.h"

@implementation Launcher

+ (void)load {
    [SFAppRealTimeLogCaughter enable];
}

@end
