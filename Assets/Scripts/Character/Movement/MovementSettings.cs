using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "DefaultMovement", menuName = "Custom/Movement Settings")]
public class MovementSettings : ScriptableObject
{
    [SerializeField]
    private float _maxSpeed = 5.0f;
    public float maxSpeed => _maxSpeed;

    [SerializeField]
    private float _acceleration = 10.0f;
    public float acceleration => _acceleration;

    [SerializeField]
    private float _slowDown = 15.0f;
    public float slowDown => _slowDown;

    [SerializeField]
    private float _maxAngle = 360.0f;
    public float maxAngle => _maxAngle;

    [SerializeField]
    private float _reverseAngle = 165.0f;
    public float reverseAngle => _reverseAngle;

    [SerializeField]
    private float _reverseAcceleration = 20.0f;
    public float reverseAcceleration => _reverseAcceleration;

}
