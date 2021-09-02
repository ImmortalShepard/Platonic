using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterMovement))]
public class PlayerMovement : MonoBehaviour
{
    [SerializeField]
    private Transform _cameraTransform;
    [SerializeField]
    private InputReader _inputReader = default;
    [SerializeField]
    private CharacterMovement _characterMovement;

    private Vector2 _movementInput = Vector2.zero;

    private void Reset()
    {
        _cameraTransform = Camera.main.transform;
        _characterMovement = GetComponent<CharacterMovement>();
    }

    private void OnEnable()
    {
        _inputReader.MoveEvent += OnMove;
        _inputReader.JumpEvent += OnJump;
        _inputReader.JumpCancelEvent += OnJumpCancel;
        _characterMovement.enabled = true;
    }

    private void OnDisable()
    {
        _inputReader.MoveEvent -= OnMove;
        _inputReader.JumpEvent -= OnJump;
        _inputReader.JumpCancelEvent -= OnJumpCancel;
        _characterMovement.enabled = false;
    }

    private void FixedUpdate()
    {
        Vector3 movementInput = new Vector3(_movementInput.x, 0, _movementInput.y);
        float cameraAngle = _cameraTransform.eulerAngles.y;
        Quaternion inputRotation = Quaternion.Euler(0, cameraAngle, 0);
        movementInput = inputRotation * movementInput;
        _characterMovement.Movement = new Vector2(movementInput.x, movementInput.z);
    }

    //Event Listeners
    private void OnMove(Vector2 movement)
    {
        _movementInput = movement;
    }

    private void OnJump()
    {
        _characterMovement.Jump = true;
    }

    private void OnJumpCancel()
    {
        _characterMovement.Jump = false;
    }
}
