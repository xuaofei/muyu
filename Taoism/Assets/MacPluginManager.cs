using System.Runtime.InteropServices; // 必须引入此命名空间
using UnityEngine;

public class MacPluginManager : MonoBehaviour
{
    // 使用DllImport属性导入Objective-C函数
    // "__Internal" 指代当前加载的本地库（即你的插件）
// #if UNITY_STANDALONE_OSX
    [DllImport("__Internal")]
    private static extern void ShowMacDialog(string title, string message);
// #endif

    void Start()
    {
        // 示例：在游戏启动时调用
        // ShowDialog("Hello from Unity!", "This is a native macOS dialog!");
        Debug.Log("ShowDialog");
    }

    public void ShowDialog(string title, string message)
    {
        ShowMacDialog(title, message);
        // 使用预处理指令，确保只在macOS平台下调用原生代码
#if UNITY_STANDALONE_OSX && !UNITY_EDITOR // 在编辑器中通常不运行原生插件
        
#else
        // Debug.Log($"模拟对话框: {title} - {message}");
        #endif
    }
}