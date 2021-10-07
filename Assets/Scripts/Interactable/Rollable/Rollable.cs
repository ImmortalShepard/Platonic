using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(RollMovement))]
[RequireComponent(typeof(Rigidbody))]
public class Rollable : MonoBehaviour, Interactable
{
    [SerializeField]
    private InputReader _inputReader = default;
    [SerializeField]
    private RollMovement _rollMovement;
    [SerializeField]
    private Transform _cameraTransform;
    [SerializeField]
    private GameObject _popUp;
    [SerializeField]
    private Rigidbody _rigidbody;

    private Vector2 _movementInput = Vector2.zero;
    private bool _rolling = false;
    private PlayerInteraction _playerInteraction;
    private PlayerMovement _playerMovement;
    private Follow _follow;

    private void Reset()
    {
        _rollMovement = GetComponent<RollMovement>();
        _cameraTransform = Camera.main.transform;
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void OnDisable()
    {
        _inputReader.InteractEvent -= OnInteract;
        _inputReader.MoveEvent -= OnMove;
        if (_playerInteraction)
        {
            _playerMovement.enabled = true;
            _follow.enabled = false;
            _playerInteraction.enabled = true;
        }
    }

    private void FixedUpdate()
    {
        if (!_rolling)
        {
            return;
        }
        Vector3 movementInput = new Vector3(_movementInput.x, 0, _movementInput.y);
        float cameraAngle = _cameraTransform.eulerAngles.y;
        Quaternion inputRotation = Quaternion.Euler(0, cameraAngle, 0);
        movementInput = inputRotation * movementInput;
        _rollMovement.Movement = new Vector2(movementInput.x, movementInput.z);
    }

    public void Activate(PlayerInteraction playerInteraction)
    {
        _inputReader.InteractEvent += OnInteract;
        _playerInteraction = playerInteraction;
        _playerMovement = playerInteraction.GetComponent<PlayerMovement>();
        _follow = playerInteraction.GetComponent<Follow>();
        _popUp.SetActive(true);
    }

    public void Deactivate()
    {
        _inputReader.InteractEvent -= OnInteract;
        _playerInteraction = null;
        _popUp.SetActive(false);
    }

    private void OnInteract()
    {
        _rolling = !_rolling;
        switch (_rolling)
        {
            case true:
                _inputReader.MoveEvent += OnMove;
                _rollMovement.enabled = true;
                _rollMovement.SetForward(_playerInteraction.transform.forward);
                _playerMovement.enabled = false;
                _follow.enabled = true;
                _follow.FollowRigidbody = _rigidbody;
                _playerInteraction.enabled = false;
                _popUp.SetActive(false);
                break;
            case false:
                _inputReader.MoveEvent -= OnMove;
                _rollMovement.enabled = false;
                _playerMovement.enabled = true;
                _follow.enabled = false;
                _playerInteraction.enabled = true;
                _popUp.SetActive(true);
                break;
        }
    }

    private void OnMove(Vector2 movement)
    {
        _movementInput = movement;
    }
}
