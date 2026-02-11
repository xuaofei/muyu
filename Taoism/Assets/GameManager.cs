using System;
using System.Runtime.InteropServices;
using System.Text;
using UnityEngine;
using UnityEngine.Audio; // 需要引入此命名空间

public class GameManager : MonoBehaviour
{
    // 静态实例引用和公开访问点
    public static GameManager Instance { get; private set; }
    public AudioMixer mainMixer;
    public Camera mainCamera;
    public float mainCameraOrthographicSize;

#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
    private delegate void UnityCallback(IntPtr utf8);
    private static UnityCallback unityCallback; // 必须静态持有，防止被 GC 回收
    [DllImport("unityPlugin")]
    private static extern void SetUnityMsgCallback(UnityCallback cb);
    [DllImport("unityPlugin")]
    private static extern void UnityStartd();
#endif

    private void Awake()
    {
        // 确保实例唯一性
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject); // 可选：跨场景不销毁
        }
        else
        {
            Destroy(gameObject);
        }

#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
        UnityStartd();
        unityCallback = OnMsgFromOC;
        SetUnityMsgCallback(unityCallback);
#endif
    }

    void Start()
    {
        mainCameraOrthographicSize = mainCamera.orthographicSize;
        Application.targetFrameRate = 60;
        
        LoggerManager.Instance.InfoLog("Taoism start targetFrameRate:" + Application.targetFrameRate);
    }

    private static string PtrToStringUtf8(IntPtr p)
    {
        if (p == IntPtr.Zero) return "";
        int len = 0;
        while (Marshal.ReadByte(p, len) != 0) len++;
        var bytes = new byte[len];
        Marshal.Copy(p, bytes, 0, len);
        return Encoding.UTF8.GetString(bytes);
    }

    private static void OnMsgFromOC(IntPtr p)
    {
        // 注意：可能来自非主线程，这里不要直接调用 Unity API
        var msg = PtrToStringUtf8(p);
        LoggerManager.Instance.InfoLog("OnMsgFromOC:" + msg);

        if (msg == "Mute")
        {
            GameManager.Instance.SetMute(true);
        }
        else if (msg == "Unmute")
        {
            GameManager.Instance.SetMute(false);
        }
        else if (msg == "Pray")
        {
            XiangluController.Instance.gameObject.SetActive(true);
            XiangluController.Instance.ResetAnimation();
            
            MuyuController.Instance.gameObject.SetActive(false);
            MuyuController.Instance.enabled = false;
        }
        else if (msg == "ShowMuyu")
        {
            XiangluController.Instance.gameObject.SetActive(false);
            MuyuController.Instance.gameObject.SetActive(true);
            MuyuController.Instance.enabled = true;
        }
    }

    public void SetMute(bool mute)
    {
        AudioListener.volume = mute ? 0f : 1f;
    }
}