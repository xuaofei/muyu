using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// Hides the native cursor and drives a UI Image so the pointer can be skinned.
/// Attach this to the Image that should behave like the cursor and assign sprites in the inspector.
/// </summary>
// [RequireComponent(typeof(Image))]
public class CustomCursorController : MonoBehaviour
{
    public static CustomCursorController Instance { get; private set; }
    //[Header("Sprites")]
    [SerializeField] private Texture2D defaultSprite;
    [SerializeField] private Texture2D pressedSprite;

    [SerializeField] private Texture2D normalSprite;
    [SerializeField] private Texture2D tapSprite;

    private int cursorUpWidth;
    private int cursorUpHeight;
    private int cursorDownWidth;
    private int cursorDownHeight;
    Vector2 normalHotspot;
    Vector2 tapHotspot;


    private float timer = 0f;
    private float interval = 0.5f; // 500毫秒即0.5秒

    private void Awake()
    {
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

    private void Start()
    {
        //changeCursorSize(900);
        Debug.Log("xaflog width:" + normalSprite.width);
        Debug.Log("xaflog height:" + normalSprite.height);
        
        //Cursor.SetCursor(normalSprite, normalHotspot, CursorMode.Auto);
        //Cursor.visible = true;
    }

    private void Update()
    {

        // 累加时间
        timer += Time.deltaTime;

        // 检查是否达到间隔时间
        if (timer >= interval)
        {
            // 重置计时器
            timer = 0f;

            // 获取鼠标位置并打印
            Vector3 mousePos = Input.mousePosition;
            Debug.Log("xaflog Mouse Position: " + mousePos);
        }


        Vector3 mousePosition = Input.mousePosition;

        // Debug.Log("xaflog cursorUpRect.position x:" + cursorUpRect.position.x);
        // Debug.Log("xaflog cursorUpRect.position y:" + cursorUpRect.position.y);
        // Debug.Log("xaflog cursorUpRect.position z:"+ cursorUpRect.position.z);

        if (pressedSprite == null || normalSprite == null)
        {
            return;
        }
        // return;
        bool isPressed = Input.GetMouseButton(0);
        //Cursor.SetCursor();
    }

    public void OnCursorUp()
    {
        Debug.Log("xaflog OnCursorUp");
        //Cursor.SetCursor(normalSprite, normalHotspot, CursorMode.Auto);
    }

    public void OnCursorDown()
    { 
        Debug.Log("xaflog OnCursorDown");
        //Cursor.SetCursor(tapSprite, tapHotspot, CursorMode.Auto);
    }

    public void changeCursorSize(int width)
    {

        Debug.Log("xaflog CustomCursorController changeCursorSize Screen.width：" + width);
        if (width == 500)
        {
            cursorUpWidth = 9;
            cursorUpHeight = 34;
            cursorDownWidth = 7;
            cursorDownHeight = 38;

        }
        else if (width == 700)
        {
            cursorUpWidth = 13;
            cursorUpHeight = 48;
            cursorDownWidth = 10;
            cursorDownHeight = 56;
            Debug.Log("Screen.width == 350");
        }
        else if (width == 900)
        {
            cursorUpWidth = 16;
            cursorUpHeight = 62;
            cursorDownWidth = 13;
            cursorDownHeight = 72;
            Debug.Log("Screen.width == 450");
        }


        //cursorUpWidth = (int)(cursorUpWidth * 2);
        //cursorUpHeight = (int)(cursorUpHeight * 2);
        //cursorDownWidth = cursorDownWidth *2;
        //cursorDownHeight = cursorDownHeight *2;

        normalSprite = ScaleTextureGPU(defaultSprite, cursorUpWidth, cursorUpHeight);
        tapSprite = ScaleTextureGPU(pressedSprite, cursorDownWidth, cursorDownHeight);

        normalHotspot = new Vector2(cursorUpWidth / 2, cursorUpHeight / 2);
        tapHotspot = new Vector2(cursorDownWidth / 2, cursorDownHeight / 4);

        Debug.Log("xaflog Start cursorUpWidth: " + cursorUpWidth);
        Debug.Log("xaflog Start cursorUpHeight: " + cursorUpHeight);
        Debug.Log("xaflog Start cursorDownWidth: " + cursorDownWidth);
        Debug.Log("xaflog Start cursorDownHeight: " + cursorDownHeight);

        //// 假设 yourTexture2D 是你的 Texture2D 对象
        //defaultSprite = Sprite.Create(currentNormalCursor,
        //                        new Rect(0, 0, currentNormalCursor.width, currentNormalCursor.height),
        //                        new Vector2(0.5f, 0.5f)); // 轴心点设为精灵中心

        //int diff = (int)(currentTapCursor.height * 0.2f);
        //diff = 0;
        //pressedSprite = Sprite.Create(currentTapCursor,
        //    new Rect(0, diff, currentTapCursor.width, currentTapCursor.height - diff),
        //    new Vector2(0.5f, 0.5f)); // 轴心点设为精灵中心


        //cursorUpImage.sprite = defaultSprite;
        //cursorUpImage.rectTransform.sizeDelta = new Vector2(defaultSprite.texture.width, defaultSprite.texture.height);
        //// cursorUpImage.sprite = newNormalCursor;


        //cursorDownImage.sprite = pressedSprite;
        //cursorDownImage.rectTransform.sizeDelta = new Vector2(pressedSprite.texture.width, pressedSprite.texture.height);
    }
    

    public static Texture2D ScaleTextureGPU(Texture2D sourceTexture, int scaledWidth, int scaledHeight)
    {
        // 创建临时RenderTexture
        RenderTexture renderTexture = RenderTexture.GetTemporary(scaledWidth, scaledHeight, 0);
        // 设置当前活动的RenderTexture
        RenderTexture.active = renderTexture;
        // 使用Graphics.Blit将源纹理拷贝到RenderTexture，并进行缩放
        Graphics.Blit(sourceTexture, renderTexture);

        // 创建新的Texture2D来接收结果
        Texture2D scaledTexture = new Texture2D(scaledWidth, scaledHeight);
        // 从RenderTexture中读取像素
        scaledTexture.ReadPixels(new Rect(0, 0, scaledWidth, scaledHeight), 0, 0);
        scaledTexture.Apply();

        // 清理状态，释放临时RenderTexture
        RenderTexture.active = null;
        RenderTexture.ReleaseTemporary(renderTexture);

        return scaledTexture;
    }
}
