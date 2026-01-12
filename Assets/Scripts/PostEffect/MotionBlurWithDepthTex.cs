using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("ÆÁÄ»ºó´¦Àí/MotionBlurWithDepthTex")]
public class MotionBlurWithDepthTex : PostEffectBase
{
    Matrix4x4 oldWorldToClipMatrix;
    [Range(0.0f, 1.0f)]
    public float blurOffset = 0.5f;

    private void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        shader = Shader.Find("Unlit/MotionBlurWithDepthTex");
    }
    private void OnEnable()
    {
        oldWorldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
    }
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material  == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        Matrix4x4 worldToClipMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
        //Matrix4x4 clipToWorldMatrix = worldToClipMatrix.inverse;
        material.SetMatrix("_ClipToWorldMatrix", worldToClipMatrix.inverse);
        material.SetMatrix("_OldWorldToClipMatrix", oldWorldToClipMatrix);
        material.SetFloat("_BlurOffset", blurOffset);
        Graphics.Blit (source, destination, material);
        oldWorldToClipMatrix = worldToClipMatrix;
    }
}
