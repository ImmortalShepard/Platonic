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
    private Vector3 _capsuleSphere1 = new Vector3(0, 0.70f, 0);
    [SerializeField]
    private Vector3 _capsuleSphere2 = new Vector3(0, -0.70f, 0);
    [SerializeField]
    private float _capsuleRadius = 0.25f;
    [SerializeField]
    private float _checkOffset = 0.25f;

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
        //TODO Check a minimum distance
        if (distance == 0)
        {
            raycast = new RaycastHit();
            return false;
        }
        Vector3 movement = forward * distance;
        movement.z = Util2D3D.Convert2Dto3D(movement.z);
        distance = movement.magnitude;
        forward = movement / distance;
        return Physics.CapsuleCast(_rigidbody.position + _capsuleSphere1, _rigidbody.position + _capsuleSphere2, _capsuleRadius, forward, out raycast, distance + _checkOffset, LayerMask.GetMask("3D"));
    }

    public override void MoveTo(Vector3 position)
    {
        position += _offset;
        position.z = Util2D3D.Convert2Dto3D(position.z);
        _rigidbody.MovePosition(position);
    }
}
