using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("ÆÁÄ»ºó´¦Àí/EdgeDetectionDepthNormal")]
public class EdgeDetectionDepthNormal : PostEffectBase
{
    [Range(0,1)]
    public float normalThreshold;
    [Range(0, 0.1f)]
    public float depthThreshold;
    public Color edgeColor;
    [Range(0, 5)]
    public float uvOffset;
    [Range(0,1)]
    public float depthSensitivity;
    [Range(0,1)]
    public float normalSensitivity;
    [Range(0,1)]
    public float bkPower = 0;
    public Color bkColor;
    private void Start()
    {
        shader = Shader.Find("Unlit/EdgeDetectionDepthNormal");
        
    }
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        base.OnRenderImage(source, destination);
    }
    protected override void UpdateProperty()
    {
        Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
        material.SetFloat("_DepthThreshold", depthThreshold);
        material.SetFloat("_NormalThreshold", normalThreshold);
        material.SetFloat("_UVOffset",uvOffset);
        material.SetColor("_EdgeColor",edgeColor);
        material.SetFloat("_DepthSensitivity", depthSensitivity);
        material.SetFloat("_NormalSensitivity", normalSensitivity);
        material.SetFloat("_BKPower", bkPower);
        material.SetColor("_BKColor", bkColor);
    }
}
