using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CameraSwitcher))]
public class CameraSwitcherEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        CameraSwitcher cameraSwitcher = (CameraSwitcher) target;
        if (GUILayout.Button("Swap Projection"))
        {
            cameraSwitcher.SwapProjection();
        }
    }
}
