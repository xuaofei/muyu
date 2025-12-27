using Microsoft.Extensions.Logging;
using ZLogger;
using UnityEngine;
using System;
using System.IO;
using Cysharp.Text; // 添加这行
using System.Text.Json;

public class LoggerManager : MonoBehaviour
{
    public static LoggerManager Instance { get; private set; }
    public static ILogger<LoggerManager> Logger { get; private set; }

    void Awake()
    {
        // 单例保护：确保只有一个实例存在
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        
        Instance = this;
        DontDestroyOnLoad(gameObject); // 防止场景切换时被销毁
        
        // 初始化日志系统
        var loggerFactory = Microsoft.Extensions.Logging.LoggerFactory.Create(builder =>
        {
            builder.ClearProviders();
            builder.SetMinimumLevel(LogLevel.Debug);

            // builder.AddZLoggerConsole(options =>
            // {
            //     options.EnableStructuredLogging = true;
            //     options.PrefixFormatter = (writer, info) => ZString.Utf8Format(writer, "[{0}][{1}]", info.LogLevel, info.Timestamp.DateTime.ToLocalTime());

            //     // Tips: use PrepareUtf8 to achive better performance.
            //     var prefixFormat = ZString.PrepareUtf8<LogLevel, DateTime>("[{0}][{1}]");
            //     options.PrefixFormatter = (writer, info) => prefixFormat.FormatTo(ref writer, info.LogLevel, info.Timestamp.DateTime.ToLocalTime());
            // });


            builder.AddZLoggerRollingFile(
                // 将文件名选择器修改为使用持久化数据路径
                fileNameSelector: (dt, x) => $"{Application.persistentDataPath}/logs/{dt.ToLocalTime():yyyy-MM-dd}_{x:000}.log", 
                timestampPattern: x => x.ToLocalTime().Date, 
                rollSizeKB: 1024
            );
        });

        Logger = loggerFactory.CreateLogger<LoggerManager>();
    }

    void OnApplicationQuit()
    {
        // 在应用退出时清理资源
        if (Logger != null)
        {
            // var loggerFactory = Logger.Factory;
            // Logger = null;
            // loggerFactory?.Dispose();
        }
    }

    public void InfoLog(
        string message,
        [System.Runtime.CompilerServices.CallerMemberName] string memberName = "",
        [System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "",
        [System.Runtime.CompilerServices.CallerLineNumber] int sourceLineNumber = 0)
    {
        // 获取当前时间，并格式化为包含毫秒的字符串
        string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
        // 组合最终的日志信息
        var logMessage = $"[{timestamp}] [Info] [{System.IO.Path.GetFileName(sourceFilePath)}:{sourceLineNumber}] [{memberName}] {message}";
        Logger?.ZLogInformation(logMessage);
    }


    public void DebugLog(
    string message,
    [System.Runtime.CompilerServices.CallerMemberName] string memberName = "",
    [System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "",
    [System.Runtime.CompilerServices.CallerLineNumber] int sourceLineNumber = 0)
    {
        // 获取当前时间，并格式化为包含毫秒的字符串
        string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
        // 组合最终的日志信息
        var logMessage = $"[{timestamp}] [Debug] [{System.IO.Path.GetFileName(sourceFilePath)}:{sourceLineNumber}] [{memberName}] {message}";
        Logger?.ZLogDebug(logMessage);
    }

    public void ErrorLog(
    string message,
    [System.Runtime.CompilerServices.CallerMemberName] string memberName = "",
    [System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "",
    [System.Runtime.CompilerServices.CallerLineNumber] int sourceLineNumber = 0)
    {
        // 获取当前时间，并格式化为包含毫秒的字符串
        string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
        // 组合最终的日志信息
        var logMessage = $"[{timestamp}] [Error] [{System.IO.Path.GetFileName(sourceFilePath)}:{sourceLineNumber}] [{memberName}] {message}";
        Logger?.ZLogError(logMessage);
    }

    public void WarningLog(
    string message,
    [System.Runtime.CompilerServices.CallerMemberName] string memberName = "",
    [System.Runtime.CompilerServices.CallerFilePath] string sourceFilePath = "",
    [System.Runtime.CompilerServices.CallerLineNumber] int sourceLineNumber = 0)
    {
        // 获取当前时间，并格式化为包含毫秒的字符串
        string timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff");
        // 组合最终的日志信息
        var logMessage = $"[{timestamp}] [Warn] [{System.IO.Path.GetFileName(sourceFilePath)}:{sourceLineNumber}] [{memberName}] {message}";
        Logger?.ZLogWarning(logMessage);
    }
}