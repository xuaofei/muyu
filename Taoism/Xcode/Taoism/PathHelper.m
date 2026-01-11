//
//  PathHelper.m
//  Taoism
//
//  Created by xuaofei on 2026/1/10.
//  Copyright © 2026 Unity Technologies. All rights reserved.
//

#import "PathHelper.h"

@implementation PathHelper
+ (NSString *)appSupportDirPath {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSError *error = nil;
    NSURL *base = [fm URLForDirectory:NSApplicationSupportDirectory
                             inDomain:NSUserDomainMask
                    appropriateForURL:nil
                               create:YES
                                error:&error];
    if (!base) return NSTemporaryDirectory(); // 兜底
    NSString *bundleID = NSBundle.mainBundle.bundleIdentifier ?: @"app";
    NSURL *dir = [base URLByAppendingPathComponent:bundleID isDirectory:YES];
    [fm createDirectoryAtURL:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return dir.path;
}

@end
