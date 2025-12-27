using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// using static SettingsMenuManager;

public class TSettingController : MonoBehaviour
{
    public GameObject settingsMenuPanel; // 引用设置菜单面板
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnMouseDown()
    {
        Debug.Log("直接点击到了: " + gameObject.name);
        // 这里可以写点击后的处理逻辑，如销毁物体、播放动画等

        // GameObject targetGameObject = GameObject.Find("SettingsMenuPanel");
        // 至关重要的空引用检查！确保找到了对象再操作
        if (settingsMenuPanel != null)
        {
            Debug.Log("显示: " + settingsMenuPanel);
            // 方法1：使用 SetActive 激活对象（最常用）
            settingsMenuPanel.SetActive(true);
        }
        // SettingsMenuManager btn = other.GetComponent<SettingsMenuManager>();

            // GameObject targetGameObject = GameObject.Find("Button");
            // Button btn = other.GetComponent<Button>();
            // btn.onClick.AddListener(() => OnEquipWeapon(weaponId, weaponName));
            Debug.Log("直接点击到了: " + settingsMenuPanel);
    }
}
