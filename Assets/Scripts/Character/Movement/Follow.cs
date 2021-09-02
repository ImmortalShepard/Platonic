using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class Follow : MonoBehaviour
{
    [SerializeField]
    private Rigidbody _rigidbody;

    [SerializeField]
    private float _followDistance = 1;
    public float FollowDistance { get => _followDistance; set => _followDistance = value; }

    private Rigidbody _followRigidbody;
    public Rigidbody FollowRigidbody { get => _followRigidbody; set => _followRigidbody = value; }

    private void Reset()
    {
        enabled = false;
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        _rigidbody.velocity = Vector3.zero;
        Vector3 toFollow = _followRigidbody.position - _rigidbody.position;
        toFollow.y = 0;
        float distance = toFollow.magnitude;

        _rigidbody.rotation = Quaternion.LookRotation(toFollow);

        if (distance <= _followDistance)
        {
            return;
        }

        toFollow /= distance;
        _rigidbody.MovePosition(_rigidbody.position + toFollow * (distance - _followDistance));
    }
}
