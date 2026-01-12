using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("ÆÁÄ»ºó´¦Àí/GaussianBlur")]
public class GaussianBlur : PostEffectBase
{
    [Range(1.0f, 8.0f)]
    public int downSample = 1;
    [Range(0f, 8.0f)]
    public int iteration;
    [Range(0,3)]
    public float blurSpread;
    private void Start()
    {
        shader = Shader.Find("Unlit/GaussianBlur");
    }
    protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material == null)
        {
            Graphics.Blit(source, destination);
            return;
        }
        int w = source.width / downSample;
        int h = source.height / downSample;
        RenderTexture buffer = RenderTexture.GetTemporary(w, h, 0);
        buffer.filterMode = FilterMode.Bilinear;
        Graphics.Blit(source, buffer);
        for (int i = 0; i < iteration; i++)
        {
            material.SetFloat("_BlurSpread",1+i*blurSpread);
            RenderTexture bufferPlus = RenderTexture.GetTemporary(w , h , 0);
            Graphics.Blit(buffer, bufferPlus, material, 0);
            RenderTexture.ReleaseTemporary(buffer);
            buffer = RenderTexture.GetTemporary(w, h, 0);
            Graphics.Blit(bufferPlus, buffer, material, 1);
            RenderTexture.ReleaseTemporary(bufferPlus);
        }
        Graphics.Blit(buffer, destination);
        RenderTexture.ReleaseTemporary(buffer);
    }
}
