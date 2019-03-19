using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(Labyrinth))]
public class LabyrinthEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        if (GUILayout.Button("Rebuild indoor"))
        {
            ((Labyrinth)target).RegenerateMesh();
        }
    }
}
