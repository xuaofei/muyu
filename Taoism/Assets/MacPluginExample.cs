using System.Runtime.InteropServices;
using UnityEditor;
using UnityEngine;

public class MacPluginExample : MonoBehaviour
{
    // 使用平台编译指令，确保只在macOS平台编译和调用此代码
#if UNITY_STANDALONE_OSX
    [DllImport("unityPlugin")]
    private static extern void StartNotifyListener();
    [DllImport("unityPlugin")]
    private static extern void StartScreenManager();
    [DllImport("unityPlugin")]
    private static extern void UnityStartd();
#endif
    void Start()
    {
        // 调用原生方法
        CallNativeFunction();
        
        Debug.Log("xaflog MacPluginExampleMacPluginExample");
    }

    void Update()
    {
        //CallNativeFunction();
    }



    public void CallNativeFunction()
    {
        Debug.Log("xaflog CallNativeFunction");
#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
        StartNotifyListener();
        StartScreenManager();
        UnityStartd();
#else
        Debug.Log("当前平台不支持调用此原生功能");
#endif
    }
}