using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementTester3D : InteractableMovement
{
    [SerializeField]
    private Rigidbody _rigidbody;
    [SerializeField]
    private Vector3 _offset;
    [SerializeField]
    private float _minDistamce = 0.1f;

    private void Reset()
    {
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void OnEnable()
    {
        _rigidbody.constraints = RigidbodyConstraints.FreezeRotation;
    }

    private void OnDisable()
    {
        _rigidbody.constraints = RigidbodyConstraints.FreezeRotation | RigidbodyConstraints.FreezePositionX | RigidbodyConstraints.FreezePositionZ;
    }

    public override bool CheckMovement(ref Vector3 forward, float distance, out RaycastHit raycast)
    {
        if (distance < _minDistamce)
        {
            distance = _minDistamce;
        }
        Vector3 movement = forward * distance;
        movement.z = Util2D3D.Convert2Dto3D(movement.z);
        distance = movement.magnitude;
        forward = movement / distance;
        return _rigidbody.SweepTest(forward, out raycast, distance, QueryTriggerInteraction.Ignore);
    }

    public override void MoveTo(Vector3 position)
    {
        position += _offset;
        position.z = Util2D3D.Convert2Dto3D(position.z);
        _rigidbody.MovePosition(position);
    }
}
