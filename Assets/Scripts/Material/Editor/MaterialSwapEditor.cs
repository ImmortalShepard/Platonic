using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(MaterialSwap))]
public class MaterialSwapEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        MaterialSwap materialSwap = (MaterialSwap) target;
        if (GUILayout.Button("Swap Material"))
        {
            materialSwap.SwapMaterial();
        }
    }
}
