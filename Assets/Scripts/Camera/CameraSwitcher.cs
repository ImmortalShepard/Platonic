using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CameraSwitcher : MonoBehaviour
{
    [SerializeField]
    private Camera _camera;
    [SerializeField]
    private CinemachineVirtualCamera _virtual2DCamera;
    [SerializeField]
    private CinemachineVirtualCamera _virtual3DCamera;

    private CinemachineBrain _cinemachineBrain;

    [SerializeField]
    private LayerMask _2DLayerMask = 0;
    [SerializeField]
    private LayerMask _3DLayerMask = 0;

    private void Reset()
    {
        _camera = Camera.main;
    }

    private void Start()
    {
        _cinemachineBrain = _camera.GetComponent<CinemachineBrain>();
    }

    public void ToOrthographic2D()
    {
        _camera.orthographic = true;
        _camera.cullingMask = _2DLayerMask;
    }

    public void ToPerspective3D()
    {
        _camera.orthographic = false;
        _camera.cullingMask = _3DLayerMask;
    }

    public void To2DCamera()
    {
        _virtual2DCamera.Priority = 1;
        _virtual3DCamera.Priority = 0;
    }

    public void To3DCamera()
    {
        _virtual2DCamera.Priority = 0;
        _virtual3DCamera.Priority = 1;
    }

    public bool IsCinemachineBlending()
    {
        return _cinemachineBrain.IsBlending;
    }

    public bool IsCameraOrthographic()
    {
        return _camera.orthographic;
    }
}
