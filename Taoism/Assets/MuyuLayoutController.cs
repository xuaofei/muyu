using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 事件中心管理器
public class EventCenter : MonoBehaviour
{
    // 定义委托和事件
    public delegate void EventHandler();
    public static event EventHandler OnMuyuKnocked;
    public static event EventHandler OnKnockCompleted;

    // 触发事件的方法
    public static void MuyuKnocked()
    {
        OnMuyuKnocked?.Invoke();
    }

    public static void KnockCompleted()
    {
        OnKnockCompleted.Invoke();
    }
}



public class MuyuLayoutController : MonoBehaviour
{
    public GameObject foguang;
    public GameObject foxiang;
    public GameObject muyu;
    // Start is called before the first frame update
    void Start()
    {
        EventCenter.OnMuyuKnocked += MuyuKnocked;
        EventCenter.OnKnockCompleted += KnockCompleted;
    }

    // Update is called once per frame
    void Update()
    {

    }

    public void MuyuKnocked()
    {
        Debug.Log("MuyuLayoutController MuyuKnocked");
    }

    public void KnockCompleted()
    {
        Debug.Log("MuyuLayoutController KnockCompleted");
    }
}
