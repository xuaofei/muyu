using UnityEngine;
using System.IO;
using System;

public class LogHelper : MonoBehaviour
{
    private StreamWriter logWriter;
    private string logFilePath;

    void Awake()
    {
        // 定义日志文件路径，位于持久化数据目录
        string directory = Path.Combine(Application.persistentDataPath, "MyGameLogs");
        Directory.CreateDirectory(directory); // 确保目录存在
        logFilePath = Path.Combine(directory, "game_log.txt");
        
        // 创建日志文件
        logWriter = new StreamWriter(logFilePath, append: true);
        logWriter.AutoFlush = true;
        
        // 注册日志回调
        Application.logMessageReceived += HandleLogMessage;
        
        Debug.Log("自定义日志系统已启动，路径: " + logFilePath);
    }

    private void HandleLogMessage(string logString, string stackTrace, LogType type)
    {
        // 将日志信息写入文件
        string formattedLog = $"[{DateTime.Now}] [{type}] {logString}";
        logWriter.WriteLine(formattedLog);
        
        if (type == LogType.Error || type == LogType.Exception)
        {
            logWriter.WriteLine(stackTrace); // 对于错误和异常，记录堆栈跟踪
        }
    }

    void OnDestroy()
    {
        // 程序结束时，注销回调并关闭文件流
        Application.logMessageReceived -= HandleLogMessage;
        logWriter?.Close();
    }
}