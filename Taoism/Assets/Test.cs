using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class Test : MonoBehaviour,IPointerEnterHandler, IPointerExitHandler
{
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
    
    		public void OnPointerEnter(PointerEventData eventData)
		{
			// cursorManager.SetHoverCursor(); // 悬停时切换样式
			Debug.LogWarning("OnPointerEnter");
		}

		public void OnPointerExit(PointerEventData eventData)
		{
			// cursorManager.SetDefaultCursor(); // 离开时恢复默认
			Debug.LogWarning("OnPointerExit");
		}
}
