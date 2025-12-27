//
//  TCPServer.m
//  Taoism
//
//  Created by xuaofei on 2025/11/11.
//  Copyright © 2025 Unity Technologies. All rights reserved.
//

#import "TCPServer.h"
#import "define.h"
#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@interface TCPServer()
@property (nonatomic, assign) int serverSocket;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) int clientSocket;
@end

@implementation TCPServer

+ (instancetype)shared {
    static TCPServer *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[TCPServer alloc] init];
    });
    
    return obj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serverSocket = -1;
        self.isRunning = NO;
        self.clientSocket = -1;
    }
    
    return self;
}

- (void)startServerOnPort:(int)port {
    // 1. 创建TCP Socket
    _serverSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (_serverSocket == -1) {
        NSLog(@"创建socket失败");
        return;
    }
    
    // 设置SO_REUSEADDR选项避免地址占用错误
    int opt = 1;
    if (setsockopt(_serverSocket, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
        NSLog(@"设置socket选项失败");
        close(_serverSocket);
        return;
    }
    
    // 2. 绑定地址和端口
    struct sockaddr_in serverAddr;
    memset(&serverAddr, 0, sizeof(serverAddr));
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = htonl(INADDR_ANY); // 监听所有接口
    serverAddr.sin_port = htons(port);
    
    if (bind(_serverSocket, (struct sockaddr*)&serverAddr, sizeof(serverAddr)) < 0) {
        NSLog(@"绑定端口失败: %s", strerror(errno));
        close(_serverSocket);
        return;
    }
    
    // 3. 开始监听
    if (listen(_serverSocket, 5) < 0) { // 最多5个连接排队
        NSLog(@"监听失败");
        close(_serverSocket);
        return;
    }
    
    NSLog(@"TCP服务端启动成功，监听端口: %d", port);
    _isRunning = YES;
    
    // 4. 在接受连接的循环中处理客户端
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self acceptClients];
    });
}

- (void)acceptClients {
    while (_isRunning) {
        @autoreleasepool {
            struct sockaddr_in clientAddr;
            socklen_t clientAddrLen = sizeof(clientAddr);
            
            // 接受客户端连接
            int clientSocket = accept(_serverSocket, (struct sockaddr*)&clientAddr, &clientAddrLen);
            if (clientSocket < 0) {
                if (_isRunning) {
                    NSLog(@"接受连接失败");
                }
                continue;
            }
            
            self.clientSocket = clientSocket;
            
            // 获取客户端IP地址
            char clientIP[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, &clientAddr.sin_addr, clientIP, INET_ADDRSTRLEN);
            NSLog(@"客户端连接: %s:%d", clientIP, ntohs(clientAddr.sin_port));
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CLIENT_CONNECT_NETWORK object:nil];
            return;
            // 为新客户端创建处理线程
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [self handleClient:self.clientSocket];
//            });
        }
    }
}

- (void)handleClient:(int)clientSocket {
    
    
    char buffer[1024];
    ssize_t bytesRead;
    
    // 发送欢迎消息
    const char *welcomeMsg = "欢迎连接到OC TCP服务器!\r\n";
    send(clientSocket, welcomeMsg, strlen(welcomeMsg), 0);
    
    while ((bytesRead = recv(clientSocket, buffer, sizeof(buffer) - 1, 0)) > 0) {
        // 添加字符串结束符
        buffer[bytesRead] = '\0';
        
        NSString *receivedMessage = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
        if (receivedMessage) {
            receivedMessage = [receivedMessage stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSLog(@"收到客户端消息: %@", receivedMessage);
            
            // 回复确认消息
            NSString *response = [NSString stringWithFormat:@"服务器已收到: %@\r\n", receivedMessage];
            const char *responseMsg = [response cStringUsingEncoding:NSUTF8StringEncoding];
            send(clientSocket, responseMsg, strlen(responseMsg), 0);
            
            // 如果客户端发送"exit"，则关闭连接
            if ([receivedMessage isEqualToString:@"exit"]) {
                break;
            }
        }
    }
    
    NSLog(@"客户端断开连接");
    close(clientSocket);
}

- (void)stopServer {
    _isRunning = NO;
    if (_serverSocket != -1) {
        close(_serverSocket);
        _serverSocket = -1;
    }
    NSLog(@"TCP服务端已停止");
}

- (void)sendMessage:(NSString*)msg {
    if (self.clientSocket < 0) {
        NSLog(@"clientSocket invalid");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        char buffer[1024] = {0};
        ssize_t bytesRead;
        
        send(self.clientSocket, msg.UTF8String, strlen(msg.UTF8String), 0);
        recv(self.clientSocket, buffer, sizeof(buffer) - 1, 0);
        
        NSLog(@"recv server msg:%s", buffer);
    });
}

- (void)dealloc {
    [self stopServer];
}

@end

// main.m - 测试程序
//int main(int argc, const char * argv[]) {
//    @autoreleasepool {
//        TCPServer *server = [[TCPServer alloc] init];
//
//        // 设置信号处理，确保程序退出时清理资源
//        signal(SIGINT, SIG_DFL);
//        signal(SIGTERM, SIG_DFL);
//
//        NSLog(@"启动OC TCP服务端...");
//        [server startServerOnPort:8080]; // 监听8080端口
//
//        // 保持程序运行
//        NSLog(@"按Ctrl+C停止服务端...");
//        [[NSRunLoop currentRunLoop] run];
//    }
//    return 0;
//}
