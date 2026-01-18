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
        // 注册日志回调
        Application.logMessageReceived += HandleLogMessage;

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
            builder.AddZLoggerRollingFile(
                // 将文件名选择器修改为使用持久化数据路径
                fileNameSelector: (dt, x) => $"{Application.persistentDataPath}/logs/{dt.ToLocalTime():yyyy-MM-dd}_{x:000}.log", 
                timestampPattern: x => x.ToLocalTime().Date, 
                rollSizeKB: 1024
            );
        });

        Logger = loggerFactory.CreateLogger<LoggerManager>();
    }

    private string ExtractFirstUserFrame(string stackTrace)
    {
        if (string.IsNullOrWhiteSpace(stackTrace))
            return "(no stacktrace - check StackTraceLogType/PlayerSettings)";
        var lines = stackTrace.Split('\n');
        foreach (var raw in lines)
        {
            var line = raw.Trim();
            if (line.Length == 0) continue;
            // 过滤 Unity 内部栈帧（按需增减）
            if (line.Contains("UnityEngine.Debug") ||
                line.Contains("UnityEngine.Logger") ||
                line.Contains("UnityEngine.Application:CallLogCallback") ||
                line.Contains("Application.CallLogCallback"))
                continue;
            return line;
        }
        return lines[0].Trim();
    }

    private void HandleLogMessage(string logString, string stackTrace, LogType type)
    {
        var callerLine = ExtractFirstUserFrame(stackTrace);
        // 你可以把 callerLine 写进文件/上报
        // callerLine 常见格式：MyClass:Foo() (at Assets/Scripts/MyClass.cs:42)
        //UnityEngine.Debug.Log($"[{type}] {condition}\nCaller: {callerLine}");

        InfoLog(callerLine + logString);

        //if (type == LogType.Error || type == LogType.Exception)
        //{
        //    ErrorLog(stackTrace);
        //}
    }

    void OnDestroy()
    {
        // 程序结束时，注销回调并关闭文件流
        Application.logMessageReceived -= HandleLogMessage;
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