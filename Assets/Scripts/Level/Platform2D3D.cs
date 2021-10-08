using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Platform2D3D : MonoBehaviour, ISwitcher2D3D
{
    [SerializeField]
    private Switcher2D3D _switcher2D3D;
    [SerializeField]
    private Transform _beamTransform;
    [SerializeField]
    private Vector3 _offPosition;
    [SerializeField]
    private Vector3 _onPosition;
    [SerializeField]
    private float _beamTime;
    private float _beamTimer;
    private bool _beamUp;
    private bool _beamMoving = false;
    private Player2D3DSwitcher _player2D3DSwitcher;
    [SerializeField]
    private InputReader _inputReader = default;
    [SerializeField]
    private int _2DLayer;
    [SerializeField]
    private int _3DLayer;
    [SerializeField]
    private GameObject _beam;
    private Renderer _platformRenderer;
    private Renderer _beamRenderer;
    [SerializeField]
    private Material _2dMaterial;
    [SerializeField]
    private Material _3dMaterial;

    private void Reset()
    {
        _switcher2D3D = FindObjectOfType<Switcher2D3D>();
        _2DLayer = LayerMask.NameToLayer("2D");
        _3DLayer = LayerMask.NameToLayer("3D");
    }

    private void Start()
    {
        Switcher2D3D.Instance.AddSwitcher(this);
        _platformRenderer = GetComponent<Renderer>();
        _beamRenderer = GetComponent<Renderer>();
    }

    private void OnTriggerEnter(Collider other)
    {
        _player2D3DSwitcher = other.GetComponent<Player2D3DSwitcher>();
        if (_player2D3DSwitcher == null)
        {
            return;
        }
        _inputReader.InteractEvent += OnInteract;
        _beamUp = true;
        if (!_beamMoving)
        {
            StartCoroutine(Beam());
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (_player2D3DSwitcher == null)
        {
            return;
        }
        Player2D3DSwitcher player2D3DSwitcher = other.GetComponent<Player2D3DSwitcher>();
        if (player2D3DSwitcher == null || _player2D3DSwitcher != player2D3DSwitcher)
        {
            return;
        }
        _inputReader.InteractEvent -= OnInteract;
        _beamUp = false;
        if (!_beamMoving)
        {
            StartCoroutine(Beam());
        }
    }

    private void OnInteract()
    {
        _switcher2D3D.SwitchProjection();
    }

    private IEnumerator Beam()
    {
        _beamMoving = true;
        _beamTimer = _beamUp ? 0 : _beamTime;
        while (_beamUp ? _beamTimer < _beamTime : _beamTimer > 0)
        {
            _beamTimer += _beamUp ? Time.deltaTime : -Time.deltaTime;
            _beamTransform.localPosition = Vector3.Lerp(_offPosition, _onPosition, _beamTimer);
            yield return null;
        }
        _beamMoving = false;
    }

    public void SwitchProjection()
    {
        if (gameObject.layer == _2DLayer)
        {
            To3D();
            return;
        }
        if (gameObject.layer == _3DLayer)
        {
            To2D();
        }
    }

    private void To2D()
    {
        gameObject.layer = _2DLayer;
        _beam.layer = _2DLayer;
        _platformRenderer.material = _2dMaterial;
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            Vector3 playerPosition = transform.position;
            playerPosition.z = Util2D3D.Convert2Dto3D(playerPosition.z);
            transform.position = playerPosition;
            return;
        }
#endif
        Vector3 position = transform.position;
        position.z = Util2D3D.Convert2Dto3D(position.z);
        transform.position = position;
    }

    private void To3D()
    {
        gameObject.layer = _3DLayer;
        _beam.layer = _3DLayer;
        _platformRenderer.material = _3dMaterial;
#if UNITY_EDITOR
        if (!Application.isPlaying)
        {
            Vector3 playerPosition = transform.position;
            playerPosition.z = Util2D3D.Convert3Dto2D(playerPosition.z);
            transform.position = playerPosition;
            return;
        }
#endif
        Vector3 position = transform.position;
        position.z = Util2D3D.Convert3Dto2D(position.z);
        transform.position = position;
    }

    public void Switch2D3D()
    {
        SwitchProjection();
    }
}
