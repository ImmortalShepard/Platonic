using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Platform2D3D : MonoBehaviour
{
    [SerializeField]
    private CameraSwitcher _cameraSwitcher;
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
    private Platform2D3D _otherPlatform2D3D;

    private void Reset()
    {
        _cameraSwitcher = FindObjectOfType<CameraSwitcher>();
    }

    private void OnTriggerEnter(Collider other)
    {
        _player2D3DSwitcher = other.GetComponent<Player2D3DSwitcher>();
        if (_player2D3DSwitcher == null)
        {
            return;
        }
        Debug.Log("Player entered platform");
        //_cameraSwitcher.SwapProjection();
        //player2D3DSwitcher.SwapProjection();
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
}
