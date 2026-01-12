using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("ÆÁÄ»ºó´¦Àí/MotionBlur")]
public class MotionBlur : PostEffectBase
{
    RenderTexture texture;
    [Range(0f, 0.9f)]
    public float blurPower;
    private void Start()
    {
        shader = Shader.Find("Unlit/MotionBlur");
    }
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(material == null)
        {
            Graphics.Blit (source, destination);
            return;
        }
        if(texture == null || texture.width != source.width || texture.height != source.height)
        {
            DestroyImmediate(texture);
            texture = new RenderTexture(source.width, source.height, 0);
            texture.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit (source, texture);
        }
        material.SetFloat("_BlurPower",1 - blurPower);
        Graphics.Blit(source, texture,material);
        Graphics.Blit(texture, destination);
    }
    private void OnDisable()
    {
        DestroyImmediate (texture);
    }
}
