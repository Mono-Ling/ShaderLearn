using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class AblationManager : MonoBehaviour
{
    [Range(0f,1f)]
    public float ablationProgress;
    public Material body;
    public Material face;
    public Material hair;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (body == null || face == null || hair == null) return;
        body.SetFloat("_AblationProgress",ablationProgress);
        face.SetFloat("_AblationProgress", ablationProgress);
        hair.SetFloat("_AblationProgress", ablationProgress);
    }
}
