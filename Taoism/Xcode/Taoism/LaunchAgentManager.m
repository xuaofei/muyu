//
//  LaunchAgentManager.m
//  Taoism
//
//  Created by xuaofei on 2025/12/21.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "LaunchAgentManager.h"

@implementation LaunchAgentManager

+ (BOOL)addAppToLaunchAgents {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 1. 确定目标目录和文件路径
    NSString *launchAgentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/LaunchAgents"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (!bundleIdentifier) {
        NSLog(@"Error: Unable to get bundle identifier.");
        return NO;
    }
    NSString *plistFileName = [NSString stringWithFormat:@"%@.plist", bundleIdentifier];
    NSString *dstLaunchPath = [launchAgentsDir stringByAppendingPathComponent:plistFileName];
    
    // 2. 检查是否已存在，避免重复添加
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:dstLaunchPath isDirectory:&isDir] && !isDir) {
        NSLog(@"LaunchAgent plist already exists at: %@", dstLaunchPath);
        return YES; // 已经存在，可视为成功
    }
    
    // 3. 构造 plist 内容字典
    NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] init];
    
    // 3.1 设置标签 (Label)，必须是唯一的，通常使用 Bundle Identifier
    [plistDict setObject:bundleIdentifier forKey:@"Label"];
    
    // 3.2 设置程序参数 (ProgramArguments)
    // 第一个参数是程序的可执行文件路径，后面可以跟启动参数
    NSMutableArray *programArguments = [NSMutableArray array];
    [programArguments addObject:[[NSBundle mainBundle] executablePath]]; // 可执行文件路径
    [programArguments addObject:@"-AutoLaunched"]; // 示例：可以添加自定义启动参数，在应用中解析
    
    [plistDict setObject:programArguments forKey:@"ProgramArguments"];
    
    // 3.3 设置在加载时运行（即用户登录时运行）
    [plistDict setObject:@(YES) forKey:@"RunAtLoad"];
    
    // 3.4 (可选) 设置工作目录 (WorkingDirectory)
    // NSString *workingDirectory = [[NSBundle mainBundle] resourcePath];
    // [plistDict setObject:workingDirectory forKey:@"WorkingDirectory"];
    
    // 3.5 (可选) 标准输出和错误日志路径，便于调试
    // NSString *stdOutPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Logs/YourApp.log"];
    // NSString *stdErrPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Logs/YourApp_Error.log"];
    // [plistDict setObject:stdOutPath forKey:@"StandardOutPath"];
    // [plistDict setObject:stdErrPath forKey:@"StandardErrorPath"];
    
    // 3.6 (可选) 设置进程退出后是否保持活动，如果希望应用始终运行，可设为YES
    // [plistDict setObject:@(NO) forKey:@"KeepAlive"];
    
    // 4. 确保目标目录存在
    NSError *creationError = nil;
    BOOL isDirExist = [fileManager fileExistsAtPath:launchAgentsDir isDirectory:&isDir];
    if (!isDirExist) {
        BOOL createSuccess = [fileManager createDirectoryAtPath:launchAgentsDir withIntermediateDirectories:YES attributes:nil error:&creationError];
        if (!createSuccess) {
            NSLog(@"Error: Could not create LaunchAgents directory. %@", creationError);
            return NO;
        }
    }
    
    // 5. 将字典写入 plist 文件
    BOOL writeSuccess = [plistDict writeToFile:dstLaunchPath atomically:YES];
    if (!writeSuccess) {
        NSLog(@"Error: Failed to write plist file to %@", dstLaunchPath);
        return NO;
    }
    
    // 6. (可选) 设置文件权限为644 (rw-r--r--)
    NSDictionary *attributes = @{NSFilePosixPermissions: @0644};
    NSError *attributesError = nil;
    BOOL setAttrSuccess = [fileManager setAttributes:attributes ofItemAtPath:dstLaunchPath error:&attributesError];
    if (!setAttrSuccess) {
        NSLog(@"Warning: Could not set file permissions on plist. %@", attributesError);
        // 这不是一个致命错误，继续执行
    }
    
    NSLog(@"Successfully added LaunchAgent at: %@", dstLaunchPath);
    return YES;
}

+ (BOOL)removeAppFromLaunchAgents {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 1. 确定目标文件路径
    NSString *launchAgentsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/LaunchAgents"];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (!bundleIdentifier) {
        NSLog(@"Error: Unable to get bundle identifier.");
        return NO;
    }
    NSString *plistFileName = [NSString stringWithFormat:@"%@.plist", bundleIdentifier];
    NSString *dstLaunchPath = [launchAgentsDir stringByAppendingPathComponent:plistFileName];
    
    // 2. 检查文件是否存在
    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:dstLaunchPath isDirectory:&isDir] || isDir) {
        NSLog(@"LaunchAgent plist does not exist at: %@", dstLaunchPath);
        return YES; // 文件不存在，可视为移除成功
    }
    
    // 3. 删除 plist 文件
    NSError *removeError = nil;
    BOOL removeSuccess = [fileManager removeItemAtPath:dstLaunchPath error:&removeError];
    if (!removeSuccess) {
        NSLog(@"Error: Failed to remove LaunchAgent plist. %@", removeError);
        return NO;
    }
    
    NSLog(@"Successfully removed LaunchAgent at: %@", dstLaunchPath);
    return YES;
}

@end
