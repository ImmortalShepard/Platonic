using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MaterialSwitcher : MonoBehaviour, ISwitcher2D3D
{
    [SerializeField]
    private Material _startMaterial;
    [SerializeField]
    private Material _swapMaterial;

    private bool _isSwapped = false;

    [SerializeField]
    private List<MeshFilter> _meshFilters = new List<MeshFilter>();

    private List<MeshRenderer> _meshRenderers = new List<MeshRenderer>();
    
    private List<Bounds> _startBounds = new List<Bounds>();

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
        _meshFilters.ForEach(meshFilter =>
        {
            Bounds bounds = meshFilter.mesh.bounds;
            bounds.Expand(outlineSize + outlineMargin);
            meshFilter.mesh.bounds = bounds;
            _startBounds.Add(bounds);

            MeshRenderer meshRenderer = meshFilter.GetComponent<MeshRenderer>();
            _meshRenderers.Add(meshRenderer);
        });
    }

    private void Start()
    {
        Switcher2D3D.Instance.AddSwitcher(this);
    }

    private void SwapMaterial()
    {
        for (int i = 0; i < _meshFilters.Count; i++)
        {
            MeshFilter meshFilter = _meshFilters[i];
            MeshRenderer meshRenderer = _meshRenderers[i];
            if (meshFilter == null || meshRenderer == null)
            {
                continue;
            }

            if (_isSwapped)
            {
                meshRenderer.material = _startMaterial;
                meshFilter.mesh.bounds = _startBounds[i];
            }
            else
            {
                meshRenderer.material = _swapMaterial;
                CalculateSwapBounds(meshFilter);
            }
        }

        _isSwapped = !_isSwapped;
    }

    private void CalculateSwapBounds(MeshFilter meshFilter)
    {
        Bounds bounds = meshFilter.mesh.bounds;
        Vector3 boundsCenter = meshFilter.transform.TransformPoint(bounds.center);
        Quaternion rotation = Quaternion.AngleAxis(flatRotationDegrees, flatRotationAxis);
        Vector3 flatCenter = rotation * boundsCenter;
        flatCenter.y = flatHeight;
        bounds.center -= meshFilter.transform.InverseTransformDirection(boundsCenter - flatCenter);

        Vector3 extents = meshFilter.transform.TransformDirection(bounds.extents);
        extents = rotation * extents;
        extents.y = 0.01f;
        bounds.extents = meshFilter.transform.InverseTransformDirection(extents);
        meshFilter.mesh.bounds = bounds;
    }

    public void Switch2D3D()
    {
        SwapMaterial();
    }
}
