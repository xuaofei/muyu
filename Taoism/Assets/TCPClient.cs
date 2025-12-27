using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Net.Sockets;
using System.Text;
// using System.Text.Json.Nodes;
// using System.Text.Json;
// 如果使用了 JsonDocument 等 DOM 类型，可能还需要
// using System.Text.Json.Serialization;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;


public class TCPClient : MonoBehaviour
{
    private TcpClient _client;
    private NetworkStream _stream;
    private bool _isConnected = false;
    private readonly string _serverIP;
    private readonly int _serverPort;

    static private GameManager _gameManager; // 声明一个私有变量来保存引用
    static private GameObject gameObjectX;

    private static SynchronizationContext _unityContext;

    public TCPClient(string serverIP, int serverPort)
    {
        _serverIP = serverIP;
        _serverPort = serverPort;
    }

    void Awake()
    {
        // 在主线程中捕获同步上下文
        _unityContext = SynchronizationContext.Current;
    }

    void Start()
    {
        // _gameManager = GetComponent<GameManager>();
        gameObjectX = gameObject;
        _gameManager = GetComponent<GameManager>();
        if (_gameManager)
        {
            Debug.Log("xaflog gameMgr ok");
        }
        else
        {
            Debug.Log("xaflog gameMgr false");
        }
        

        Task.Run(async () => await connectTcp());
        // connectTcp();
    }
    public async Task connectTcp()
    {
        Debug.Log("xaflog connectTcp");
        TCPClient client = new TCPClient("127.0.0.1", 56887); // 连接到本地OC服务端
        
        Debug.Log("xaflog connectTcp2");
        Debug.Log("C# TCP客户端启动");
        Debug.Log("正在连接服务器...");

        if (await client.ConnectAsync())
        {
            Debug.Log("连接成功! 输入消息发送给服务器，输入 'exit' 退出");
            
            // 消息发送循环
            while (client.IsConnected)
            {
                string input = Console.ReadLine();
                
                if (string.IsNullOrEmpty(input))
                    continue;
                    
                if (input.ToLower() == "exit")
                {
                    await client.SendMessageAsync("exit");
                    break;
                }
                
                await client.SendMessageAsync(input);
                
                // 短暂延迟避免过快发送
                await Task.Delay(100);
            }
        }
        
        // client.Disconnect();
        // Debug.Log("按任意键退出...");
        // Console.ReadKey();

        return;
    }

    public async Task<bool> ConnectAsync()
    {
        try
        {
            _client = new TcpClient();
            await _client.ConnectAsync(_serverIP, _serverPort);
            _stream = _client.GetStream();
            _isConnected = true;
            
            Debug.Log($"已连接到服务器 {_serverIP}:{_serverPort}");
            
            // 启动接收消息的任务
            _ = Task.Run(ReceiveMessagesAsync);
            
            return true;
        }
        catch (Exception ex)
        {
            Debug.Log($"连接失败: {ex.Message}");
            return false;
        }
    }

    public async Task SendMessageAsync(string message)
    {
        if (!_isConnected || _stream == null)
        {
            Debug.Log("未连接到服务器");
            return;
        }

        try
        {
            byte[] data = Encoding.UTF8.GetBytes(message + "\n");
            await _stream.WriteAsync(data, 0, data.Length);
            Debug.Log($"发送消息: {message}");
        }
        catch (Exception ex)
        {
            Debug.Log($"发送消息失败: {ex.Message}");
            Disconnect();
        }
    }

    private async Task ReceiveMessagesAsync()
    {
        byte[] buffer = new byte[1024];
        
        while (_isConnected && _stream != null)
        {
            try
            {
                int bytesRead = await _stream.ReadAsync(buffer, 0, buffer.Length);
                if (bytesRead == 0)
                {
                    // 连接已关闭
                    Debug.Log("服务器断开连接");
                    Disconnect();
                    break;
                }

                string receivedMessage = Encoding.UTF8.GetString(buffer, 0, bytesRead);
                Debug.Log($"收到服务器回复: {receivedMessage.Trim()}");
                SendMessageAsync("回复：" + receivedMessage);


                JObject jsonObj = JObject.Parse(receivedMessage);
                string screenSize = (string)jsonObj["screenSize"]; // 这样就不会报错了

                int number = int.Parse(screenSize);
                Console.WriteLine(number); // 输出：789

                // JsonNode node = JsonNode.Parse(receivedMessage)!;
                // string screenSize = node["data"]!.GetValue<string>(); // 使用 GetValue<T>
                Debug.Log("xaflog call screenSize 0：" + number);
                // Screen.SetResolution(1900, 1900, false);

                if (number == 999)
                {
                    // Disconnect();
                    // Application.Quit();
                }
                else
                {
                    _unityContext?.Post(_ =>
                    {
                        // 这个代码块会在主线程执行
                        Debug.Log("xaflog call ChangeScreen 0：" + Thread.CurrentThread.ManagedThreadId);
                        GameManager.Instance.ChangeScreen(number);
                        Debug.Log("xaflog call ChangeScreen 1：" + Thread.CurrentThread.ManagedThreadId);
                    }, null);
                }

        
                // 2. 发送带一个参数的消息

                // if (gameObjectX)
                // {
                //     gameObjectX.SendMessage("ChangeScreen", 300);
                // }
                // else
                // {
                //     Debug.Log("xaflog call ChangeScreen no");
                // }
                    // _gameManager.send("", "ChangeScreen", "");

                
            }
            catch (Exception ex)
            {
                if (_isConnected) // 只在仍然连接时报告错误
                {
                    Debug.Log($"xaflog 接收消息错误: {ex.Message}");
                }
                break;
            }
        }
    }

    public void Disconnect()
    {
        _isConnected = false;
        _stream?.Close();
        _client?.Close();
        Debug.Log("已断开连接");
    }

    public bool IsConnected => _isConnected;
}

// // 主程序
// class Program
// {
//     static async Task Main(string[] args)
//     {
//         TCPClient client = new TCPClient("127.0.0.1", 8080); // 连接到本地OC服务端
        
//         Debug.Log("C# TCP客户端启动");
//         Debug.Log("正在连接服务器...");

//         if (await client.ConnectAsync())
//         {
//             Debug.Log("连接成功! 输入消息发送给服务器，输入 'exit' 退出");
            
//             // 消息发送循环
//             while (client.IsConnected)
//             {
//                 string input = Console.ReadLine();
                
//                 if (string.IsNullOrEmpty(input))
//                     continue;
                    
//                 if (input.ToLower() == "exit")
//                 {
//                     await client.SendMessageAsync("exit");
//                     break;
//                 }
                
//                 await client.SendMessageAsync(input);
                
//                 // 短暂延迟避免过快发送
//                 await Task.Delay(100);
//             }
//         }
        
//         client.Disconnect();
//         Debug.Log("按任意键退出...");
//         Console.ReadKey();
//     }
// }
