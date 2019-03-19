using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
public class FogLabyrinthRefPos : MonoBehaviour
{
    public bool isItMain = false;
    public GameObject MainTorch;
    public float MaxDistance = 10;
    public string refName = "_RefLabyrinthPos";

    void Update()
    {
        Shader.SetGlobalVector(refName, transform.position);
        if(!isItMain)
        {
        Shader.SetGlobalFloat(refName+"Distance", Mathf.Clamp01(Vector3.Distance(transform.position, MainTorch.transform.position) / MaxDistance));
        
		}
    }
}
