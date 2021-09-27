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
    [SerializeField]
    private InteractableMovement _interactableMovement;

    private Vector2 _movement;
    public Vector2 Movement
    {
        get => _movement;
        set => _movement = value;
    }

    private void Reset()
    {
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void OnEnable()
    {
        _rigidbody.constraints = RigidbodyConstraints.FreezeRotation;
        _interactableMovement.enabled = true;
    }

    private void OnDisable()
    {
        _rigidbody.constraints = RigidbodyConstraints.FreezeRotation | RigidbodyConstraints.FreezePositionX | RigidbodyConstraints.FreezePositionZ;
        _interactableMovement.enabled = false;
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
        SetForward(newForward);

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

        newForward.y = 0;
        float distance = currentVelocity * Time.fixedDeltaTime;
        if (!CheckInteractable(newForward, distance))
        {
            MoveInteractable(_rigidbody.velocity * Time.fixedDeltaTime);
        }
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

        float distance = currentVelocity * Time.fixedDeltaTime;
        if (!CheckInteractable(forward, distance))
        {
            MoveInteractable(_rigidbody.velocity * Time.fixedDeltaTime);
        }
    }

    public void SetForward(Vector3 newForward)
    {
        _rigidbody.rotation = Quaternion.LookRotation(newForward);
    }

    private void MoveInteractable(Vector3 movement)
    {
        _interactableMovement.MoveTo(_rigidbody.position + movement);
    }

    private bool CheckInteractable(Vector3 forward, float distance)
    {
        RaycastHit raycast;
        bool hit = _interactableMovement.CheckMovement(ref forward, distance, out raycast);
        if (hit)
        {
            float otherDistance = raycast.distance;
            Debug.Log("Check: " + otherDistance);
            Vector3 movement = forward * otherDistance;
            movement.z = Util2D3D.Convert3Dto2D(movement.z);
            _rigidbody.velocity = Vector3.zero;
            _rigidbody.MovePosition(_rigidbody.position += movement);
            MoveInteractable(movement);
        }
        return hit;
    }
}
