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
    private ForwardRendererData _forwardRendererData;
    private CircleWipePassFeature _circleWipe;

    [SerializeField]
    private float _fadeTime = 0.4f;
    [SerializeField]
    private float _blackTime = 0.2f;
    private float _transitionTimer = 0.0f;

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

        if (_forwardRendererData)
        {
            ScriptableRendererFeature scriptableRendererFeature = _forwardRendererData.rendererFeatures.Find(renderFeature => renderFeature is CircleWipePassFeature);
            _circleWipe = scriptableRendererFeature as CircleWipePassFeature;
            _circleWipe?.SetActive(false);
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

    private IEnumerator ToPerspective()
    {
        _circleWipe.SetActive(true);

        _transitionTimer = 0;
        do
        {
            FadeOut();
            yield return null;
        } while (_transitionTimer < _fadeTime);

        _camera.orthographic = false;
        _camera.cullingMask = _3DLayerMask;

        _transitionTimer = 0;
        while (_transitionTimer < _blackTime || _cinemachineBrain.IsBlending)
        {
            _transitionTimer += Time.deltaTime;
            yield return null;
        }

        _transitionTimer = 0;
        do
        {
            FadeIn();
            yield return null;
        } while (_transitionTimer < _fadeTime);

        _virtual2DCamera.Priority = 0;
        _virtual3DCamera.Priority = 1;

        _circleWipe.SetActive(false);
    }

    private IEnumerator ToOrthographic()
    {
        _circleWipe.SetActive(true);

        _virtual2DCamera.Priority = 1;
        _virtual3DCamera.Priority = 0;

        _transitionTimer = 0;
        do
        {
            FadeOut();
            yield return null;
        } while (_transitionTimer < _fadeTime);

        _camera.orthographic = true;
        _camera.cullingMask = _2DLayerMask;

        _transitionTimer = 0;
        while (_transitionTimer < _blackTime || _cinemachineBrain.IsBlending)
        {
            _transitionTimer += Time.deltaTime;
            yield return null;
        }

        _transitionTimer = 0;
        do
        {
            FadeIn();
            yield return null;
        } while (_transitionTimer < _fadeTime);

        _circleWipe.SetActive(false);
    }

    private void FadeOut()
    {
        _transitionTimer += Time.deltaTime;
        float lerpT = _transitionTimer / _fadeTime;
        _circleWipe.CircleSize = Mathf.Lerp(1, 0, lerpT);
    }

    private void FadeIn()
    {
        _transitionTimer += Time.deltaTime;
        float lerpT = _transitionTimer / _fadeTime;
        _circleWipe.CircleSize = Mathf.Lerp(0, 1, lerpT);
    }
}
