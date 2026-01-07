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
        LoggerManager.Instance.InfoLog($"Taoism start");
    }
}