using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightnessStaturationContrast : PostEffectBase
{
    [Range(0f, 3f)]
    public float Brightness;
    [Range(0f, 3f)]
    public float Staturation;
    [Range(0f, 3f)]
    public float Contrast;
    protected override void UpdateProperty()
    {
        material.SetFloat("_Brightness", Brightness);
        material.SetFloat("_Staturation", Staturation);
        material.SetFloat("_Contrast", Contrast);
    }
}
