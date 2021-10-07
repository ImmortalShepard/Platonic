using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class CharacterMovement : MonoBehaviour
{
    [SerializeField]
    private Rigidbody _rigidbody;
    [SerializeField]
    private MovementSettings _movementSettings = default;

    private bool _isReversing = false;
    private Quaternion _reverseRotation;

    private Vector2 _movement;
    public Vector2 Movement
    {
        get => _movement;
        set => _movement = value;
    }
    private bool _jump;
    public bool Jump
    {
        get => _jump;
        set => _jump = value;
    }

    private void Reset()
    {
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        if (_isReversing)
        {
            ReverseMovement();
            return;
        }

        float movementSqrMagnitude = _movement.sqrMagnitude;

        if (movementSqrMagnitude != 0)
        {
            MovementInput();
            return;
        }

        MovementNoInput();
    }

    private void MovementInput()
    {
        Vector3 inputForward = new Vector3(_movement.x, 0, _movement.y);
        Vector3 currentForward = transform.forward;

        //Rotation
        if (Vector3.Angle(currentForward, inputForward) >= _movementSettings.reverseAngle)
        {
            _isReversing = true;
            _reverseRotation = Quaternion.LookRotation(inputForward);
            ReverseMovement();
            return;
        }

        Vector3 newForward = Vector3.RotateTowards(currentForward, inputForward, Mathf.Deg2Rad * _movementSettings.maxAngle * Time.fixedDeltaTime, 0);
        _rigidbody.rotation = Quaternion.LookRotation(newForward);

        //Movement
        Vector3 velocity = _rigidbody.velocity;
        float yVelocity = velocity.y;
        velocity.y = 0;
        float xyVelocity = velocity.magnitude;
        float inputMagnitude = inputForward.magnitude;
        float maxVelocity = inputMagnitude * _movementSettings.maxSpeed;
        if (xyVelocity < maxVelocity)
        {
            xyVelocity += _movementSettings.acceleration * Time.fixedDeltaTime;
            if (xyVelocity > maxVelocity)
            {
                xyVelocity = maxVelocity;
            }
        }
        else if (xyVelocity > maxVelocity)
        {
            xyVelocity -= _movementSettings.slowDown * Time.fixedDeltaTime;
            if (xyVelocity < maxVelocity)
            {
                xyVelocity = maxVelocity;
            }
        }

        velocity = newForward * xyVelocity;
        velocity.y = yVelocity;
        _rigidbody.velocity = velocity;
    }

    private void ReverseMovement()
    {
        Vector3 forward = transform.forward;
        Vector3 velocity = _rigidbody.velocity;
        float yVelocity = velocity.y;
        velocity.y = 0;
        float xyVelocity = velocity.magnitude;
        xyVelocity -= _movementSettings.reverseAcceleration * Time.fixedDeltaTime;
        if (xyVelocity < 0)
        {
            xyVelocity = 0;
            _rigidbody.rotation = _reverseRotation;
            _isReversing = false;
        }

        velocity = forward * xyVelocity;
        velocity.y = yVelocity;
        _rigidbody.velocity = velocity;
    }

    private void MovementNoInput()
    {
        if (_rigidbody.velocity.sqrMagnitude == 0)
        {
            return;
        }

        Vector3 forward = transform.forward;
        Vector3 velocity = _rigidbody.velocity;
        float yVelocity = velocity.y;
        velocity.y = 0;
        float xyVelocity = velocity.magnitude;
        xyVelocity -= _movementSettings.slowDown * Time.fixedDeltaTime;
        if (xyVelocity < 0)
        {
            xyVelocity = 0;
        }

        velocity = forward * xyVelocity;
        velocity.y = yVelocity;
        _rigidbody.velocity = velocity;
    }
}
