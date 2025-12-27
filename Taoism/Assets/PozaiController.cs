
using Spine;
using Spine.Unity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PozaiController : MonoBehaviour
{
    public string attackButton = "Fire1";
    public float jitterX = 10f; // X轴抖动幅度
    public float jitterY = 10f; // Y轴抖动幅度
    SkeletonAnimation skeletonAnimation;

    // Start is called before the first frame update
    void Start()
    {
        
        skeletonAnimation = GetComponent<SkeletonAnimation>();
        if (skeletonAnimation == null)
        {
            // // 初始化顶点效果委托
            // var vertexEffect = new VertexEffectDelegate();
            // vertexEffect.InitJitter(jitterX, jitterY);

            // // 应用效果到Spine组件
            // skeletonAnimation.Skeleton.SetVertexEffect(vertexEffect);

            

            // Spine.Bone targetBone = skeletonAnimation.Skeleton.FindBone("bone_name"); // 替换为骨骼名
        }
        // skeletonAnimation.timeScale = 0.2f;
        TrackEntry trackEntry = skeletonAnimation.AnimationState.SetAnimation(0, "S0", false);
        // skeletonAnimation.AnimationState.TimeScale = 0.1f; // 半速播放
        TrackEntry currentTrack = skeletonAnimation.AnimationState.GetCurrent(0);
        if (currentTrack != null)
        {
            Debug.Log("TaoismController currentTrack");
            currentTrack.TimeScale = 2.0f; // 让这个特定的动画以2倍速播放
        }
        
        // trackEntry.TimeScale = 1/5.0f; // 值越小速度越慢[1,7](@ref)
        skeletonAnimation.AnimationState.Complete += OnAnimationComplete;
        Debug.Log("TaoismController");
    }

    // Update is called once per frame
    void Update()
    {
    

        if (Input.GetButton(attackButton))
        {
            Debug.LogWarning("attackButton");
            // model.TryShoot();
        }


        if (Input.GetButtonDown(attackButton))
        {
            float TimeScale = 1.0f;

            // skeletonAnimation.AnimationState.SetEmptyAnimation(0, 0.3f); // 0.3秒淡出
            TrackEntry trackEntry = skeletonAnimation.AnimationState.SetAnimation(1, "C0", false);
            trackEntry.TimeScale = TimeScale;
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(1, "C1", false);
            // trackEntry.TimeScale = TimeScale;
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(1, "C2", false);
            // trackEntry.TimeScale = TimeScale;
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(1, "C3", false);
            // trackEntry.TimeScale = TimeScale;
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(1, "C4", false);
            // trackEntry.TimeScale = TimeScale;
        }


        // if (Input.GetButtonUp(aimButton)) {

        //     }


        // if (Input.GetButtonDown(jumpButton))
        // {

        //     }

    }

    void OnAnimationComplete(TrackEntry entry)
    {
        Debug.LogWarning("OnAnimationComplete");

        TrackEntry trackEntry;
        float TimeScale = 0.01f;
        if (entry.Animation.Name == "S0")
        {
            // 攻击结束后切回待机
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(0, "S1", false);
            trackEntry.TimeScale = TimeScale;
        }

        else if (entry.Animation.Name == "S1")
        {
            // 攻击结束后切回待机
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(0, "S2", false);
            trackEntry.TimeScale = TimeScale;
        }

        else if (entry.Animation.Name == "S2")
        {
            // 攻击结束后切回待机
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(0, "S3", false);
            trackEntry.TimeScale = TimeScale;
        }

        else if (entry.Animation.Name == "S3")
        {
            // 攻击结束后切回待机
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(0, "S4", false);
            trackEntry.TimeScale = TimeScale;
        }
        
        else if (entry.Animation.Name == "S4")
        {
            // 攻击结束后切回待机
            trackEntry = skeletonAnimation.AnimationState.SetAnimation(0, "S0", false);
            trackEntry.TimeScale = TimeScale;
        }
    }
}
