
using Spine;
using Spine.Unity;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FoguangController : MonoBehaviour
{
    SkeletonAnimation skeletonAnimation;
    private string animationNameGuang01 = "guang01";
    private string animationNameGuang02 = "guang02";
    private TrackEntry trackEntryFoguang;
    private bool isKnockCompleted = false;
    void Start()
    {
        EventCenter.OnMuyuKnocked += MuyuKnocked;
        EventCenter.OnKnockCompleted += KnockCompleted;
        skeletonAnimation = GetComponent<SkeletonAnimation>();
        // skeletonAnimation.Initialize(true);

        // skeletonAnimation.skeleton.SetToSetupPose();
        // skeletonAnimation.AnimationState.ClearTracks();

        trackEntryFoguang = skeletonAnimation.AnimationState.SetAnimation(0, animationNameGuang01, false);
        // trackEntryFoxiang = skeletonAnimation.AnimationState.SetAnimation(1, animationNameFoXiang, false);
        // trackEntryMuyu = skeletonAnimation.AnimationState.SetAnimation(2, animationNameMuYu01, false);

        // trackEntry1.AnimationEnd = 1.0f;
        // skeletonAnimation.timeScale = 0.0f;
        // trackEntry1.TimeScale = 0.2f;
        // totalDuration = trackEntryFoguang.AnimationEnd;
        Debug.Log("TaoismController trackEntryFoguang：" + trackEntryFoguang.AnimationEnd);
        // Debug.Log("TaoismController trackEntryMuyu：" + trackEntryMuyu.AnimationEnd);

        skeletonAnimation.AnimationState.Complete += OnAnimationComplete;
    }

    // Update is called once per frame
    void Update()
    {
        if (isKnockCompleted)
        {
            isKnockCompleted = false;
            float currentAnimationTime = trackEntryFoguang.TrackTime;
            // 1. 可选的清理操作：清除当前状态，避免切换残影
            // skeletonAnimation.skeleton.SetToSetupPose();
            // skeletonAnimation.AnimationState.ClearTracks();

            // skeletonAnimation.AnimationState.ClearTrack(1);
            skeletonAnimation.AnimationState.SetEmptyAnimation(0, 0);
            trackEntryFoguang = skeletonAnimation.AnimationState.SetAnimation(0, animationNameGuang01, false);
            trackEntryFoguang.TrackTime = currentAnimationTime;
            trackEntryFoguang.MixDuration = 0.1f;
        }
    }

    void OnAnimationComplete(TrackEntry entry)
    {
        if (entry.Animation.Name == animationNameGuang01)
        {
            trackEntryFoguang = skeletonAnimation.AnimationState.SetAnimation(0, entry.Animation.Name, false);
        }
        else if (entry.Animation.Name == animationNameGuang02)
        {
            trackEntryFoguang = skeletonAnimation.AnimationState.SetAnimation(0, entry.Animation.Name, false);
        }

        Debug.LogWarning("OnAnimationComplete:" + entry.Animation.Name);
    }

    // 点击后播放动画的方法
    public void PlayAnimationOnClick()
    {
        float currentAnimationTime = trackEntryFoguang.TrackTime;

        // 1. 可选的清理操作：清除当前状态，避免切换残影
        // skeletonAnimation.skeleton.SetToSetupPose();
        // skeletonAnimation.AnimationState.ClearTracks();

        // 2. 在轨道0上设置动画B，并设置为循环播放

        skeletonAnimation.AnimationState.SetEmptyAnimation(0, 0);
        trackEntryFoguang = skeletonAnimation.AnimationState.SetAnimation(0, animationNameGuang02, false);

        // 3. 关键步骤：设置动画B的起始时间为动画A的当前时间
        trackEntryFoguang.TrackTime = currentAnimationTime;
        // skeletonAnimation.skeleton.UpdateWorldTransform();

        // 4. 如果你希望切换瞬间完成，不包含混合过渡，可以设置混合时间为0
        trackEntryFoguang.MixDuration = 0.1f;
    }

    public void MuyuKnocked()
    {
        // 
        Debug.Log("FoguangController MuyuKnocked");
        PlayAnimationOnClick();
    }

    public void KnockCompleted()
    {
        isKnockCompleted = true;
        Debug.Log("FoguangController KnockCompleted");
    }
}
