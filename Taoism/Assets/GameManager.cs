using UnityEngine;
using UnityEngine.Audio; // 需要引入此命名空间
using System.Threading;
using System.Threading.Tasks;

public class GameManager : MonoBehaviour
{
    // 静态实例引用和公开访问点
    public static GameManager Instance { get; private set; }
    public AudioMixer mainMixer;
    public Camera mainCamera;
    public float mainCameraOrthographicSize;

    private void Awake()
    {
        Screen.SetResolution(900, 900, false);
        
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
    }

    void Start()
    {
        mainCameraOrthographicSize = mainCamera.orthographicSize;
        Application.targetFrameRate = 30;
        Debug.Log("targetFrameRate:" + Application.targetFrameRate);
        Debug.Log(Application.persistentDataPath);

        LoggerManager.Instance.InfoLog($"");
        LoggerManager.Instance.InfoLog($"");
        LoggerManager.Instance.InfoLog($"Taoism start");
    }

    public void ChangeScreen(int size)
    {
        Debug.Log("xaflog enter ChangeScreen 0：" + Thread.CurrentThread.ManagedThreadId);
        Screen.SetResolution(size, size, false);
        Debug.Log("xaflog enter ChangeScreen 1：" + Thread.CurrentThread.ManagedThreadId);

        CustomCursorController.Instance.changeCursorSize(size);
    }
}