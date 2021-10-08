using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class Switcher2D3D : MonoBehaviour
{
    [SerializeField]
    private ForwardRendererData _forwardRendererData = default;
    private CircleWipePassFeature _circleWipe;
    [SerializeField]
    private CameraSwitcher _cameraSwitcher;

    [SerializeField]
    private float _fadeTime = 0.4f;
    [SerializeField]
    private float _blackTime = 0.2f;
    private float _transitionTimer = 0.0f;
    private List<ISwitcher2D3D> _switchers = new List<ISwitcher2D3D>();
    [SerializeField]
    private PlayerMovement _playerMovement;

    private static Switcher2D3D _instance;
    public static Switcher2D3D Instance => _instance;

    private void Awake()
    {
        if (_instance != null && _instance != this)
        {
            Destroy(this.gameObject);
        }
        else
        {
            _instance = this;
        }
    }

    private void Reset()
    {
        _cameraSwitcher = FindObjectOfType<CameraSwitcher>();
        _playerMovement = FindObjectOfType<PlayerMovement>();
    }

    private void Start()
    {
        if (_forwardRendererData)
        {
            ScriptableRendererFeature scriptableRendererFeature = _forwardRendererData.rendererFeatures.Find(renderFeature => renderFeature is CircleWipePassFeature);
            _circleWipe = scriptableRendererFeature as CircleWipePassFeature;
            _circleWipe?.SetActive(false);
        }
    }

    public void AddSwitcher(ISwitcher2D3D switcher)
    {
        _switchers.Add(switcher);
    }

    public void SwitchProjection()
    {
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            switch (_cameraSwitcher.IsCameraOrthographic())
            {
                case true:
                    _cameraSwitcher.ToPerspective3D();
                    _cameraSwitcher.To3DCamera();
                    break;
                case false:
                    _cameraSwitcher.ToOrthographic2D();
                    _cameraSwitcher.To2DCamera();
                    break;
            }
            return;
        }
#endif
        _playerMovement.enabled = false;
        switch (_cameraSwitcher.IsCameraOrthographic())
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

        _cameraSwitcher.ToPerspective3D();
        _switchers.ForEach(switcher => switcher.Switch2D3D());

        _transitionTimer = 0;
        while (_transitionTimer < _blackTime || _cameraSwitcher.IsCinemachineBlending())
        {
            _transitionTimer += Time.deltaTime;
            yield return null;
        }

        _playerMovement.enabled = true;
        _transitionTimer = 0;
        do
        {
            FadeIn();
            yield return null;
        } while (_transitionTimer < _fadeTime);

        _cameraSwitcher.To3DCamera();

        _circleWipe.SetActive(false);
    }

    private IEnumerator ToOrthographic()
    {
        _circleWipe.SetActive(true);

        _cameraSwitcher.To2DCamera();

        _transitionTimer = 0;
        do
        {
            FadeOut();
            yield return null;
        } while (_transitionTimer < _fadeTime);

        _cameraSwitcher.ToOrthographic2D();
        _switchers.ForEach(switcher => switcher.Switch2D3D());

        _transitionTimer = 0;
        while (_transitionTimer < _blackTime || _cameraSwitcher.IsCinemachineBlending())
        {
            _transitionTimer += Time.deltaTime;
            yield return null;
        }

        _playerMovement.enabled = true;
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
