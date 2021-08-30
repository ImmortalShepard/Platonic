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

    [SerializeField]
    private Volume _volume;
    [SerializeField]
    private ForwardRendererData _forwardRendererData;
    private CircleWipePassFeature _circleWipe;

    [SerializeField]
    private float _fadeTime = 0.5f;
    private float _fadeTimer = 0.0f;

    private float _cameraBlendTime = 0.0f;

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
        CinemachineBrain cinemachineBrain = _camera.GetComponent<CinemachineBrain>();
        if (cinemachineBrain != null)
        {
            _cameraBlendTime = cinemachineBrain.m_DefaultBlend.BlendTime;
        }

        if (_forwardRendererData)
        {
            ScriptableRendererFeature scriptableRendererFeature = _forwardRendererData.rendererFeatures.Find(renderFeature => renderFeature is CircleWipePassFeature);
            _circleWipe = scriptableRendererFeature as CircleWipePassFeature;
        }
    }

    public void SwapProjection()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            _camera.orthographic = !_camera.orthographic;
            switch (_camera.orthographic)
            {
                case true:
                    _camera.cullingMask = _2DLayerMask;
                    _virtual2DCamera.Priority = 1;
                    _virtual3DCamera.Priority = 0;
                    break;
                case false:
                    _camera.cullingMask = _3DLayerMask;
                    _virtual2DCamera.Priority = 0;
                    _virtual3DCamera.Priority = 1;
                    break;
            }
            return;
        }
#endif
        switch (_camera.orthographic)
        {
            case true:
                StartCoroutine(ToPerspective());
                break;
            case false:
                StartCoroutine(ToOrthographic());
                break;
        }
    }

    IEnumerator ToPerspective()
    {
        _fadeTimer = 0;
        do
        {
            FadeOut();
            yield return null;
        } while (_fadeTimer < _fadeTime);

        _camera.orthographic = false;
        _camera.cullingMask = _3DLayerMask;

        _fadeTimer = 0;
        do
        {
            FadeIn();
            yield return null;
        } while (_fadeTimer < _fadeTime);

        _virtual2DCamera.Priority = 0;
        _virtual3DCamera.Priority = 1;
    }

    IEnumerator ToOrthographic()
    {
        _virtual2DCamera.Priority = 1;
        _virtual3DCamera.Priority = 0;

        _fadeTimer = 0;
        do
        {
            _fadeTimer += Time.deltaTime;
            yield return null;
        } while (_fadeTimer < _cameraBlendTime);

        _fadeTimer = 0;
        do
        {
            FadeOut();
            yield return null;
        } while (_fadeTimer < _fadeTime);

        _camera.orthographic = true;
        _camera.cullingMask = _2DLayerMask;

        _fadeTimer = 0;
        do
        {
            FadeIn();
            yield return null;
        } while (_fadeTimer < _fadeTime);
    }

    private void FadeOut()
    {
        _fadeTimer += Time.deltaTime;
        float lerpT = _fadeTimer / _fadeTime;
        //_volume.weight = Mathf.Lerp(0, 1, lerpT);
        _circleWipe.CircleWipeSettings._circleSize = Mathf.Lerp(1, 0, lerpT);
    }

    private void FadeIn()
    {
        _fadeTimer += Time.deltaTime;
        float lerpT = _fadeTimer / _fadeTime;
        //_volume.weight = Mathf.Lerp(1, 0, lerpT);
        _circleWipe.CircleWipeSettings._circleSize = Mathf.Lerp(0, 1, lerpT);
    }
}
