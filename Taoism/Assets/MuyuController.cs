using Spine;
using Spine.Unity;
using System.Collections;
using System.Runtime.InteropServices;
using UnityEngine;

public class MuyuController : MonoBehaviour
{
    SkeletonAnimation skeletonAnimation;
    public Texture2D normalCursor;
    public Texture2D tapCursor;

    public Texture2D normalCursor250;
    public Texture2D tapCursor250;

    public Texture2D normalCursor350;
    public Texture2D tapCursor350;

    public Texture2D normalCursor450;
    public Texture2D tapCursor450;

    private bool isKnockCompleted = true;

    private string muyuAnimationName = "01";
    private string animationNameMuYu02 = "muyu02";
    private string muyuAudioName = "muyu0_1";

    private AudioSource audioSource;

    private float knockRemainingTime = 0.0f;
    private TrackEntry trackEntryMuyu;

    private int cursorUpWidth;
    private int cursorUpHeight;
    private int cursorDownWidth;
    private int cursorDownHeight;
    Vector2 normalHotspot;
    Vector2 tapHotspot;

    public static MuyuController Instance { get; private set; }

#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
    [DllImport("unityPlugin")]
    private static extern void MouseUp();
    [DllImport("unityPlugin")]
    private static extern void MouseDown();
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
    }

    private void OnApplicationFocus(bool hasFocus)
    {
        if (hasFocus)
        {
            LoggerManager.Instance.InfoLog("游戏窗口获得焦点，恢复正常运行。");
             //changeCursorSize(Screen.width);
        }
        else
        {
            LoggerManager.Instance.InfoLog("游戏窗口失去焦点，可以暂停游戏。");
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        EventCenter.OnMuyuKnocked += MuyuKnocked;
        EventCenter.OnKnockCompleted += KnockCompleted;

        skeletonAnimation = GetComponent<SkeletonAnimation>();

        trackEntryMuyu = skeletonAnimation.AnimationState.SetAnimation(0, animationNameMuYu02, false);
        trackEntryMuyu.TimeScale = 0.0f;
        trackEntryMuyu.AnimationEnd = 2.2f;

        skeletonAnimation.AnimationState.Complete += OnAnimationComplete;

        audioSource = gameObject.AddComponent<AudioSource>();
        audioSource.outputAudioMixerGroup = GameManager.Instance.mainMixer.FindMatchingGroups("Master")[0];

#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
        UnityStartd();
#endif

    }

    // Update is called once per frame
    void Update()
    {
        if (knockRemainingTime > 0.0f)
        {
            knockRemainingTime -= Time.deltaTime;
            if (knockRemainingTime <= 0.0f)
            {
                EventCenter.KnockCompleted();



                 isKnockCompleted = true;
            }
        }
    }

    public void changeCursorSize(int width)
    {
        LoggerManager.Instance.InfoLog("Screen.width：" + width);
        if (width == 500)
        {
            cursorUpWidth = 9;
            cursorUpHeight = 34;
            cursorDownWidth = 7;
            cursorDownHeight = 38;

            normalHotspot = new Vector2(cursorUpWidth / 2, cursorUpHeight / 2);
            tapHotspot = new Vector2(cursorDownWidth / 2, cursorDownHeight / 4);
        }
        else if (width == 700)
        {
            cursorUpWidth = 12;
            cursorUpHeight = 48;
            cursorDownWidth = 10;
            cursorDownHeight = 52;

            normalHotspot = new Vector2(cursorUpWidth / 2, cursorUpHeight / 2);
            tapHotspot = new Vector2(cursorDownWidth / 2, cursorDownHeight / 4);
        }
        else if (width == 900)
        {
            cursorUpWidth = 15;
            cursorUpHeight = 62;
            cursorDownWidth = 14;
            cursorDownHeight = 66;

            normalHotspot = new Vector2(cursorUpWidth / 2, cursorUpHeight / 2);
            tapHotspot = new Vector2(cursorDownWidth / 2 - 2, cursorDownHeight / 4);
        }


        LoggerManager.Instance.InfoLog("Start tapHotspot: " + tapHotspot.ToString());


        if (Screen.width == 500)
        {
            Cursor.SetCursor(normalCursor250, normalHotspot, CursorMode.Auto);
        }
        else if (Screen.width == 700)
        {
            Cursor.SetCursor(normalCursor350, normalHotspot, CursorMode.Auto);
        }
        else if (Screen.width == 900)
        {
            Cursor.SetCursor(normalCursor450, normalHotspot, CursorMode.Auto);
        }

        LoggerManager.Instance.InfoLog("Start cursorUpWidth: " + cursorUpWidth);
        LoggerManager.Instance.InfoLog("Start cursorUpHeight: " + cursorUpHeight);
        LoggerManager.Instance.InfoLog("Start cursorDownWidth: " + cursorDownWidth);
        LoggerManager.Instance.InfoLog("Start cursorDownHeight: " + cursorDownHeight);
    }

    void OnAnimationComplete(TrackEntry entry)
    {
        if (entry.Animation.Name == animationNameMuYu02)
        {
            trackEntryMuyu = skeletonAnimation.AnimationState.SetAnimation(0, entry.Animation.Name, false);
            trackEntryMuyu.TimeScale = 2f/0.7f;
            trackEntryMuyu.AnimationEnd = 2f;
            trackEntryMuyu.MixDuration = 0.2f;
            //Debug.LogWarning("OnAnimationComplete:" + entry.Animation.Name);

            isKnockCompleted = true; // 标记已点击
        }

    }

    // 点击后播放动画的方法
    public void PlayAnimationOnClick()
    {
        float currentAnimationTime = trackEntryMuyu.TrackTime;

        // 1. 可选的清理操作：清除当前状态，避免切换残影
        // skeletonAnimation.skeleton.SetToSetupPose();
        // skeletonAnimation.AnimationState.ClearTracks();

        // 2. 在轨道0上设置动画B，并设置为循环播放

        skeletonAnimation.AnimationState.SetEmptyAnimation(0, 0);
        trackEntryMuyu = skeletonAnimation.AnimationState.SetAnimation(0, animationNameMuYu02, false);

        trackEntryMuyu.TimeScale = 2f/0.7f;
        trackEntryMuyu.AnimationEnd = 2f;

        // 3. 关键步骤：设置动画B的起始时间为动画A的当前时间
        // trackEntryMuyu.TrackTime = currentAnimationTime;
        // skeletonAnimation.skeleton.UpdateWorldTransform();

        // 4. 如果你希望切换瞬间完成，不包含混合过渡，可以设置混合时间为0
        // trackEntryMuyu.MixDuration = 0.1f;
    }

    private void OnMouseUp()
    {
#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
        MouseUp();
#endif
        if (Screen.width == 500)
        {
            Cursor.SetCursor(normalCursor250, normalHotspot, CursorMode.Auto);
        }
        else if (Screen.width == 700)
        {
            Cursor.SetCursor(normalCursor350, normalHotspot, CursorMode.Auto);
        }
        else if (Screen.width == 900)
        {
            Cursor.SetCursor(normalCursor450, normalHotspot, CursorMode.Auto);
        }

        //CustomCursorController.Instance.OnCursorUp();

        LoggerManager.Instance.InfoLog("Screen.width：" + Screen.width);
        LoggerManager.Instance.InfoLog("Screen.height：" + Screen.height);


        LoggerManager.Instance.InfoLog("点击到了: " + gameObject.name);
    }

    private void OnMouseDown()
    {
        changeCursorSize(Screen.width);

        if (!isKnockCompleted)
        {
            return;
        }


#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
        MouseDown();
#endif

        isKnockCompleted = false;

        if (knockRemainingTime <= 0.0f)
        {
            StartCoroutine(DelayCallMuyuKnocked(0.15f));

            // EventCenter.MuyuKnocked();
        }


        // 这里可以写点击后的处理逻辑，如销毁物体、播放动画等
    }

    IEnumerator DelayCallMuyuKnocked(float delaySeconds)
    { 
        if (Screen.width == 500)
        {
            Cursor.SetCursor(tapCursor250, tapHotspot, CursorMode.Auto);
        }
        else if (Screen.width == 700)
        {
            Cursor.SetCursor(tapCursor350, tapHotspot, CursorMode.Auto);
        }
        else if (Screen.width == 900)
        {
            Cursor.SetCursor(tapCursor450, tapHotspot, CursorMode.Auto);
        }

        yield return new WaitForSeconds(delaySeconds);
        knockRemainingTime = 0.7f;
        EventCenter.MuyuKnocked();
    }

    public void PlaySoundByName()
    {
        // 从Resources文件夹加载音频
        AudioClip clip = Resources.Load<AudioClip>(muyuAudioName);
        if (clip != null)
        {
            audioSource.clip = clip;
            audioSource.Play();
        }
        else
        {
            Debug.LogError("音频文件未找到: " + muyuAudioName);
        }
    }

    public void MuyuKnocked()
    {
        LoggerManager.Instance.InfoLog("MuyuController MuyuKnocked");
        PlayAnimationOnClick();
        PlaySoundByName();
    }

    public void KnockCompleted()
    {
        LoggerManager.Instance.InfoLog("MuyuController KnockCompleted");

        float currentAnimationTime = trackEntryMuyu.TrackTime;
        // 1. 可选的清理操作：清除当前状态，避免切换残影
        // skeletonAnimation.skeleton.SetToSetupPose();
        // skeletonAnimation.AnimationState.ClearTracks();

        // skeletonAnimation.AnimationState.ClearTrack(1);
        skeletonAnimation.AnimationState.SetEmptyAnimation(0, 0);
        trackEntryMuyu = skeletonAnimation.AnimationState.SetAnimation(0, animationNameMuYu02, false);
        trackEntryMuyu.TimeScale = 0.0f;
        // trackEntryMuyu.AnimationEnd = 3.3667f;
        trackEntryMuyu.TrackTime = 0.0f;
        // trackEntryMuyu.MixDuration = 0.1f;
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
