

#if !UNITY_EDITOR
using UnityEngine;
using UnityEngine.Rendering;

public class HiddenUnityLogo
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSplashScreen)]
    private static void BeforeSplashScreen()
    {
        // 对于Mac（Standalone）平台，使用异步任务立即停止启动画面
        System.Threading.Tasks.Task.Run(() => 
        {
            SplashScreen.Stop(SplashScreen.StopBehavior.StopImmediate);
        });
    }
}
#endif
