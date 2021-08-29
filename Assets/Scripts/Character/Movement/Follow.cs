using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class Follow : MonoBehaviour
{
    [SerializeField]
    private Rigidbody _rigidbody;

    [SerializeField]
    private float _followDistance = 0.5f;
    public float FollowDistance { get => _followDistance; set => _followDistance = value; }

    private Transform _followTransform;
    public Transform FollowTransform { get => _followTransform; set => _followTransform = value; }

    private void Reset()
    {
        enabled = false;
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        Vector3 toFollow = _followTransform.position - transform.position;
        toFollow.y = 0;
        float distance = toFollow.magnitude;
        if (distance <= _followDistance)
        {
            return;
        }

        toFollow /= distance;
        _rigidbody.rotation = Quaternion.LookRotation(toFollow);
        _rigidbody.MovePosition(_rigidbody.position + toFollow * (distance - _followDistance));
    }
}
