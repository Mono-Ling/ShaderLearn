using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase
{
    public Color edgeColor;
    protected override void UpdateProperty()
    {
        material.SetColor("_EdgeColor", edgeColor);
    }
}
