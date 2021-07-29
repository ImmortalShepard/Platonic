using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MaterialSwap : MonoBehaviour
{
    [SerializeField]
    private Material startMaterial;
    [SerializeField]
    private Material swapMaterial;

    private bool IsSwapped = false;

    [SerializeField]
    private List<MeshFilter> meshFilters = new List<MeshFilter>();

    private List<MeshRenderer> meshRenderers = new List<MeshRenderer>();

    private List<Bounds> startBounds = new List<Bounds>();

    [SerializeField]
    private bool isSwapFlat = true;
    [SerializeField]
    private float flatHeight = 0;
    [SerializeField]
    private Vector3 flatRotationAxis = Vector3.right;
    [SerializeField]
    private float flatRotationDegrees = 45;

    [SerializeField]
    private float outlineSize = 0.1f;
    private float outlineMargin = 0.1f;

    private void Awake()
    {
        meshFilters.ForEach(meshFilter =>
        {
            Bounds bounds = meshFilter.mesh.bounds;
            bounds.Expand(outlineSize + outlineMargin);
            meshFilter.mesh.bounds = bounds;
            startBounds.Add(bounds);

            MeshRenderer meshRenderer = meshFilter.GetComponent<MeshRenderer>();
            meshRenderers.Add(meshRenderer);
        });
    }

    public void SwapMaterial()
    {
        for (int i = 0; i < meshFilters.Count; i++)
        {
            MeshFilter meshFilter = meshFilters[i];
#if UNITY_EDITOR
            MeshRenderer meshRenderer;
            if (Application.isPlaying)
            {
                meshRenderer = meshRenderers[i];
                if (meshFilter == null || meshRenderer == null)
                {
                    continue;
                }
            }
            else
            {
                meshRenderer = meshFilter.GetComponent<MeshRenderer>();
                if (meshRenderer == null)
                {
                    Debug.Log($"No MeshRenderer for MeshFilter: {meshFilter.name}");
                    continue;
                }
            }
#else
            MeshRenderer meshRenderer = meshRenderers[i];
            if (meshFilter == null || meshRenderer == null)
            {
                continue;
            }
#endif
            
            if (IsSwapped)
            {
                meshRenderer.material = startMaterial;
#if UNITY_EDITOR
                if (Application.isPlaying)
                {
                    meshFilter.mesh.bounds = startBounds[i];
                }
                else
                {
                    meshFilter.sharedMesh.RecalculateBounds();
                    Bounds bounds = meshFilter.sharedMesh.bounds;
                    //bounds.Expand(outlineSize + outlineMargin);
                    meshFilter.sharedMesh.bounds = bounds;
                }
#else
                meshFilter.mesh.bounds = startBounds[i];
#endif
            }
            else
            {
                meshRenderer.material = swapMaterial;
                CalculateSwapBounds(meshFilter);
            }
        }

        IsSwapped = !IsSwapped;
    }

    private void CalculateSwapBounds(MeshFilter meshFilter)
    {
#if UNITY_EDITOR
        Bounds bounds = Application.isPlaying ? meshFilter.mesh.bounds : meshFilter.sharedMesh.bounds;
#else
        Bounds bounds = meshFilter.mesh.bounds;
#endif
        Vector3 boundsCenter = meshFilter.transform.TransformPoint(bounds.center);
        Quaternion rotation = Quaternion.AngleAxis(flatRotationDegrees, flatRotationAxis);
        Vector3 flatCenter = rotation * boundsCenter;
        flatCenter.y = flatHeight;
        bounds.center -= meshFilter.transform.InverseTransformDirection(boundsCenter - flatCenter);

        Vector3 extents = meshFilter.transform.TransformDirection(bounds.extents);
        extents = rotation * extents;
        extents.y = 0.01f;
        bounds.extents = meshFilter.transform.InverseTransformDirection(extents);

#if UNITY_EDITOR
        if (Application.isPlaying)
        {
            meshFilter.mesh.bounds = bounds;
        }
        else
        {
            meshFilter.sharedMesh.bounds = bounds;
        }
#else
        meshFilter.mesh.bounds = bounds;
#endif
    }
}
