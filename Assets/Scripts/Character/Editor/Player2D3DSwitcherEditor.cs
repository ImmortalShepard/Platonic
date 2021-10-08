using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Player2D3DSwitcher))]
public class Player2D3DSwitcherEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        Player2D3DSwitcher player2D3DSwitcher = (Player2D3DSwitcher) target;
        if (GUILayout.Button("Switch Projection"))
        {
            player2D3DSwitcher.SwitchProjection();
        }
    }
}
