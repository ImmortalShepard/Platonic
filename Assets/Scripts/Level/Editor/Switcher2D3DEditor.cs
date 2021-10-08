using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Switcher2D3D))]
public class Switcher2D3DEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        Switcher2D3D switcher2D3D = (Switcher2D3D) target;
        if (GUILayout.Button("Swap Projection"))
        {
            switcher2D3D.SwitchProjection();
        }
    }
}
