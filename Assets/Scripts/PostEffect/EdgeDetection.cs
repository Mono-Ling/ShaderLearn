using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase
{
    public Color edgeColor;
    public Color BKColor;
    [Range(0f, 1f)]
    public float BKExtent;
    protected override void UpdateProperty()
    {
        material.SetColor("_EdgeColor", edgeColor);
        material.SetColor("_BKColor",BKColor);
        material.SetFloat("_BKExtent", BKExtent);
    }
}
