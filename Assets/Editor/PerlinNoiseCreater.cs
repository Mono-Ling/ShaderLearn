using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

public class PerlinNoiseCreater : EditorWindow
{
    int width = 512;
    int height = 512;
    int scale = 20;
    string path = "PerlinNoiseTexture_";
    [MenuItem("工具/生成柏林噪声纹理")]
    static void OpenWindow()
    {
        PerlinNoiseCreater window = EditorWindow.GetWindow<PerlinNoiseCreater>("生成柏林噪声纹理");
        window.Show();
    }
    private void OnGUI()
    {
        width = EditorGUILayout.IntField("宽", width);
        height = EditorGUILayout.IntField ("高", height);
        scale = EditorGUILayout.IntField("缩放", scale);
        path = EditorGUILayout.TextField("路径",path);
        if (GUILayout.Button("生成柏林噪声纹理"))
        {
            Texture2D texture = new Texture2D(width, height);
            for (int w = 0; w < width; w++)
            {
                for (int h = 0; h < height; h++)
                {
                    float noise = Mathf.PerlinNoise((float)w/width*scale, (float)h/height*scale);
                    texture.SetPixel(w,h,new Color(noise,noise,noise));
                }
            }
            texture.Apply();
            File.WriteAllBytes("Assets/" + path + ".png", texture.EncodeToPNG());
            AssetDatabase.Refresh();
        }
    }
}
