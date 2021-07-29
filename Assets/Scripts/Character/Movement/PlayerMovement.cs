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
    }

    private void OnDisable()
    {
        _inputReader.MoveEvent -= OnMove;
        _inputReader.JumpEvent -= OnJump;
        _inputReader.JumpCancelEvent -= OnJumpCancel;
    }

    //Event Listeners
    private void OnMove(Vector2 movement)
    {
        Vector3 movementInput = new Vector3(movement.x, 0, movement.y);
        float cameraAngle = _cameraTransform.eulerAngles.y;
        Quaternion inputRotation = Quaternion.Euler(0, cameraAngle, 0);
        movementInput = inputRotation * movementInput;
         _characterMovement.Movement = new Vector2(movementInput.x, movementInput.z);
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
