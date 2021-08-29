using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class RollMovement : MonoBehaviour
{
    [SerializeField]
    private Rigidbody _rigidbody;
    [SerializeField]
    private RollSettings _rollSettings = default;


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

        Vector3 newForward = Vector3.RotateTowards(currentForward, inputForward, Mathf.Deg2Rad * _rollSettings.maxAngle * Time.fixedDeltaTime, 0);
        _rigidbody.rotation = Quaternion.LookRotation(newForward);

        //Movement
        float currentVelocity = _rigidbody.velocity.magnitude;
        float inputMagnitude = inputForward.magnitude;
        float maxVelocity = inputMagnitude * _rollSettings.maxSpeed;
        if (currentVelocity < maxVelocity)
        {
            currentVelocity += _rollSettings.acceleration * Time.fixedDeltaTime;
            if (currentVelocity > maxVelocity)
            {
                currentVelocity = maxVelocity;
            }
        }
        else if (currentVelocity > maxVelocity)
        {
            currentVelocity -= _rollSettings.slowDown * Time.fixedDeltaTime;
            if (currentVelocity < maxVelocity)
            {
                currentVelocity = maxVelocity;
            }
        }
        _rigidbody.velocity = newForward * currentVelocity;
    }

    private void MovementNoInput()
    {
        if (_rigidbody.velocity.sqrMagnitude == 0)
        {
            return;
        }

        Vector3 forward = transform.forward;
        float currentVelocity = _rigidbody.velocity.magnitude;
        currentVelocity -= _rollSettings.slowDown * Time.fixedDeltaTime;
        if (currentVelocity < 0)
        {
            currentVelocity = 0;
        }

        _rigidbody.velocity = forward * currentVelocity;
    }
}
