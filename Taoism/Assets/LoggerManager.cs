using Microsoft.Extensions.Logging;
using ZLogger;
using UnityEngine;
using System;
using System.IO;
using System.Collections;
using Cysharp.Text; // 添加这行
using System.Text.Json;

public class LoggerManager : MonoBehaviour
{
    public static LoggerManager Instance { get; private set; }
    public static ILogger<LoggerManager> Logger { get; private set; }

    private const int LogRetentionDays = 7;
    private const float CleanupIntervalSeconds = 24f * 60f * 60f; // 每24小时清理一次

    private string _logDir;
    private Coroutine _cleanupCoroutine;

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

        // 准备日志目录
        _logDir = Path.Combine(Application.persistentDataPath, "logs");
        Directory.CreateDirectory(_logDir);

        // 启动时先清一次旧日志（最多保留最近7天）
        CleanupOldLogs(_logDir, LogRetentionDays);

        // 运行中每24小时自动清一次
        _cleanupCoroutine = StartCoroutine(IntervalCleanupCoroutine());

        // 初始化日志系统
        var loggerFactory = Microsoft.Extensions.Logging.LoggerFactory.Create(builder =>
        {
            builder.ClearProviders();
            builder.SetMinimumLevel(LogLevel.Debug);
            builder.AddZLoggerRollingFile(
                fileNameSelector: (dt, x) => Path.Combine(_logDir, $"{dt.ToLocalTime():yyyy-MM-dd}_{x:000}.log"),
                timestampPattern: x => x.ToLocalTime().Date,
                rollSizeKB: 1024
            );
        });

        Logger = loggerFactory.CreateLogger<LoggerManager>();
    }

    private IEnumerator IntervalCleanupCoroutine()
    {
        while (true)
        {
            yield return new WaitForSecondsRealtime(CleanupIntervalSeconds);
            CleanupOldLogs(_logDir, LogRetentionDays);
        }
    }

    private static void CleanupOldLogs(string logDir, int retentionDays)
    {
        if (retentionDays <= 0) return;
        if (!Directory.Exists(logDir)) return;

        // 保留最近 retentionDays 天（含今天）
        var keepFromDate = DateTime.Today.AddDays(-(retentionDays - 1));

        foreach (var file in Directory.EnumerateFiles(logDir, "*.log", SearchOption.TopDirectoryOnly))
        {
            try
            {
                var lastWriteDate = File.GetLastWriteTime(file).Date;
                if (lastWriteDate < keepFromDate)
                {
                    File.Delete(file);
                }
            }
            catch (Exception e)
            {
                Debug.LogWarning($"[LoggerManager] Failed to delete old log: {file}, {e.Message}");
            }
        }
    }

    void OnApplicationQuit()
    {
        if (_cleanupCoroutine != null)
        {
            StopCoroutine(_cleanupCoroutine);
            _cleanupCoroutine = null;
        }

        // 在应用退出时清理资源（如果你后续需要 Dispose loggerFactory，可在这里补上）
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

        LoggerManager.Instance.InfoLog(logMessage);
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
